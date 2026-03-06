// Generated models for the chat resource group.
// DO NOT EDIT — regenerate with: make sdk-regen
using System.Collections.Generic;
using Newtonsoft.Json;

namespace Ensoul
{
    public class TokenUsage
    {
        [JsonProperty("input_tokens")] public int InputTokens { get; set; }
        [JsonProperty("output_tokens")] public int OutputTokens { get; set; }
        [JsonProperty("total_tokens")] public int TotalTokens { get; set; }
    }

    public class ChatResponse
    {
        [JsonProperty("response")] public string Response { get; set; } = "";
        [JsonProperty("conversation_id")] public string ConversationId { get; set; } = "";
        [JsonProperty("token_usage")] public TokenUsage TokenUsage { get; set; } = new();
        [JsonProperty("latency_ms")] public int LatencyMs { get; set; }
        [JsonProperty("model")] public string Model { get; set; } = "";
        [JsonProperty("timestamp")] public string? Timestamp { get; set; }
    }

    public class ConversationMessage
    {
        [JsonProperty("role")] public string Role { get; set; } = "";
        [JsonProperty("content")] public string Content { get; set; } = "";
        [JsonProperty("timestamp")] public string Timestamp { get; set; } = "";
    }

    public class ConversationResponse
    {
        [JsonProperty("conversation_id")] public string ConversationId { get; set; } = "";
        [JsonProperty("persona_id")] public string PersonaId { get; set; } = "";
        [JsonProperty("messages")] public List<ConversationMessage> Messages { get; set; } = new();
        [JsonProperty("created_at")] public string CreatedAt { get; set; } = "";
        [JsonProperty("updated_at")] public string UpdatedAt { get; set; } = "";
        [JsonProperty("message_count")] public int MessageCount { get; set; }
        [JsonProperty("total_tokens")] public int TotalTokens { get; set; }
    }

    public class ConversationListItem
    {
        [JsonProperty("conversation_id")] public string ConversationId { get; set; } = "";
        [JsonProperty("persona_id")] public string PersonaId { get; set; } = "";
        [JsonProperty("created_at")] public string CreatedAt { get; set; } = "";
        [JsonProperty("updated_at")] public string UpdatedAt { get; set; } = "";
        [JsonProperty("message_count")] public int MessageCount { get; set; }
        [JsonProperty("preview")] public string? Preview { get; set; }
    }
}
