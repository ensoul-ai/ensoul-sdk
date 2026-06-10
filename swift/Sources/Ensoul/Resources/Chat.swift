/// Chat resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/personas/{personaId}/chat` and conversation endpoints.
///
/// Example — one-shot message:
/// ```swift
/// let response = try await client.chat.send(
///     personaId: "abc123",
///     message: "Hello!"
/// )
/// print(response.reply)
/// ```
///
/// Example — streaming:
/// ```swift
/// let stream = client.chat.stream(personaId: "abc123", message: "Hello!")
/// for try await event in stream {
///     print(event.data)
/// }
/// ```
import Foundation

// MARK: - Chat

@available(iOS 15.0, macOS 12.0, *)
public class Chat {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Send

    /// POST /v1/personas/{personaId}/chat
    ///
    /// Sends a message to a persona and returns its full reply.
    public func send(
        personaId: String,
        message: String,
        conversationId: String? = nil,
        userId: String? = nil,
        maxTokens: Int = 1024,
        temperature: Double = 1.0,
        includeMemories: Bool = true,
        includeKnowledge: Bool = true
    ) async throws -> ChatResponse {
        var body: [String: Any] = [
            "message": message,
            "max_tokens": maxTokens,
            "temperature": temperature,
            "include_memories": includeMemories,
            "include_knowledge": includeKnowledge,
        ]
        if let conversationId { body["conversation_id"] = conversationId }
        if let userId { body["user_id"] = userId }

        let (data, _) = try await client.post(
            "/v1/personas/\(personaId)/chat",
            body: body
        )
        let decoder = JSONDecoder()
        return try decoder.decode(ChatResponse.self, from: data)
    }

    // MARK: - Stream

    /// POST /v1/personas/{personaId}/chat/stream
    ///
    /// Begins a streaming chat session and returns an `SSEStream`. The stream is
    /// NOT async — the caller iterates it with `for try await event in stream { }`.
    ///
    /// - Note: This method is synchronous (non-throwing) because no network call
    ///   is made until the caller begins iterating the returned `SSEStream`.
    public func stream(
        personaId: String,
        message: String,
        conversationId: String? = nil,
        userId: String? = nil,
        maxTokens: Int = 1024,
        temperature: Double = 1.0,
        includeMemories: Bool = true,
        includeKnowledge: Bool = true
    ) -> SSEStream {
        var body: [String: Any] = [
            "message": message,
            "max_tokens": maxTokens,
            "temperature": temperature,
            "include_memories": includeMemories,
            "include_knowledge": includeKnowledge,
        ]
        if let conversationId { body["conversation_id"] = conversationId }
        if let userId { body["user_id"] = userId }

        return client.streamSSE(
            method: "POST",
            path: "/v1/personas/\(personaId)/chat/stream",
            body: body
        )
    }

    // MARK: - Get Conversations

    /// GET /v1/personas/{personaId}/conversations
    ///
    /// Returns a paginated list of past conversations for a persona.
    public func getConversations(
        personaId: String,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> Page<ConversationListItem> {
        let params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        let (data, _) = try await client.get(
            "/v1/personas/\(personaId)/conversations",
            params: params
        )
        return try Page.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas/\(personaId)/conversations",
            params: params
        )
    }

    // MARK: - Get Conversation

    /// GET /v1/personas/{personaId}/conversations/{conversationId}
    ///
    /// Returns the full message history for a single conversation.
    public func getConversation(
        personaId: String,
        conversationId: String
    ) async throws -> ConversationResponse {
        let (data, _) = try await client.get(
            "/v1/personas/\(personaId)/conversations/\(conversationId)"
        )
        let decoder = JSONDecoder()
        return try decoder.decode(ConversationResponse.self, from: data)
    }

    // MARK: - Chat sessions (persisted conversation history)

    /// POST /v1/chat/sessions
    public func createSession(
        teamId: String,
        userId: String,
        domainId: String,
        personaId: String? = nil,
        mode: String? = nil,
        participantPersonaIds: [String]? = nil,
        title: String? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = [
            "team_id": teamId,
            "user_id": userId,
            "domain_id": domainId,
        ]
        if let personaId { body["persona_id"] = personaId }
        if let mode { body["mode"] = mode }
        if let participantPersonaIds { body["participant_persona_ids"] = participantPersonaIds }
        if let title { body["title"] = title }

        let (data, _) = try await client.post("/v1/chat/sessions", body: body)
        return try Self.jsonObject(from: data)
    }

