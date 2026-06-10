package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject

/**
 * Memory resource for the Ensoul SDK.
 *
 * Wraps the `/v1/memory` endpoints. As of API 0.2.0 these routes were rebased
 * off `/v1/personas/{id}/memories` onto `/v1/memory/{personaId}`. See
 * `sdks/openapi/namespace-migration-contract.md`.
 */
class Memory(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    /** GET /v1/memory/stats — global memory statistics. */
    suspend fun stats(): JsonObject {
        val response = client.get("/v1/memory/stats")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/memory/{personaId} — add a memory (`MemoryCreate`). */
    suspend fun create(
        personaId: String,
        content: String,
        source: String = "user",
        references: Map<String, Any?>? = null,
    ): JsonObject {
        val body = mutableMapOf<String, Any?>(
            "content" to content,
            "source" to source,
        )
        references?.let { body["references"] = it }
        val response = client.post("/v1/memory/$personaId", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /**
     * GET /v1/memory/{personaId} — list memories.
     *
     * Returns the `MemoriesResponse` shape
     * `{persona_id, memories, working_memory, total}` (not a paginated envelope —
     * the API does not page this route).
     */
    suspend fun list(personaId: String, limit: Int = 50, offset: Int = 0): JsonObject {
        val params = mapOf<String, Any?>("limit" to limit, "offset" to offset)
        val response = client.get("/v1/memory/$personaId", params = params)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** DELETE /v1/memory/{personaId} — delete all memories for a persona. */
    suspend fun clear(personaId: String) {
        client.delete("/v1/memory/$personaId")
    }

    /** DELETE /v1/memory/{personaId}/{memoryId} — delete one memory. */
    suspend fun delete(personaId: String, memoryId: String) {
        client.delete("/v1/memory/$personaId/$memoryId")
    }

    /** PATCH /v1/memory/{personaId}/{memoryId}/access — record an access. */
    suspend fun updateAccess(personaId: String, memoryId: String): JsonObject {
        val response = client.patch("/v1/memory/$personaId/$memoryId/access")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/memory/{personaId}/batch — add many memories at once. */
    suspend fun batchCreate(personaId: String, memories: List<Map<String, Any?>>): JsonObject {
        val body = mapOf<String, Any?>("memories" to memories)
        val response = client.post("/v1/memory/$personaId/batch", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/memory/{personaId}/consolidate — consolidate memories. */
    suspend fun consolidate(personaId: String): JsonObject {
        val response = client.post("/v1/memory/$personaId/consolidate", json = emptyMap<String, Any?>())
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/memory/{personaId}/generate — generate memories. */
    suspend fun generate(personaId: String, options: Map<String, Any?> = emptyMap()): JsonObject {
        val response = client.post("/v1/memory/$personaId/generate", json = options)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/memory/{personaId}/working — working-memory snapshot. */
    suspend fun working(personaId: String): JsonObject {
        val response = client.get("/v1/memory/$personaId/working")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/memory/{personaId}/knowledge — retrieve RAG knowledge. */
    suspend fun getKnowledge(personaId: String): JsonObject {
        val response = client.get("/v1/memory/$personaId/knowledge")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/memory/{personaId}/knowledge — add RAG knowledge (`KnowledgeCreate`). */
    suspend fun addKnowledge(personaId: String, content: String, source: String): JsonObject {
        val body = mapOf<String, Any?>("content" to content, "source" to source)
        val response = client.post("/v1/memory/$personaId/knowledge", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
