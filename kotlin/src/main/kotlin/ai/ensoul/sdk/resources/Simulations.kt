package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.Page
import ai.ensoul.sdk.SseStream
import ai.ensoul.sdk.generated.SimulationDetailResponse
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonPrimitive

class Simulations(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun create(
        name: String,
        domainId: String,
        description: String? = null,
        config: Map<String, Any?>? = null,
        participantPersonaIds: List<String>? = null,
    ): SimulationDetailResponse {
        val body = mutableMapOf<String, Any?>("name" to name, "domain_id" to domainId)
        description?.let { body["description"] = it }
        config?.let { body["config"] = it }
        participantPersonaIds?.let { body["participant_persona_ids"] = it }
        val response = client.post("/v1/simulations", json = body)
        return json.decodeFromString(SimulationDetailResponse.serializer(), response.bodyAsText())
    }

    suspend fun get(simulationId: String): SimulationDetailResponse {
        val response = client.get("/v1/simulations/$simulationId")
        return json.decodeFromString(SimulationDetailResponse.serializer(), response.bodyAsText())
    }

    suspend fun list(
        page: Int = 1,
        perPage: Int = 20,
        extras: Map<String, Any?> = emptyMap(),
    ): Page<JsonObject> {
        val params = mutableMapOf<String, Any?>("page" to page, "per_page" to perPage)
        params.putAll(extras.filterValues { it != null })
        val response = client.get("/v1/simulations", params = params)
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
            path = "/v1/simulations",
            params = params,
            deserializer = { it.jsonObject },
        )
    }

    suspend fun start(simulationId: String, ticks: Int? = null): JsonObject {
        val body = mutableMapOf<String, Any?>()
        ticks?.let { body["ticks"] = it }
        val response = client.post("/v1/simulations/$simulationId/start", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun pause(simulationId: String): JsonObject {
        val response = client.post("/v1/simulations/$simulationId/pause", json = emptyMap<String, Any?>())
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun stream(simulationId: String): SseStream {
        return client.streamSse(HttpMethod.Get, "/v1/simulations/$simulationId/stream")
    }

    suspend fun getEvents(
        simulationId: String,
        page: Int = 1,
        perPage: Int = 20,
        extras: Map<String, Any?> = emptyMap(),
    ): Page<JsonObject> {
        val params = mutableMapOf<String, Any?>("page" to page, "per_page" to perPage)
        params.putAll(extras.filterValues { it != null })
        val response = client.get("/v1/simulations/$simulationId/events", params = params)
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
            path = "/v1/simulations/$simulationId/events",
            params = params,
            deserializer = { it.jsonObject },
        )
    }

    suspend fun getHistory(simulationId: String): JsonObject {
        val response = client.get("/v1/simulations/$simulationId/history")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/simulations/{simulationId}/participants */
    suspend fun listParticipants(
        simulationId: String,
        page: Int = 1,
        perPage: Int = 20,
    ): JsonObject {
        val params = mapOf<String, Any?>("page" to page, "per_page" to perPage)
        val response = client.get("/v1/simulations/$simulationId/participants", params = params)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/simulations/{simulationId}/participants */
    suspend fun addParticipants(
        simulationId: String,
        personaIds: List<String>,
    ): JsonObject {
        val body = mapOf<String, Any?>("persona_ids" to personaIds)
        val response = client.post("/v1/simulations/$simulationId/participants", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/simulations/{simulationId}/events/ticks */
    suspend fun getEventTicks(simulationId: String): JsonObject {
        val response = client.get("/v1/simulations/$simulationId/events/ticks")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
