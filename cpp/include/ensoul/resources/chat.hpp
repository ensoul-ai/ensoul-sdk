#pragma once

#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"
#include "ensoul/streaming.hpp"
#include "ensoul/generated/chat.hpp"

namespace ensoul {

class ChatResource {
public:
    explicit ChatResource(IHttpTransport& transport) : transport_(transport) {}

    ChatResponse send(const std::string& persona_id,
                      const std::string& message,
                      const std::string& conversation_id = "",
                      const std::string& user_id = "",
                      int max_tokens = 1024,
                      double temperature = 1.0,
                      bool include_memories = true,
                      bool include_knowledge = true) {
        nlohmann::json body = {
            {"message", message},
            {"max_tokens", max_tokens},
            {"temperature", temperature},
            {"include_memories", include_memories},
            {"include_knowledge", include_knowledge}
        };
        if (!conversation_id.empty()) body["conversation_id"] = conversation_id;
        if (!user_id.empty()) body["user_id"] = user_id;
        auto resp = transport_.request("POST", "/v1/personas/" + persona_id + "/chat", body);
        return nlohmann::json::parse(resp.body).get<ChatResponse>();
    }

    SseStream stream(const std::string& persona_id,
                     const std::string& message,
                     const nlohmann::json& extras = nullptr) {
        nlohmann::json body = {{"message", message}};
        if (extras.is_object()) {
            for (auto& [k, v] : extras.items()) body[k] = v;
        }
        auto raw = transport_.stream_sse_raw("POST",
            "/v1/personas/" + persona_id + "/chat/stream", body);
        return SseStream(raw);
    }

    Page<ConversationListItem> get_conversations(const std::string& persona_id,
                                                  int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET",
            "/v1/personas/" + persona_id + "/conversations", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);

        auto fetcher = [this, persona_id, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET",
                "/v1/personas/" + persona_id + "/conversations", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> ConversationListItem {
            return j.get<ConversationListItem>();
        };
        return Page<ConversationListItem>::from_json(data, fetcher, deserializer);
    }

    ConversationResponse get_conversation(const std::string& persona_id,
                                           const std::string& conversation_id) {
        auto resp = transport_.request("GET",
            "/v1/personas/" + persona_id + "/conversations/" + conversation_id);
        return nlohmann::json::parse(resp.body).get<ConversationResponse>();
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
