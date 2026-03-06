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
}
