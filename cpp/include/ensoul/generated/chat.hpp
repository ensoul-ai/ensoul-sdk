#pragma once

#include <string>
#include <vector>
#include <optional>
#include <nlohmann/json.hpp>

namespace ensoul {

struct TokenUsage {
    int input_tokens = 0;
    int output_tokens = 0;
    int total_tokens = 0;
};

inline void from_json(const nlohmann::json& j, TokenUsage& t) {
    t.input_tokens = j.value("input_tokens", 0);
    t.output_tokens = j.value("output_tokens", 0);
    t.total_tokens = j.value("total_tokens", 0);
}

struct ChatResponse {
    std::string response;
    std::string conversation_id;
    TokenUsage token_usage;
    int latency_ms = 0;
    std::string model;
    std::optional<std::string> timestamp;
};

inline void from_json(const nlohmann::json& j, ChatResponse& c) {
    j.at("response").get_to(c.response);
    j.at("conversation_id").get_to(c.conversation_id);
    c.token_usage = j.at("token_usage").get<TokenUsage>();
    c.latency_ms = j.value("latency_ms", 0);
    c.model = j.value("model", std::string(""));
    if (j.contains("timestamp") && !j["timestamp"].is_null())
        c.timestamp = j["timestamp"].get<std::string>();
}

struct ConversationMessage {
    std::string role;
    std::string content;
    std::string timestamp;
};

inline void from_json(const nlohmann::json& j, ConversationMessage& m) {
    j.at("role").get_to(m.role);
    j.at("content").get_to(m.content);
    j.at("timestamp").get_to(m.timestamp);
}

struct ConversationResponse {
    std::string conversation_id;
    std::string persona_id;
    std::vector<ConversationMessage> messages;
    std::string created_at;
    std::string updated_at;
    int message_count = 0;
    int total_tokens = 0;
};

inline void from_json(const nlohmann::json& j, ConversationResponse& c) {
    j.at("conversation_id").get_to(c.conversation_id);
    j.at("persona_id").get_to(c.persona_id);
    c.messages = j.at("messages").get<std::vector<ConversationMessage>>();
    j.at("created_at").get_to(c.created_at);
    j.at("updated_at").get_to(c.updated_at);
    c.message_count = j.value("message_count", 0);
    c.total_tokens = j.value("total_tokens", 0);
}

struct ConversationListItem {
    std::string conversation_id;
    std::string persona_id;
    std::string created_at;
    std::string updated_at;
    int message_count = 0;
    std::optional<std::string> preview;
};

inline void from_json(const nlohmann::json& j, ConversationListItem& c) {
    j.at("conversation_id").get_to(c.conversation_id);
    j.at("persona_id").get_to(c.persona_id);
    j.at("created_at").get_to(c.created_at);
    j.at("updated_at").get_to(c.updated_at);
    c.message_count = j.value("message_count", 0);
    if (j.contains("preview") && !j["preview"].is_null())
        c.preview = j["preview"].get<std::string>();
}

} // namespace ensoul
