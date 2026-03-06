/// Sessions resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/personas/{personaId}/sessions` endpoints.
///
/// Sessions model hierarchical reasoning: a parent session can spawn child
/// sessions that are later aggregated into a synthesised result.
///
/// Example:
/// ```swift
/// let session = try await client.sessions.create(
///     personaId: "abc123",
///     tier: 1,
///     systemInstructions: "Focus on pricing strategy."
/// )
/// let children = try await client.sessions.getChildren(
///     personaId: "abc123",
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

    /// POST /v1/personas/{personaId}/sessions
    ///
    /// Creates a new session for the persona. Use `tier` to control reasoning
    /// depth (0 = fast/shallow, higher = slower/deeper). Supply
    /// `parentSessionId` to create a child session within an existing tree.
    public func create(
        personaId: String,
        tier: Int = 0,
        parentSessionId: String? = nil,
        systemInstructions: String? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = ["tier": tier]
        if let parentSessionId { body["parent_session_id"] = parentSessionId }
        if let systemInstructions { body["system_instructions"] = systemInstructions }

        let (data, _) = try await client.post(
            "/v1/personas/\(personaId)/sessions",
            body: body
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Get

    /// GET /v1/personas/{personaId}/sessions/{sessionId}
    public func get(personaId: String, sessionId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get(
            "/v1/personas/\(personaId)/sessions/\(sessionId)"
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - List

    /// GET /v1/personas/{personaId}/sessions
    ///
    /// Returns a paginated list of sessions for a persona.
    public func list(
        personaId: String,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> RawPage {
        let params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        let (data, _) = try await client.get(
            "/v1/personas/\(personaId)/sessions",
            params: params
        )
        return try RawPage.from(data: data)
    }

    // MARK: - Get Children

    /// GET /v1/personas/{personaId}/sessions/{sessionId}/children
    ///
    /// Returns all direct child sessions for the given session as raw JSON
    /// dictionaries (schema is domain-specific).
    public func getChildren(
        personaId: String,
        sessionId: String
    ) async throws -> [[String: Any]] {
        let (data, _) = try await client.get(
            "/v1/personas/\(personaId)/sessions/\(sessionId)/children"
        )
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

    /// POST /v1/personas/{personaId}/sessions/{sessionId}/aggregate
    ///
    /// Aggregates all child sessions of the given session into a synthesised
    /// result using the specified `aggregationMode` (e.g. `"summary"`,
    /// `"vote"`, `"weighted"`).
    public func aggregateChildren(
        personaId: String,
        sessionId: String,
        aggregationMode: String = "summary"
    ) async throws -> [String: Any] {
        let body: [String: Any] = ["aggregation_mode": aggregationMode]
        let (data, _) = try await client.post(
            "/v1/personas/\(personaId)/sessions/\(sessionId)/aggregate",
            body: body
        )
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
