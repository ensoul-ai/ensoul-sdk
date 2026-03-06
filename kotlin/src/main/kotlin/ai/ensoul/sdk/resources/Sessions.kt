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

class Sessions(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun create(
        personaId: String,
        tier: Int = 0,
        parentSessionId: String? = null,
        systemInstructions: String? = null,
        extras: Map<String, Any?> = emptyMap(),
    ): JsonObject {
        val body = mutableMapOf<String, Any?>("tier" to tier)
        parentSessionId?.let { body["parent_session_id"] = it }
        systemInstructions?.let { body["system_instructions"] = it }
        body.putAll(extras.filterValues { it != null })
        val response = client.post("/v1/personas/$personaId/sessions", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun get(personaId: String, sessionId: String): JsonObject {
        val response = client.get("/v1/personas/$personaId/sessions/$sessionId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun list(personaId: String, page: Int = 1, perPage: Int = 20): Page<JsonObject> {
        val params = mapOf<String, Any?>("page" to page, "per_page" to perPage)
        val response = client.get("/v1/personas/$personaId/sessions", params = params)
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
            path = "/v1/personas/$personaId/sessions",
            params = params,
            deserializer = { it },
        )
    }

    suspend fun getChildren(personaId: String, sessionId: String): List<JsonObject> {
        val response = client.get("/v1/personas/$personaId/sessions/$sessionId/children")
        val data = json.parseToJsonElement(response.bodyAsText())
        return if (data is JsonArray) {
            data.map { it.jsonObject }
        } else {
            data.jsonObject["items"]?.jsonArray?.map { it.jsonObject } ?: emptyList()
        }
    }

    suspend fun aggregateChildren(
        personaId: String,
        sessionId: String,
        aggregationMode: String = "summary",
    ): JsonObject {
        val body = mapOf<String, Any?>("aggregation_mode" to aggregationMode)
        val response = client.post(
            "/v1/personas/$personaId/sessions/$sessionId/aggregate",
            json = body,
        )
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
