/// Audit and verification resource for the Ensoul Swift SDK.
///
/// Exposes the tamper-evident audit trail (Merkle-committed communication
/// events) and the public content-verification endpoint. Responses are returned
/// as raw decoded JSON, matching the untyped resource methods elsewhere in the
/// SDK.
///
/// Example:
/// ```swift
/// let event = try await client.audit.getEvent("evt_001")
/// let result = try await client.audit.verify(auditEventId: "evt_001")
/// let pem = try await client.audit.getSigningKey()
/// ```
import Foundation

// MARK: - Audit

@available(iOS 15.0, macOS 12.0, *)
public class Audit {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Get Event

    /// GET /v1/audit/events/{eventId}
    public func getEvent(_ eventId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/audit/events/\(eventId)")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Get Commitment

    /// GET /v1/audit/commitments/{commitmentId}
    public func getCommitment(_ commitmentId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/audit/commitments/\(commitmentId)")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Get Proof

    /// GET /v1/audit/proofs/{eventId} — Merkle inclusion proof.
    public func getProof(_ eventId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/audit/proofs/\(eventId)")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Verify

    /// POST /v1/verify — verify AI-generated content against the audit trail.
    public func verify(
        auditEventId: String,
        contentHash: String? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = ["audit_event_id": auditEventId]
        if let contentHash { body["content_hash"] = contentHash }

        let (data, _) = try await client.post("/v1/verify", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Get Signing Key

    /// GET /.well-known/ensoul-signing-key.pem — ECDSA public key (PEM text).
    ///
    /// Returns the raw PEM string (not JSON). Uses the raw transport variant so
    /// the well-known path is not rewritten with the `/v1/` prefix.
    public func getSigningKey() async throws -> String {
        let (data, _) = try await client.getRaw("/.well-known/ensoul-signing-key.pem")
        guard let text = String(data: data, encoding: .utf8) else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected UTF-8 text in signing-key response"
            )
        }
        return text
    }

    // MARK: - Private helpers

    /// Decode response `Data` as a top-level JSON object.
    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected JSON object in audit response"
            )
        }
        return dict
    }
}
