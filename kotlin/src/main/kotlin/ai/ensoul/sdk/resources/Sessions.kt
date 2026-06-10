package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.Page
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Sessions resource for the Ensoul SDK.
 *
 * Hierarchical session orchestration under `/v1/sessions`. As of API 0.2.0
 * these routes are no longer nested under a persona: a session is created
 * against the authenticated team/user context, so [create] no longer takes a
 * `personaId` (the `SessionCreate` body has no persona field). This is a
 * distinct family from `/v1/chat/sessions` (chat-message threads). See
 * `sdks/openapi/namespace-migration-contract.md`.
 */
class Sessions(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    /** POST /v1/sessions — create a session (`SessionCreate`). */
    suspend fun create(
        tier: Int = 0,
        parentSessionId: String? = null,
        systemInstructions: String? = null,
        extras: Map<String, Any?> = emptyMap(),
    ): JsonObject {
        val body = mutableMapOf<String, Any?>("tier" to tier)
        parentSessionId?.let { body["parent_session_id"] = it }
        systemInstructions?.let { body["system_instructions"] = it }
        body.putAll(extras.filterValues { it != null })
        val response = client.post("/v1/sessions", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/sessions/{sessionId} */
    suspend fun get(sessionId: String): JsonObject {
        val response = client.get("/v1/sessions/$sessionId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /**
     * DELETE /v1/sessions/{sessionId}
     *
     * The transport's `delete` takes no query params, so `cancelChildren` is
     * embedded directly in the path string.
     */
    suspend fun delete(sessionId: String, cancelChildren: Boolean = false) {
        client.delete("/v1/sessions/$sessionId?cancel_children=${if (cancelChildren) "true" else "false"}")
    }

    /** GET /v1/sessions — list sessions (paginated). */
    suspend fun list(
        tier: Int? = null,
        status: String? = null,
        parentSessionId: String? = null,
        page: Int = 1,
        perPage: Int = 20,
    ): Page<JsonObject> {
        val params = mutableMapOf<String, Any?>("page" to page, "per_page" to perPage)
        tier?.let { params["tier"] = it }
        status?.let { params["status"] = it }
        parentSessionId?.let { params["parent_session_id"] = it }
        val response = client.get("/v1/sessions", params = params)
        val data = json.parseToJsonElement(response.bodyAsText()).jsonObject
        val rawItems = data["items"]?.jsonArray?.map { it.jsonObject } ?: emptyList()
        return Page(
            items = rawItems,
            total = data["total"]?.jsonPrimitive?.intOrNull ?: rawItems.size,
            page = data["page"]?.jsonPrimitive?.intOrNull ?: page,
            perPage = data["per_page"]?.jsonPrimitive?.intOrNull ?: perPage,
            pages = data["pages"]?.jsonPrimitive?.intOrNull ?: 1,
            client = client,
            method = "GET",
            path = "/v1/sessions",
            params = params,
            deserializer = { it },
        )
    }

    /** GET /v1/sessions/hierarchy — full session tree. */
    suspend fun hierarchy(): JsonObject {
        val response = client.get("/v1/sessions/hierarchy")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/sessions/info — session-system info. */
    suspend fun info(): JsonObject {
        val response = client.get("/v1/sessions/info")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/sessions/stats/summary — session statistics. */
    suspend fun stats(): JsonObject {
        val response = client.get("/v1/sessions/stats/summary")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/sessions/{sessionId}/children */
    suspend fun getChildren(sessionId: String, page: Int = 1, perPage: Int = 20): List<JsonObject> {
        val params = mapOf<String, Any?>("page" to page, "per_page" to perPage)
        val response = client.get("/v1/sessions/$sessionId/children", params = params)
        val data = json.parseToJsonElement(response.bodyAsText())
        return if (data is JsonArray) {
            data.map { it.jsonObject }
        } else {
            data.jsonObject["items"]?.jsonArray?.map { it.jsonObject } ?: emptyList()
        }
    }

    /** POST /v1/sessions/{sessionId}/aggregate (`AggregateChildrenRequest`). */
    suspend fun aggregateChildren(
        sessionId: String,
        aggregationMode: String = "summary",
    ): JsonObject {
        val body = mapOf<String, Any?>("aggregation_mode" to aggregationMode)
        val response = client.post("/v1/sessions/$sessionId/aggregate", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
