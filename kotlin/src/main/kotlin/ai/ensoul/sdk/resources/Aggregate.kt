package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.SseStream
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject

class Aggregate(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun query(
        query: String,
        filters: Map<String, Any?>? = null,
        aggregationMode: String? = null,
    ): JsonObject {
        val body = mutableMapOf<String, Any?>("query" to query)
        filters?.let { body["filters"] = it }
        aggregationMode?.let { body["aggregation_mode"] = it }
        val response = client.post("/v1/aggregate/query", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

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

    suspend fun groupedStream(
        query: String,
        groupBy: String,
        filters: Map<String, Any?>? = null,
    ): SseStream {
        val body = mutableMapOf<String, Any?>("query" to query, "group_by" to groupBy)
        filters?.let { body["filters"] = it }
        return client.streamSse(HttpMethod.Post, "/v1/aggregate/stream/grouped", json = body)
    }

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
        val response = client.post("/v1/aggregate/simulate", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

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
