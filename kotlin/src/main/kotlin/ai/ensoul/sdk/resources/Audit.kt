package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import io.ktor.client.statement.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject

/**
 * Audit and verification resource for the Ensoul SDK.
 *
 * Exposes the tamper-evident audit trail (Merkle-committed communication events)
 * and the public content-verification endpoint. Responses are returned as raw
 * decoded JSON, matching the untyped resource methods elsewhere in the SDK.
 */
class Audit(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    /** GET /v1/audit/events/{eventId} */
    suspend fun getEvent(eventId: String): JsonObject {
        val response = client.get("/v1/audit/events/$eventId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/audit/commitments/{commitmentId} */
    suspend fun getCommitment(commitmentId: String): JsonObject {
        val response = client.get("/v1/audit/commitments/$commitmentId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/audit/proofs/{eventId} — Merkle inclusion proof. */
    suspend fun getProof(eventId: String): JsonObject {
        val response = client.get("/v1/audit/proofs/$eventId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/verify — verify AI-generated content against the audit trail. */
    suspend fun verify(auditEventId: String, contentHash: String? = null): JsonObject {
        val body = mutableMapOf<String, Any?>("audit_event_id" to auditEventId)
        contentHash?.let { body["content_hash"] = it }
        val response = client.post("/v1/verify", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /.well-known/ensoul-signing-key.pem — ECDSA public key (PEM text). */
    suspend fun getSigningKey(): String {
        val response = client.getRaw("/.well-known/ensoul-signing-key.pem")
        return response.bodyAsText()
    }
}
