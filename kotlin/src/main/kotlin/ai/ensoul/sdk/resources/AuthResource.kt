package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.generated.APIKeyResponse
import ai.ensoul.sdk.generated.TokenResponse
import ai.ensoul.sdk.generated.UserResponse
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject

class AuthResource(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun token(username: String, password: String): TokenResponse {
        val response = client.postForm(
            "/v1/auth/token",
            mapOf(
                "username" to username,
                "password" to password,
                "grant_type" to "password",
            ),
        )
        return json.decodeFromString(TokenResponse.serializer(), response.bodyAsText())
    }

    suspend fun refresh(refreshToken: String): TokenResponse {
        val body = mapOf<String, Any?>(
            "refresh_token" to refreshToken,
            "grant_type" to "refresh_token",
        )
        val response = client.post("/v1/auth/refresh", json = body)
        return json.decodeFromString(TokenResponse.serializer(), response.bodyAsText())
    }

    suspend fun me(): UserResponse {
        val response = client.get("/v1/auth/me")
        return json.decodeFromString(UserResponse.serializer(), response.bodyAsText())
    }

    suspend fun createApiKey(
        name: String,
        expiresDays: Int = 365,
        scopes: List<String>? = null,
    ): APIKeyResponse {
        val body = mutableMapOf<String, Any?>("name" to name, "expires_days" to expiresDays)
        scopes?.let { body["scopes"] = it }
        val response = client.post("/v1/api-keys", json = body)
        return json.decodeFromString(APIKeyResponse.serializer(), response.bodyAsText())
    }

    suspend fun listApiKeys(): List<APIKeyResponse> {
        val response = client.get("/v1/api-keys")
        val data = json.parseToJsonElement(response.bodyAsText())
        val items = if (data is JsonArray) {
            data.map { json.decodeFromJsonElement(APIKeyResponse.serializer(), it) }
        } else {
            data.jsonObject["items"]?.jsonArray?.map {
                json.decodeFromJsonElement(APIKeyResponse.serializer(), it)
            } ?: emptyList()
        }
        return items
    }

    suspend fun revokeApiKey(keyId: String) {
        client.delete("/v1/api-keys/$keyId")
    }
}
