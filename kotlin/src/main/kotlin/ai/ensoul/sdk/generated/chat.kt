/**
 * Generated models for chat resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */
package ai.ensoul.sdk.generated

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/** Token usage statistics. */
@Serializable
data class TokenUsage(
    @SerialName("input_tokens") val inputTokens: Int,
    @SerialName("output_tokens") val outputTokens: Int,
    @SerialName("total_tokens") val totalTokens: Int,
)

/** Request to send a chat message to a persona. */
@Serializable
data class ChatRequest(
    val message: String,
    @SerialName("conversation_id") val conversationId: String? = null,
    @SerialName("user_id") val userId: String? = null,
    @SerialName("max_tokens") val maxTokens: Int? = 1024,
    val temperature: Double? = 1.0,
    @SerialName("include_memories") val includeMemories: Boolean = true,
    @SerialName("include_knowledge") val includeKnowledge: Boolean = true,
)

/** Response from chat message. */
@Serializable
data class ChatResponse(
    val response: String,
    @SerialName("conversation_id") val conversationId: String,
    @SerialName("token_usage") val tokenUsage: TokenUsage,
    @SerialName("latency_ms") val latencyMs: Int,
    val model: String,
    val timestamp: String? = null,
)

/** A single message in a conversation. */
@Serializable
data class ConversationMessage(
    val role: String,
    val content: String,
    val timestamp: String,
)

/** Complete conversation history with messages. */
@Serializable
data class ConversationResponse(
    @SerialName("conversation_id") val conversationId: String,
    @SerialName("persona_id") val personaId: String,
    val messages: List<ConversationMessage>,
    @SerialName("created_at") val createdAt: String,
    @SerialName("updated_at") val updatedAt: String,
    @SerialName("message_count") val messageCount: Int,
    @SerialName("total_tokens") val totalTokens: Int = 0,
)

/** Summary item for conversation list. */
@Serializable
data class ConversationListItem(
    @SerialName("conversation_id") val conversationId: String,
    @SerialName("persona_id") val personaId: String,
    @SerialName("created_at") val createdAt: String,
    @SerialName("updated_at") val updatedAt: String,
    @SerialName("message_count") val messageCount: Int,
    val preview: String? = null,
)

/** Paginated list of conversations for a persona. */
@Serializable
data class ConversationListResponse(
    val items: List<ConversationListItem>,
    val total: Int,
    val page: Int = 1,
    @SerialName("per_page") val perPage: Int = 20,
    val pages: Int = 1,
    @SerialName("persona_id") val personaId: String,
)
