package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.SseStream
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject

/**
 * Aggregate resource for the Ensoul SDK.
 *
 * As of API 0.2.0 the one-shot `POST /v1/aggregate/query` route was removed and
 * split into `GET /v1/aggregate/count` and `GET /v1/aggregate/stats`. The
 * forward-simulation route moved from `/v1/aggregate/simulate` to
 * `/v1/aggregate/simulation`. See
 * `sdks/openapi/namespace-migration-contract.md`.
 */
class Aggregate(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    /** GET /v1/aggregate/count — count personas matching a filter. */
    suspend fun count(
        domain: String? = null,
        filters: String? = null,
        region: String? = null,
        archetype: String? = null,
        ageMin: Int? = null,
        ageMax: Int? = null,
    ): JsonObject {
        val params = mutableMapOf<String, Any?>()
        domain?.let { params["domain"] = it }
        filters?.let { params["filters"] = it }
        region?.let { params["region"] = it }
        archetype?.let { params["archetype"] = it }
        ageMin?.let { params["age_min"] = it }
        ageMax?.let { params["age_max"] = it }
        val response = client.get("/v1/aggregate/count", params = params)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/aggregate/stats — aggregate query statistics. */
    suspend fun stats(): JsonObject {
        val response = client.get("/v1/aggregate/stats")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/aggregate/stream — returns an SSE stream of progress events. */
    suspend fun stream(
        query: String,
        filters: Map<String, Any?>? = null,
        aggregationMode: String? = null,
        targetConfidence: Double = 0.95,
        minSamples: Int = 100,
        maxSamples: Int? = null,
    ): SseStream {
        val body = mutableMapOf<String, Any?>(
            "query" to query,
            "target_confidence" to targetConfidence,
            "min_samples" to minSamples,
        )
        filters?.let { body["filters"] = it }
        aggregationMode?.let { body["aggregation_mode"] = it }
        maxSamples?.let { body["max_samples"] = it }
        return client.streamSse(HttpMethod.Post, "/v1/aggregate/stream", json = body)
    }

    /** POST /v1/aggregate/stream/grouped */
    suspend fun groupedStream(
        query: String,
        groupBy: String,
        filters: Map<String, Any?>? = null,
    ): SseStream {
        val body = mutableMapOf<String, Any?>("query" to query, "group_by" to groupBy)
        filters?.let { body["filters"] = it }
        return client.streamSse(HttpMethod.Post, "/v1/aggregate/stream/grouped", json = body)
    }

    /** POST /v1/aggregate/simulation (`SimulationRequest`). */
    suspend fun simulate(
        scenario: String,
        targetCohort: Map<String, Any?>? = null,
        durationDays: Int = 30,
        parameters: Map<String, Any?>? = null,
    ): JsonObject {
        val body = mutableMapOf<String, Any?>(
            "scenario" to scenario,
            "duration_days" to durationDays,
        )
        targetCohort?.let { body["target_cohort"] = it }
        parameters?.let { body["parameters"] = it }
        val response = client.post("/v1/aggregate/simulation", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/aggregate/influence/{personaId} */
    suspend fun traceInfluence(
        personaId: String,
        influenceType: String? = null,
        direction: String = "downstream",
        maxDepth: Int = 3,
    ): JsonObject {
        val params = mutableMapOf<String, Any?>("direction" to direction, "max_depth" to maxDepth)
        influenceType?.let { params["influence_type"] = it }
        val response = client.get("/v1/aggregate/influence/$personaId", params = params)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
