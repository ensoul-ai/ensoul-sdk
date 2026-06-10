/// Memory resource for the Ensoul Swift SDK.
///
/// Wraps the `/v1/memory/*` endpoints. As of API 0.2.0 these routes were
/// rebased off `/v1/personas/{id}/memories` onto `/v1/memory/{personaId}`.
/// See `sdks/openapi/namespace-migration-contract.md`.
///
/// Example:
/// ```swift
/// let memory = try await client.memory.create(
///     personaId: "abc123",
///     content: "Attended the company all-hands meeting."
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

    // MARK: - Stats

    /// GET /v1/memory/stats — global memory statistics.
    public func stats() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/memory/stats")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Create

    /// POST /v1/memory/{personaId} — add a memory (`MemoryCreate`).
    public func create(
        personaId: String,
        content: String,
        source: String = "user",
        references: [String: Any]? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = [
            "content": content,
            "source": source,
        ]
        if let references { body["references"] = references }

        let (data, _) = try await client.post("/v1/memory/\(personaId)", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - List

    /// GET /v1/memory/{personaId} — list memories.
    ///
    /// Returns the `MemoriesResponse` shape
    /// `{ persona_id, memories, working_memory, total }` (not a paginated
    /// envelope — the API does not page this route).
    public func list(
        personaId: String,
        limit: Int = 50,
        offset: Int = 0
    ) async throws -> [String: Any] {
        let params: [String: String] = [
            "limit": String(limit),
            "offset": String(offset),
        ]
        let (data, _) = try await client.get("/v1/memory/\(personaId)", params: params)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Clear

    /// DELETE /v1/memory/{personaId} — delete all memories for a persona.
    public func clear(personaId: String) async throws {
        _ = try await client.delete("/v1/memory/\(personaId)")
    }

    // MARK: - Delete

    /// DELETE /v1/memory/{personaId}/{memoryId} — delete one memory.
    public func delete(personaId: String, memoryId: String) async throws {
        _ = try await client.delete("/v1/memory/\(personaId)/\(memoryId)")
    }

    // MARK: - Update Access

    /// PATCH /v1/memory/{personaId}/{memoryId}/access — record an access.
    public func updateAccess(personaId: String, memoryId: String) async throws -> [String: Any] {
        let (data, _) = try await client.patch(
            "/v1/memory/\(personaId)/\(memoryId)/access",
            body: [String: Any]()
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Batch Create

    /// POST /v1/memory/{personaId}/batch — add many memories at once.
    public func batchCreate(
        personaId: String,
        memories: [[String: Any]]
    ) async throws -> [String: Any] {
        let body: [String: Any] = ["memories": memories]
        let (data, _) = try await client.post("/v1/memory/\(personaId)/batch", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Consolidate

    /// POST /v1/memory/{personaId}/consolidate — consolidate memories.
    public func consolidate(personaId: String) async throws -> [String: Any] {
        let (data, _) = try await client.post(
            "/v1/memory/\(personaId)/consolidate",
            body: [String: Any]()
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Generate

    /// POST /v1/memory/{personaId}/generate — generate memories.
    public func generate(personaId: String, options: [String: Any] = [:]) async throws -> [String: Any] {
        let (data, _) = try await client.post("/v1/memory/\(personaId)/generate", body: options)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Working

    /// GET /v1/memory/{personaId}/working — working-memory snapshot.
    public func working(personaId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/memory/\(personaId)/working")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Knowledge

    /// GET /v1/memory/{personaId}/knowledge — retrieve RAG knowledge.
    public func getKnowledge(personaId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/memory/\(personaId)/knowledge")
        return try Self.jsonObject(from: data)
    }

    /// POST /v1/memory/{personaId}/knowledge — add RAG knowledge (`KnowledgeCreate`).
    public func addKnowledge(
        personaId: String,
        content: String,
        source: String
    ) async throws -> [String: Any] {
        let body: [String: Any] = ["content": content, "source": source]
        let (data, _) = try await client.post("/v1/memory/\(personaId)/knowledge", body: body)
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