    /// GET /v1/chat/sessions
    public func listSessions(
        userId: String,
        mode: String? = nil,
        domainId: String? = nil,
        includeArchived: Bool? = nil,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> [String: Any] {
        var params: [String: String] = [
            "user_id": userId,
            "page": String(page),
            "per_page": String(perPage),
        ]
        if let mode { params["mode"] = mode }
        if let domainId { params["domain_id"] = domainId }
        if let includeArchived { params["include_archived"] = String(includeArchived) }

        let (data, _) = try await client.get("/v1/chat/sessions", params: params)
        return try Self.jsonObject(from: data)
    }

    /// GET /v1/chat/sessions/stats
    public func sessionStats(
        teamId: String,
        startDate: String,
        endDate: String
    ) async throws -> [String: Any] {
        let params: [String: String] = [
            "team_id": teamId,
            "start_date": startDate,
            "end_date": endDate,
        ]
        let (data, _) = try await client.get("/v1/chat/sessions/stats", params: params)
        return try Self.jsonObject(from: data)
    }

    /// GET /v1/chat/sessions/{sessionId}
    public func getSession(
        _ sessionId: String,
        userId: String? = nil
    ) async throws -> [String: Any] {
        var params: [String: String] = [:]
        if let userId { params["user_id"] = userId }

        let (data, _) = try await client.get(
            "/v1/chat/sessions/\(sessionId)",
            params: params.isEmpty ? nil : params
        )
        return try Self.jsonObject(from: data)
    }

    /// PATCH /v1/chat/sessions/{sessionId}
    public func updateSession(
        _ sessionId: String,
        title: String? = nil,
        isArchived: Bool? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = [:]
        if let title { body["title"] = title }
        if let isArchived { body["is_archived"] = isArchived }

        let (data, _) = try await client.patch(
            "/v1/chat/sessions/\(sessionId)",
            body: body
        )
        return try Self.jsonObject(from: data)
    }

    /// DELETE /v1/chat/sessions/{sessionId} — 204 No Content.
    public func deleteSession(_ sessionId: String) async throws {
        _ = try await client.delete("/v1/chat/sessions/\(sessionId)")
    }

    /// POST /v1/chat/sessions/{sessionId}/archive
    public func archiveSession(_ sessionId: String) async throws -> [String: Any] {
        let (data, _) = try await client.post(
            "/v1/chat/sessions/\(sessionId)/archive",
            body: [String: Any]()
        )
        return try Self.jsonObject(from: data)
    }

    /// POST /v1/chat/sessions/{sessionId}/messages
    public func addMessage(
        _ sessionId: String,
        role: String,
        content: String,
        inputTokens: Int? = nil,
        outputTokens: Int? = nil,
        modelUsed: String? = nil,
        metadata: [String: Any]? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = ["role": role, "content": content]
        if let inputTokens { body["input_tokens"] = inputTokens }
        if let outputTokens { body["output_tokens"] = outputTokens }
        if let modelUsed { body["model_used"] = modelUsed }
        if let metadata { body["metadata"] = metadata }

        let (data, _) = try await client.post(
            "/v1/chat/sessions/\(sessionId)/messages",
            body: body
        )
        return try Self.jsonObject(from: data)
    }

    /// GET /v1/chat/sessions/{sessionId}/messages — returns a bare JSON array.
    public func getMessages(
        _ sessionId: String,
        limit: Int? = nil,
        offset: Int? = nil
    ) async throws -> [[String: Any]] {
        var params: [String: String] = [:]
        if let limit { params["limit"] = String(limit) }
        if let offset { params["offset"] = String(offset) }

        let (data, _) = try await client.get(
            "/v1/chat/sessions/\(sessionId)/messages",
            params: params.isEmpty ? nil : params
        )
        return try Self.jsonArray(from: data)
    }

    // MARK: - Private helpers

    /// Decode response `Data` as a top-level JSON object.
    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected JSON object in chat response"
            )
        }
        return dict
    }

    /// Decode response `Data` as a top-level JSON array of objects.
    private static func jsonArray(from data: Data) throws -> [[String: Any]] {
        guard let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected JSON array in chat response"
            )
        }
        return arr
    }
}
