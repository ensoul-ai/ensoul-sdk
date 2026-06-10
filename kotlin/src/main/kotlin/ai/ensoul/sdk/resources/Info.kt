package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject

/**
 * Info resource for the Ensoul SDK.
 *
 * As of API 0.2.0 the four `/v1/info` routes were replaced by a single
 * `GET /v1/api/info` returning an `APIInfoResponse` blob. The convenience
 * methods below each fetch that blob and return their relevant sub-section, so
 * existing call sites keep working without four separate round-trips becoming
 * four copies of the same payload. See
 * `sdks/openapi/namespace-migration-contract.md`.
 */
class Info(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    /** GET /v1/api/info — full server info (`APIInfoResponse`). */
    suspend fun get(): JsonObject {
        val response = client.get("/v1/api/info")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** Full server configuration blob (alias for [get]). */
    suspend fun config(): JsonObject = get()

    /** Rate-limiting configuration sub-section. */
    suspend fun rateLimits(): JsonObject =
        get()["rate_limiting"]?.jsonObject ?: JsonObject(emptyMap())

    /** Access-tier definitions sub-section. */
    suspend fun tiers(): JsonArray =
        get()["access_tiers"]?.jsonArray ?: JsonArray(emptyList())

    /** Feature-flags sub-section. */
    suspend fun features(): JsonObject =
        get()["features"]?.jsonObject ?: JsonObject(emptyMap())
}
