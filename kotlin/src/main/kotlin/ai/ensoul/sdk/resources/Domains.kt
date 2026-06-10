package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.Page
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonPrimitive

class Domains(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun list(
        page: Int = 1,
        perPage: Int = 20,
        extras: Map<String, Any?> = emptyMap(),
    ): Page<JsonObject> {
        val params = mutableMapOf<String, Any?>("page" to page, "per_page" to perPage)
        params.putAll(extras.filterValues { it != null })
        val response = client.get("/v1/domains", params = params)
        val text = response.bodyAsText()
        val data = json.parseToJsonElement(text).jsonObject
        val items = data["items"]!!.jsonArray.map { it.jsonObject }
        return Page(
            items = items,
            total = data["total"]!!.jsonPrimitive.int,
            page = data["page"]!!.jsonPrimitive.int,
            perPage = data["per_page"]!!.jsonPrimitive.int,
            pages = data["pages"]!!.jsonPrimitive.int,
            client = client,
            method = "GET",
            path = "/v1/domains",
            params = params,
            deserializer = { it.jsonObject },
        )
    }

    suspend fun get(domainId: String): JsonObject {
        val response = client.get("/v1/domains/$domainId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun create(body: Map<String, Any?>): JsonObject {
        val response = client.post("/v1/domains", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun update(domainId: String, body: Map<String, Any?>): JsonObject {
        val response = client.put("/v1/domains/$domainId", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun delete(domainId: String) {
        client.delete("/v1/domains/$domainId")
    }

    /** POST /v1/domains/validate — validate a domain config (`DomainConfigCreate`). */
    suspend fun validate(config: Map<String, Any?>): JsonObject {
        val response = client.post("/v1/domains/validate", json = config)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
