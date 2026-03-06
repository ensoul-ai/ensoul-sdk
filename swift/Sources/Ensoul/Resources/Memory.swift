/// Memory resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/personas/{personaId}/memories` and
/// `/v1/personas/{personaId}/knowledge` endpoints.
///
/// Example:
/// ```swift
/// let memory = try await client.memory.create(
///     personaId: "abc123",
///     content: "Attended the company all-hands meeting.",
///     memoryType: "episodic",
///     importance: 0.7
/// )
/// ```
import Foundation

// MARK: - Memory

@available(iOS 15.0, macOS 12.0, *)
public class Memory {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Create

    /// POST /v1/personas/{personaId}/memories
    ///
    /// Creates a new memory for a persona. The `memoryType` controls how the
    /// server stores and retrieves this memory (e.g. `"episodic"`, `"semantic"`).
    public func create(
        personaId: String,
        content: String,
        memoryType: String = "episodic",
        importance: Double = 0.5,
        metadata: [String: Any]? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = [
            "content": content,
            "memory_type": memoryType,
            "importance": importance,
        ]
        if let metadata { body["metadata"] = metadata }

        let (data, _) = try await client.post(
            "/v1/personas/\(personaId)/memories",
            body: body
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - List

    /// GET /v1/personas/{personaId}/memories
    ///
    /// Returns a paginated page of memories for a persona.
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
            "/v1/personas/\(personaId)/memories",
            params: params
        )
        return try RawPage.from(data: data)
    }

    // MARK: - Get

    /// GET /v1/personas/{personaId}/memories/{memoryId}
    public func get(personaId: String, memoryId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get(
            "/v1/personas/\(personaId)/memories/\(memoryId)"
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Delete

    /// DELETE /v1/personas/{personaId}/memories/{memoryId}
    public func delete(personaId: String, memoryId: String) async throws {
        _ = try await client.delete("/v1/personas/\(personaId)/memories/\(memoryId)")
    }

    // MARK: - Batch Create

    /// POST /v1/personas/{personaId}/memories/batch
    ///
    /// Creates multiple memories for a persona in a single request.
    /// Each element in `memories` should be a dict matching the single-create
    /// body shape (keys: `content`, `memory_type`, `importance`, `metadata`).
    public func batchCreate(
        personaId: String,
        memories: [[String: Any]]
    ) async throws -> [String: Any] {
        let body: [String: Any] = ["memories": memories]
        let (data, _) = try await client.post(
            "/v1/personas/\(personaId)/memories/batch",
            body: body
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Consolidate

    /// POST /v1/personas/{personaId}/memories/consolidate
    ///
    /// Triggers server-side memory consolidation for a persona — merging
    /// overlapping episodic memories into semantic knowledge entries.
    public func consolidate(personaId: String) async throws -> [String: Any] {
        let (data, _) = try await client.post(
            "/v1/personas/\(personaId)/memories/consolidate",
            body: [String: Any]()
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Query Knowledge

    /// POST /v1/personas/{personaId}/knowledge/query
    ///
    /// Queries the persona's consolidated knowledge graph with a natural-language
    /// query and returns the most relevant knowledge entries.
    public func queryKnowledge(personaId: String, query: String) async throws -> [String: Any] {
        let body: [String: Any] = ["query": query]
        let (data, _) = try await client.post(
            "/v1/personas/\(personaId)/knowledge/query",
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
                message: "Expected a JSON object in memory response"
            )
        }
        return dict
    }
}
