package ai.ensoul.sdk

import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.serialization.json.*

private val pageJson = Json { ignoreUnknownKeys = true; isLenient = true }

class Page<T>(
    val items: List<T>,
    val total: Int,
    val page: Int,
    val perPage: Int,
    val pages: Int,
    private val client: EnsoulHttpClient,
    private val method: String,
    private val path: String,
    private val params: Map<String, Any?>,
    private val deserializer: (JsonObject) -> T,
) {
    fun hasNextPage(): Boolean = page < pages

    suspend fun nextPage(): Page<T> {
        val nextParams = params + ("page" to (page + 1))
        val response = client.request(
            method = HttpMethod.parse(method),
            path = path,
            params = nextParams,
        )
        return fromResponse(response, client, method, path, nextParams, deserializer)
    }

    operator fun iterator(): Iterator<T> = items.iterator()

    fun autoPagingFlow(): Flow<T> = flow {
        var current = this@Page
        while (true) {
            current.items.forEach { emit(it) }
            if (!current.hasNextPage()) break
            current = current.nextPage()
        }
    }

    companion object {
        suspend fun <T> fromResponse(
            response: HttpResponse,
            client: EnsoulHttpClient,
            method: String,
            path: String,
            params: Map<String, Any?>,
            deserializer: (JsonObject) -> T,
        ): Page<T> {
            val body = response.bodyAsText()
            val root = pageJson.parseToJsonElement(body).jsonObject
            val rawItems = root["items"]?.jsonArray ?: JsonArray(emptyList())
            val items = rawItems.mapNotNull { element ->
                element.jsonObject.let { deserializer(it) }
            }
            val total = root["total"]?.jsonPrimitive?.int ?: 0
            val page = root["page"]?.jsonPrimitive?.int ?: 1
            val perPage = root["per_page"]?.jsonPrimitive?.int ?: items.size
            val pages = root["pages"]?.jsonPrimitive?.int ?: 1
            return Page(
                items = items,
                total = total,
                page = page,
                perPage = perPage,
                pages = pages,
                client = client,
                method = method,
                path = path,
                params = params,
                deserializer = deserializer,
            )
        }
    }
}
