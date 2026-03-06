package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject

class Info(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun config(): JsonObject {
        val response = client.get("/v1/info/config")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun rateLimits(): JsonObject {
        val response = client.get("/v1/info/rate-limits")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun tiers(): JsonObject {
        val response = client.get("/v1/info/tiers")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun features(): JsonObject {
        val response = client.get("/v1/info/features")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
