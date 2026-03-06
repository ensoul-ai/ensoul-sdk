package ai.ensoul.sdk

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Base exception for all Ensoul SDK errors. */
open class EnsoulError(message: String) : Exception(message)

/** Error returned by the Ensoul API. */
open class APIError(
    val statusCode: Int,
    val error: String,
    message: String,
    val requestId: String? = null,
) : EnsoulError(message) {
    override fun toString(): String =
        "${this::class.simpleName}(statusCode=$statusCode, error=${error.let { "\"$it\"" }}, message=${message?.let { "\"$it\"" }})"
}

/** HTTP 401 — authentication failed or token missing/expired. */
class AuthenticationError(
    statusCode: Int,
    error: String,
    message: String,
    requestId: String? = null,
) : APIError(statusCode, error, message, requestId)

/** HTTP 403 — authenticated but not permitted. */
class AuthorizationError(
    statusCode: Int,
    error: String,
    message: String,
    requestId: String? = null,
    val requiredTier: String? = null,
    val currentTier: String? = null,
) : APIError(statusCode, error, message, requestId)

/** HTTP 404 — requested resource does not exist. */
class NotFoundError(
    statusCode: Int,
    error: String,
    message: String,
    requestId: String? = null,
    val resourceType: String? = null,
    val resourceId: String? = null,
) : APIError(statusCode, error, message, requestId)

/** HTTP 429 — too many requests. */
class RateLimitError(
    statusCode: Int,
    error: String,
    message: String,
    requestId: String? = null,
    val retryAfter: Int = 0,
) : APIError(statusCode, error, message, requestId)

/** Detail entry for a validation error. */
data class ErrorDetail(
    val field: String,
    val message: String,
    val type: String,
)

/** HTTP 422 — request body failed validation. */
class ValidationError(
    statusCode: Int,
    error: String,
    message: String,
    requestId: String? = null,
    val details: List<ErrorDetail> = emptyList(),
) : APIError(statusCode, error, message, requestId)

/** HTTP 409 — resource already exists or state conflict. */
class ConflictError(
    statusCode: Int,
    error: String,
    message: String,
    requestId: String? = null,
) : APIError(statusCode, error, message, requestId)

/** HTTP 500 / 503 — server-side failure. */
class ServerError(
    statusCode: Int,
    error: String,
    message: String,
    requestId: String? = null,
) : APIError(statusCode, error, message, requestId)

private val lenientJson = Json { ignoreUnknownKeys = true; isLenient = true }

/**
 * Raise an appropriate SDK exception for 4xx/5xx responses.
 *
 * @param statusCode HTTP status code
 * @param body Raw response body string
 * @param headers Response headers map (values are lists per HTTP spec)
 */
fun raiseForStatus(
    statusCode: Int,
    body: String,
    headers: Map<String, List<String>> = emptyMap(),
) {
    if (statusCode < 400) return

    val parsed: JsonObject? = try {
        lenientJson.parseToJsonElement(body).jsonObject
    } catch (_: Exception) {
        null
    }

    val error = parsed?.get("error")?.jsonPrimitive?.contentOrNull ?: "Unknown Error"
    val message = parsed?.get("message")?.jsonPrimitive?.contentOrNull ?: "Unknown error"
    val requestId = parsed?.get("request_id")?.jsonPrimitive?.contentOrNull

    when (statusCode) {
        401 -> throw AuthenticationError(statusCode, error, message, requestId)
        403 -> throw AuthorizationError(statusCode, error, message, requestId)
        404 -> throw NotFoundError(statusCode, error, message, requestId)
        409 -> throw ConflictError(statusCode, error, message, requestId)
        422 -> {
            val rawDetails = try {
                parsed?.get("details")?.jsonArray
            } catch (_: Exception) {
                null
            }
            val details = rawDetails?.mapNotNull { element ->
                try {
                    val obj = element.jsonObject
                    ErrorDetail(
                        field = obj["field"]?.jsonPrimitive?.contentOrNull ?: "",
                        message = obj["message"]?.jsonPrimitive?.contentOrNull ?: "",
                        type = obj["type"]?.jsonPrimitive?.contentOrNull ?: "",
                    )
                } catch (_: Exception) {
                    null
                }
            } ?: emptyList()
            throw ValidationError(statusCode, error, message, requestId, details)
        }
        429 -> {
            val retryAfterRaw = headers["retry-after"]?.firstOrNull()
                ?: headers["Retry-After"]?.firstOrNull()
                ?: "0"
            val retryAfter = retryAfterRaw.toIntOrNull() ?: 0
            throw RateLimitError(statusCode, error, message, requestId, retryAfter)
        }
        500, 503 -> throw ServerError(statusCode, error, message, requestId)
        else -> throw APIError(statusCode, error, message, requestId)
    }
}
