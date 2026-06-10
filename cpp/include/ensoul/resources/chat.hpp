#pragma once

#include <string>
#include <map>
#include <optional>
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

    // -- Chat sessions (persisted conversation history) --------------------

    // POST /v1/chat/sessions
    nlohmann::json create_session(const std::string& team_id,
                                  const std::string& user_id,
                                  const std::string& domain_id,
                                  const std::string& persona_id = "",
                                  const std::string& mode = "",
                                  const nlohmann::json& participant_persona_ids = nullptr,
                                  const std::string& title = "") {
        nlohmann::json body = {
            {"team_id", team_id},
            {"user_id", user_id},
            {"domain_id", domain_id}
        };
        if (!persona_id.empty()) body["persona_id"] = persona_id;
        if (!mode.empty()) body["mode"] = mode;
        if (!participant_persona_ids.is_null())
            body["participant_persona_ids"] = participant_persona_ids;
        if (!title.empty()) body["title"] = title;
        auto resp = transport_.request("POST", "/v1/chat/sessions", body);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/chat/sessions
    nlohmann::json list_sessions(const std::string& user_id,
                                 const std::string& mode = "",
                                 const std::string& domain_id = "",
                                 std::optional<bool> include_archived = std::nullopt,
                                 int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"user_id", user_id},
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        if (!mode.empty()) params["mode"] = mode;
        if (!domain_id.empty()) params["domain_id"] = domain_id;
        if (include_archived) params["include_archived"] = *include_archived ? "true" : "false";
        auto resp = transport_.request("GET", "/v1/chat/sessions", nullptr, params);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/chat/sessions/stats
    nlohmann::json session_stats(const std::string& team_id,
                                 const std::string& start_date,
                                 const std::string& end_date) {
        std::map<std::string, std::string> params = {
            {"team_id", team_id},
            {"start_date", start_date},
            {"end_date", end_date}
        };
        auto resp = transport_.request("GET", "/v1/chat/sessions/stats", nullptr, params);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/chat/sessions/{session_id}
    nlohmann::json get_session(const std::string& session_id,
                               const std::string& user_id = "") {
        std::map<std::string, std::string> params;
        if (!user_id.empty()) params["user_id"] = user_id;
        auto resp = transport_.request("GET",
            "/v1/chat/sessions/" + session_id, nullptr, params);
        return nlohmann::json::parse(resp.body);
    }

    // PATCH /v1/chat/sessions/{session_id}
    nlohmann::json update_session(const std::string& session_id,
                                  const std::string& title = "",
                                  std::optional<bool> is_archived = std::nullopt) {
        nlohmann::json body = nlohmann::json::object();
        if (!title.empty()) body["title"] = title;
        if (is_archived) body["is_archived"] = *is_archived;
        auto resp = transport_.request("PATCH",
            "/v1/chat/sessions/" + session_id, body);
        return nlohmann::json::parse(resp.body);
    }

    // DELETE /v1/chat/sessions/{session_id} — 204 No Content.
    void delete_session(const std::string& session_id) {
        transport_.request("DELETE", "/v1/chat/sessions/" + session_id);
    }

    // POST /v1/chat/sessions/{session_id}/archive
    nlohmann::json archive_session(const std::string& session_id) {
        auto resp = transport_.request("POST",
            "/v1/chat/sessions/" + session_id + "/archive",
            nlohmann::json::object());
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/chat/sessions/{session_id}/messages
    nlohmann::json add_message(const std::string& session_id,
                               const std::string& role,
                               const std::string& content,
                               std::optional<int> input_tokens = std::nullopt,
                               std::optional<int> output_tokens = std::nullopt,
                               const std::string& model_used = "",
                               const nlohmann::json& metadata = nullptr) {
        nlohmann::json body = {{"role", role}, {"content", content}};
        if (input_tokens) body["input_tokens"] = *input_tokens;
        if (output_tokens) body["output_tokens"] = *output_tokens;
        if (!model_used.empty()) body["model_used"] = model_used;
        if (!metadata.is_null()) body["metadata"] = metadata;
        auto resp = transport_.request("POST",
            "/v1/chat/sessions/" + session_id + "/messages", body);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/chat/sessions/{session_id}/messages — bare JSON array.
    nlohmann::json get_messages(const std::string& session_id,
                                std::optional<int> limit = std::nullopt,
                                std::optional<int> offset = std::nullopt) {
        std::map<std::string, std::string> params;
        if (limit) params["limit"] = std::to_string(*limit);
        if (offset) params["offset"] = std::to_string(*offset);
        auto resp = transport_.request("GET",
            "/v1/chat/sessions/" + session_id + "/messages", nullptr, params);
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
