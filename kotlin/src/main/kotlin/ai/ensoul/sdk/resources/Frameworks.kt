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

class Frameworks(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun list(page: Int = 1, perPage: Int = 20): Page<JsonObject> {
        val params = mapOf<String, Any?>("page" to page, "per_page" to perPage)
        val response = client.get("/v1/frameworks", params = params)
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
            path = "/v1/frameworks",
            params = params,
            deserializer = { it },
        )
    }

    suspend fun get(frameworkId: String): JsonObject {
        val response = client.get("/v1/frameworks/$frameworkId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun create(body: Map<String, Any?>): JsonObject {
        val response = client.post("/v1/frameworks", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun update(frameworkId: String, body: Map<String, Any?>): JsonObject {
        val response = client.put("/v1/frameworks/$frameworkId", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun delete(frameworkId: String) {
        client.delete("/v1/frameworks/$frameworkId")
    }

    /** GET /v1/frameworks/{frameworkId}/validations */
    suspend fun validations(frameworkId: String): JsonObject {
        val response = client.get("/v1/frameworks/$frameworkId/validations")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun getInstruments(frameworkId: String): List<JsonObject> {
        val response = client.get("/v1/frameworks/$frameworkId/instruments")
        val data = json.parseToJsonElement(response.bodyAsText())
        return if (data is JsonArray) {
            data.map { it.jsonObject }
        } else {
            data.jsonObject["items"]?.jsonArray?.map { it.jsonObject } ?: emptyList()
        }
    }
}
