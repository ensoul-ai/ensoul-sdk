package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.Page
import ai.ensoul.sdk.generated.PersonaBatchResponse
import ai.ensoul.sdk.generated.PersonaFiltersResponse
import ai.ensoul.sdk.generated.PersonaResponse
import ai.ensoul.sdk.generated.PersonalityVectorResponse
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonPrimitive

class Personas(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun create(
        name: String,
        domain: String,
        personalityData: Map<String, Any?>? = null,
        extras: Map<String, Any?> = emptyMap(),
    ): PersonaResponse {
        val body = mutableMapOf<String, Any?>("name" to name, "domain" to domain)
        personalityData?.let { body["personality_data"] = it }
        body.putAll(extras.filterValues { it != null })
        val response = client.post("/v1/personas", json = body)
        return json.decodeFromString(PersonaResponse.serializer(), response.bodyAsText())
    }

    suspend fun get(personaId: String): PersonaResponse {
        val response = client.get("/v1/personas/$personaId")
        return json.decodeFromString(PersonaResponse.serializer(), response.bodyAsText())
    }

    suspend fun update(personaId: String, fields: Map<String, Any?> = emptyMap()): PersonaResponse {
        val body = fields.filterValues { it != null }
        val response = client.put("/v1/personas/$personaId", json = body)
        return json.decodeFromString(PersonaResponse.serializer(), response.bodyAsText())
    }

    suspend fun delete(personaId: String) {
        client.delete("/v1/personas/$personaId")
    }

    suspend fun list(
        page: Int = 1,
        perPage: Int = 20,
        region: String? = null,
        archetype: String? = null,
        country: String? = null,
        city: String? = null,
        extras: Map<String, Any?> = emptyMap(),
    ): Page<PersonaResponse> {
        val params = mutableMapOf<String, Any?>("page" to page, "per_page" to perPage)
        region?.let { params["region"] = it }
        archetype?.let { params["archetype"] = it }
        country?.let { params["country"] = it }
        city?.let { params["city"] = it }
        params.putAll(extras.filterValues { it != null })
        val response = client.get("/v1/personas", params = params)
        val text = response.bodyAsText()
        val data = json.parseToJsonElement(text).jsonObject
        val items = data["items"]!!.jsonArray.map {
            json.decodeFromJsonElement(PersonaResponse.serializer(), it)
        }
        return Page(
            items = items,
            total = data["total"]!!.jsonPrimitive.int,
            page = data["page"]!!.jsonPrimitive.int,
            perPage = data["per_page"]!!.jsonPrimitive.int,
            pages = data["pages"]!!.jsonPrimitive.int,
            client = client,
            method = "GET",
            path = "/v1/personas",
            params = params,
            deserializer = { json.decodeFromJsonElement(PersonaResponse.serializer(), it) },
        )
    }

    suspend fun batchCreate(
        personas: List<Map<String, Any?>>,
        batchId: String? = null,
        domain: String? = null,
    ): PersonaBatchResponse {
        val body = mutableMapOf<String, Any?>("personas" to personas)
        batchId?.let { body["batch_id"] = it }
        domain?.let { body["domain"] = it }
        val response = client.post("/v1/personas/batch", json = body)
        return json.decodeFromString(PersonaBatchResponse.serializer(), response.bodyAsText())
    }

    suspend fun getPersonality(personaId: String): PersonalityVectorResponse {
        val response = client.get("/v1/personas/$personaId/personality")
        return json.decodeFromString(PersonalityVectorResponse.serializer(), response.bodyAsText())
    }

    suspend fun getFilters(): PersonaFiltersResponse {
        val response = client.get("/v1/personas/filters")
        return json.decodeFromString(PersonaFiltersResponse.serializer(), response.bodyAsText())
    }

    suspend fun getConnections(personaId: String): List<JsonObject> {
        val response = client.get("/v1/personas/$personaId/connections")
        val text = response.bodyAsText()
        return json.parseToJsonElement(text).jsonArray.map { it.jsonObject }
    }
}
