/// Sessions resource for the Ensoul Swift SDK.
///
/// Hierarchical session orchestration under `/v1/sessions/*`. As of API 0.2.0
/// these routes are no longer nested under a persona: a session is created
/// against the authenticated team/user context, so `create` no longer takes a
/// `personaId` (the `SessionCreate` body has no persona field). This is a
/// distinct family from `/v1/chat/sessions` (chat-message threads). See
/// `sdks/openapi/namespace-migration-contract.md`.
///
/// Example:
/// ```swift
/// let session = try await client.sessions.create(
///     tier: 1,
///     systemInstructions: "Focus on pricing strategy."
/// )
/// let children = try await client.sessions.getChildren(
///     sessionId: session["id"] as! String
/// )
/// ```
import Foundation

// MARK: - Sessions

@available(iOS 15.0, macOS 12.0, *)
public class Sessions {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Create

    /// POST /v1/sessions — create a session (`SessionCreate`).
    ///
    /// Use `tier` to control reasoning depth (0 = fast/shallow, higher =
    /// slower/deeper). Supply `parentSessionId` to create a child session.
    public func create(
        tier: Int = 0,
        parentSessionId: String? = nil,
        systemInstructions: String? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = ["tier": tier]
        if let parentSessionId { body["parent_session_id"] = parentSessionId }
        if let systemInstructions { body["system_instructions"] = systemInstructions }

        let (data, _) = try await client.post("/v1/sessions", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Get

    /// GET /v1/sessions/{sessionId}
    public func get(sessionId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/sessions/\(sessionId)")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Delete

    /// DELETE /v1/sessions/{sessionId}
    public func delete(sessionId: String, cancelChildren: Bool = false) async throws {
        _ = try await client.delete(
            "/v1/sessions/\(sessionId)?cancel_children=\(cancelChildren ? "true" : "false")"
        )
    }

    // MARK: - List

    /// GET /v1/sessions — list sessions (paginated).
    public func list(
        tier: Int? = nil,
        status: String? = nil,
        parentSessionId: String? = nil,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> RawPage {
        var params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        if let tier { params["tier"] = String(tier) }
        if let status { params["status"] = status }
        if let parentSessionId { params["parent_session_id"] = parentSessionId }

        let (data, _) = try await client.get("/v1/sessions", params: params)
        return try RawPage.from(data: data)
    }

    // MARK: - Hierarchy / Info / Stats

    /// GET /v1/sessions/hierarchy — full session tree.
    public func hierarchy() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/sessions/hierarchy")
        return try Self.jsonObject(from: data)
    }

    /// GET /v1/sessions/info — session-system info.
    public func info() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/sessions/info")
        return try Self.jsonObject(from: data)
    }

    /// GET /v1/sessions/stats/summary — session statistics.
    public func stats() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/sessions/stats/summary")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Get Children

    /// GET /v1/sessions/{sessionId}/children
    public func getChildren(
        sessionId: String,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> [[String: Any]] {
        let params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        let (data, _) = try await client.get("/v1/sessions/\(sessionId)/children", params: params)
        // The server may return a bare array or a wrapped object.
        if let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return array
        }
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let items = dict["items"] as? [[String: Any]] {
            return items
        }
        throw EnsoulAPIError(
            statusCode: 200,
            error: "ParseError",
            message: "Expected a JSON array or paginated object for session children"
        )
    }

    // MARK: - Aggregate Children

    /// POST /v1/sessions/{sessionId}/aggregate (`AggregateChildrenRequest`).
    public func aggregateChildren(
        sessionId: String,
        aggregationMode: String = "summary"
    ) async throws -> [String: Any] {
        let body: [String: Any] = ["aggregation_mode": aggregationMode]
        let (data, _) = try await client.post("/v1/sessions/\(sessionId)/aggregate", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Private helpers

    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected a JSON object in session response"
            )
        }
        return dict
    }
}
