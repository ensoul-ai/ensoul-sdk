package ai.ensoul.sdk

import io.ktor.client.*
import io.ktor.client.engine.*
import io.ktor.client.engine.cio.*
import java.io.Closeable
import io.ktor.client.plugins.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.request.forms.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.delay
import kotlinx.serialization.json.*
import kotlin.math.min
import kotlin.random.Random

private const val SDK_USER_AGENT = "ensoul-kotlin/0.1.0"
private val RETRY_STATUS_CODES = setOf(429, 500, 502, 503)

internal fun jsonObjectFrom(map: Map<String, Any?>): JsonObject {
    return buildJsonObject {
        for ((key, value) in map) {
            put(key, toJsonElement(value))
        }
    }
}

@Suppress("UNCHECKED_CAST")
private fun toJsonElement(value: Any?): JsonElement = when (value) {
    null -> JsonNull
    is Boolean -> JsonPrimitive(value)
    is Number -> JsonPrimitive(value)
    is String -> JsonPrimitive(value)
    is Map<*, *> -> jsonObjectFrom(value as Map<String, Any?>)
    is List<*> -> buildJsonArray { value.forEach { add(toJsonElement(it)) } }
    else -> JsonPrimitive(value.toString())
}

private fun buildAuth(config: ClientConfig): AuthProvider = when {
    config.apiKey != null -> APIKeyAuth(config.apiKey)
    config.bearerToken != null -> BearerAuth(config.bearerToken)
    else -> APIKeyAuth("")
}

private fun normalizePath(path: String): String {
    val versionPrefix = "/$API_VERSION/"
    val noSlash = path.trimStart('/')
    return if (noSlash.startsWith("$API_VERSION/") || path.startsWith(versionPrefix)) {
        if (path.startsWith("/")) path else "/$path"
    } else {
        "/$API_VERSION/$noSlash"
    }
}

private fun retryWait(attempt: Int, retryAfter: Double?): Double {
    if (retryAfter != null && retryAfter > 0) return retryAfter
    val baseWait = min(0.5 * (1 shl attempt).toDouble(), 30.0)
    val jitter = Random.nextDouble(0.0, 1.0)
    return baseWait + jitter
}

