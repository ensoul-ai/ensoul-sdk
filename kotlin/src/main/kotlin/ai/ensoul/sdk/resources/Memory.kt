package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.Page
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray

class Memory(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun create(
        personaId: String,
        content: String,
        memoryType: String = "episodic",
        importance: Double = 0.5,
        metadata: Map<String, Any?>? = null,
    ): JsonObject {
        val body = mutableMapOf<String, Any?>(
            "content" to content,
            "memory_type" to memoryType,
            "importance" to importance,
        )
        metadata?.let { body["metadata"] = it }
        val response = client.post("/v1/personas/$personaId/memories", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun list(personaId: String, page: Int = 1, perPage: Int = 20): Page<JsonObject> {
        val params = mapOf<String, Any?>("page" to page, "per_page" to perPage)
        val response = client.get("/v1/personas/$personaId/memories", params = params)
        val text = response.bodyAsText()
        val data = json.parseToJsonElement(text).jsonObject
        val rawItems = data["items"]?.jsonArray?.map { it.jsonObject } ?: emptyList()
        return Page(
            items = rawItems,
            total = data["total"]?.jsonPrimitive?.intOrNull ?: rawItems.size,
            page = data["page"]?.jsonPrimitive?.intOrNull ?: page,
            perPage = data["per_page"]?.jsonPrimitive?.intOrNull ?: perPage,
            pages = data["pages"]?.jsonPrimitive?.intOrNull ?: 1,
            client = client,
            method = "GET",
            path = "/v1/personas/$personaId/memories",
            params = params,
            deserializer = { it },
        )
    }

    suspend fun get(personaId: String, memoryId: String): JsonObject {
        val response = client.get("/v1/personas/$personaId/memories/$memoryId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun delete(personaId: String, memoryId: String) {
        client.delete("/v1/personas/$personaId/memories/$memoryId")
    }

    suspend fun batchCreate(personaId: String, memories: List<Map<String, Any?>>): JsonObject {
        val body = mapOf<String, Any?>("memories" to memories)
        val response = client.post("/v1/personas/$personaId/memories/batch", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun consolidate(personaId: String): JsonObject {
        val response = client.post("/v1/personas/$personaId/memories/consolidate", json = emptyMap<String, Any?>())
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun queryKnowledge(personaId: String, query: String): JsonObject {
        val body = mapOf<String, Any?>("query" to query)
        val response = client.post("/v1/personas/$personaId/knowledge/query", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
