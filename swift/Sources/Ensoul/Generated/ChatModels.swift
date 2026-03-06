/// Generated models for the chat resource group.
/// DO NOT EDIT — regenerate with: make sdk-regen
import Foundation

// MARK: - Token usage

/// Token consumption statistics for a single inference call.
public struct TokenUsage: Codable, Sendable {
    public let inputTokens: Int
    public let outputTokens: Int
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Chat request / response

/// Request to send a chat message to a persona.
public struct ChatRequest: Codable, Sendable {
    /// User message to send.
    public let message: String
    /// Conversation ID to continue; `nil` starts a new conversation.
    public let conversationId: String?
    /// User ID for memory isolation.
    public let userId: String?
    /// Maximum tokens in the response (1–4096).
    public let maxTokens: Int?
    /// Sampling temperature (0.0–2.0).
    public let temperature: Double?
    /// Whether to include long-term memories in context.
    public let includeMemories: Bool
    /// Whether to include RAG knowledge in context.
    public let includeKnowledge: Bool

    public init(
        message: String,
        conversationId: String? = nil,
        userId: String? = nil,
        maxTokens: Int? = 1024,
        temperature: Double? = 1.0,
        includeMemories: Bool = true,
        includeKnowledge: Bool = true
    ) {
        self.message = message
        self.conversationId = conversationId
        self.userId = userId
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.includeMemories = includeMemories
        self.includeKnowledge = includeKnowledge
    }

    enum CodingKeys: String, CodingKey {
        case message
        case conversationId = "conversation_id"
        case userId = "user_id"
        case maxTokens = "max_tokens"
        case temperature
        case includeMemories = "include_memories"
        case includeKnowledge = "include_knowledge"
    }
}

/// Response from a single chat message.
public struct ChatResponse: Codable, Sendable {
    public let response: String
    public let conversationId: String
    public let tokenUsage: TokenUsage
    public let latencyMs: Int
    public let model: String
    /// ISO-8601 response timestamp.
    public let timestamp: String?

    enum CodingKeys: String, CodingKey {
        case response
        case conversationId = "conversation_id"
        case tokenUsage = "token_usage"
        case latencyMs = "latency_ms"
        case model
        case timestamp
    }
}

// MARK: - Conversation history

/// A single message in a conversation thread.
public struct ConversationMessage: Codable, Sendable {
    /// Either `"user"` or `"assistant"`.
    public let role: String
    public let content: String
    /// ISO-8601 message timestamp.
    public let timestamp: String

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case timestamp
    }
}

/// Complete conversation history including all messages.
public struct ConversationResponse: Codable, Sendable {
    public let conversationId: String
    public let personaId: String
    public let messages: [ConversationMessage]
    public let createdAt: String
    public let updatedAt: String
    public let messageCount: Int
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case personaId = "persona_id"
        case messages
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case messageCount = "message_count"
        case totalTokens = "total_tokens"
    }
}

/// Summary item for a conversation list.
public struct ConversationListItem: Codable, Sendable {
    public let conversationId: String
    public let personaId: String
    public let createdAt: String
    public let updatedAt: String
    public let messageCount: Int
    /// Preview of the first user message.
    public let preview: String?

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case personaId = "persona_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case messageCount = "message_count"
        case preview
    }
}

/// Paginated list of conversations for a persona.
public struct ConversationListResponse: Codable, Sendable {
    public let items: [ConversationListItem]
    public let total: Int
    public let page: Int
    public let perPage: Int
    public let pages: Int
    public let personaId: String

    enum CodingKeys: String, CodingKey {
        case items
        case total
        case page
        case perPage = "per_page"
        case pages
        case personaId = "persona_id"
    }
}