class EnsoulHttpClient(
    private val config: ClientConfig,
    engine: HttpClientEngine? = null,
) : Closeable {

    private val auth: AuthProvider = buildAuth(config)
    private val rateLimiter = RateLimitTracker()

    internal val client: HttpClient = run {
        val block: HttpClientConfig<*>.() -> Unit = {
            install(ContentNegotiation) {
                json(Json {
                    ignoreUnknownKeys = true
                    isLenient = true
                })
            }
            defaultRequest {
                url(config.baseUrl)
                header(HttpHeaders.UserAgent, SDK_USER_AGENT)
                header(HttpHeaders.Accept, ContentType.Application.Json.toString())
                config.customHeaders.forEach { (k, v) -> header(k, v) }
            }
            install(HttpTimeout) {
                requestTimeoutMillis = config.timeout
                connectTimeoutMillis = config.timeout
            }
        }
        if (engine != null) HttpClient(engine, block) else HttpClient(CIO, block)
    }

    suspend fun request(
        method: HttpMethod,
        path: String,
        json: Map<String, Any?>? = null,
        params: Map<String, Any?>? = null,
        headers: Map<String, String>? = null,
        stream: Boolean = false,
    ): HttpResponse {
        val normalizedPath = normalizePath(path)
        var lastException: Exception? = null

        for (attempt in 0..config.maxRetries) {
            val (shouldWait, waitSeconds) = rateLimiter.shouldWait()
            if (shouldWait) {
                delay((waitSeconds * 1000).toLong())
            }

            try {
                val response = client.request(normalizedPath) {
                    this.method = method
                    auth.authHeaders().forEach { (k, v) -> header(k, v) }
                    headers?.forEach { (k, v) -> header(k, v) }

                    if (json != null) {
                        contentType(ContentType.Application.Json)
                        setBody(Json.encodeToString(JsonObject.serializer(), jsonObjectFrom(json)))
                    }

                    params?.forEach { (k, v) ->
                        if (v != null) url.parameters.append(k, v.toString())
                    }
                }

                rateLimiter.update(response.headers.entries().associate { it.key to it.value })

                val statusCode = response.status.value
                if (statusCode in RETRY_STATUS_CODES && attempt < config.maxRetries) {
                    val retryAfter: Double? = if (statusCode == 429) {
                        response.headers["Retry-After"]?.toDoubleOrNull()
                    } else null
                    val wait = retryWait(attempt, retryAfter)
                    delay((wait * 1000).toLong())
                    continue
                }

                // Only read body for error status codes — success responses are read by callers.
                if (!stream && statusCode >= 400) {
                    val bodyText = response.bodyAsText()
                    val headersMap = response.headers.entries().associate { it.key to it.value }
                    raiseForStatus(statusCode, bodyText, headersMap)
                }
                return response

            } catch (e: Exception) {
                // Re-raise SDK errors (rate limit, auth, etc.) immediately
                if (e is EnsoulError) throw e
                lastException = e
                if (attempt < config.maxRetries) {
                    delay((retryWait(attempt, null) * 1000).toLong())
                    continue
                }
                throw e
            }
        }

        throw lastException ?: RuntimeException("Exhausted retries without a response")
    }

    suspend fun get(path: String, params: Map<String, Any?>? = null): HttpResponse =
        request(HttpMethod.Get, path, params = params)

    suspend fun getRaw(path: String, params: Map<String, Any?>? = null): HttpResponse {
        val authHeaders = auth.authHeaders()
        val response = client.request(path) {
            method = HttpMethod.Get
            authHeaders.forEach { (k, v) -> header(k, v) }
            params?.forEach { (k, v) ->
                if (v != null) url.parameters.append(k, v.toString())
            }
        }
        val statusCode = response.status.value
        if (statusCode >= 400) {
            val bodyText = response.bodyAsText()
            val headersMap = response.headers.entries().associate { it.key to it.value }
            raiseForStatus(statusCode, bodyText, headersMap)
        }
        return response
    }

    suspend fun post(path: String, json: Map<String, Any?>? = null, params: Map<String, Any?>? = null): HttpResponse =
        request(HttpMethod.Post, path, json = json, params = params)

    suspend fun put(path: String, json: Map<String, Any?>? = null): HttpResponse =
        request(HttpMethod.Put, path, json = json)

    suspend fun patch(path: String, json: Map<String, Any?>? = null): HttpResponse =
        request(HttpMethod.Patch, path, json = json)

    suspend fun delete(path: String): HttpResponse =
        request(HttpMethod.Delete, path)

    suspend fun postForm(path: String, formData: Map<String, String>): HttpResponse {
        val normalizedPath = normalizePath(path)
        val authHeaders = auth.authHeaders()
        val response = client.submitForm(
            url = normalizedPath,
            formParameters = parameters {
                formData.forEach { (k, v) -> append(k, v) }
            }
        ) {
            authHeaders.forEach { (k, v) -> header(k, v) }
        }
        val statusCode = response.status.value
        if (statusCode >= 400) {
            val bodyText = response.bodyAsText()
            val headersMap = response.headers.entries().associate { it.key to it.value }
            raiseForStatus(statusCode, bodyText, headersMap)
        }
        return response
    }

    suspend fun streamSse(
        method: HttpMethod,
        path: String,
        json: Map<String, Any?>? = null,
        params: Map<String, Any?>? = null,
    ): SseStream {
        val response = request(method, path, json = json, params = params, stream = true)
        // request() skips the error check for streams (the success body is the
        // live stream and must not be consumed here). For a 4xx/5xx the body is
        // an error payload, not SSE, so surface it instead of handing back a
        // stream that would parse the error as events.
        val statusCode = response.status.value
        if (statusCode >= 400) {
            val bodyText = response.bodyAsText()
            val headersMap = response.headers.entries().associate { it.key to it.value }
            raiseForStatus(statusCode, bodyText, headersMap)
        }
        return SseStream(response)
    }

    override fun close() {
        client.close()
    }
}
