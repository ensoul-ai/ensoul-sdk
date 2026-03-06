package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject

class Health(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun check(): JsonObject {
        val response = client.getRaw("/health")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun ready(): JsonObject {
        val response = client.getRaw("/health/ready")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun live(): JsonObject {
        val response = client.getRaw("/health/live")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}
