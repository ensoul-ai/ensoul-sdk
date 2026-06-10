#pragma once

#include <string>
#include <map>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"

namespace ensoul {

// Sessions resource — hierarchical session orchestration under /v1/sessions/*.
//
// As of API 0.2.0 these routes are no longer nested under a persona: a session
// is created against the authenticated team/user context, so create() no longer
// takes a persona_id (the SessionCreate body has no persona field). This is a
// distinct family from /v1/chat/sessions (chat-message threads).
class SessionsResource {
public:
    explicit SessionsResource(IHttpTransport& transport) : transport_(transport) {}

    // POST /v1/sessions — create a session (SessionCreate).
    nlohmann::json create(int tier = 0,
                           const std::string& parent_session_id = "",
                           const std::string& system_instructions = "",
                           const nlohmann::json& extras = nullptr) {
        nlohmann::json body = {{"tier", tier}};
        if (!parent_session_id.empty()) body["parent_session_id"] = parent_session_id;
        if (!system_instructions.empty()) body["system_instructions"] = system_instructions;
        if (extras.is_object()) {
            for (auto& [k, v] : extras.items()) body[k] = v;
        }
        auto resp = transport_.request("POST", "/v1/sessions", body);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/sessions/{session_id}
    nlohmann::json get(const std::string& session_id) {
        auto resp = transport_.request("GET", "/v1/sessions/" + session_id);
        return nlohmann::json::parse(resp.body);
    }

    // DELETE /v1/sessions/{session_id}
    void delete_(const std::string& session_id, bool cancel_children = false) {
        std::string suffix = std::string("?cancel_children=")
                           + (cancel_children ? "true" : "false");
        transport_.request("DELETE", "/v1/sessions/" + session_id + suffix);
    }

    // GET /v1/sessions — list sessions (paginated).
    Page<nlohmann::json> list(std::optional<int> tier = std::nullopt,
                               const std::string& status = "",
                               const std::string& parent_session_id = "",
                               int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        if (tier) params["tier"] = std::to_string(*tier);
        if (!status.empty()) params["status"] = status;
        if (!parent_session_id.empty()) params["parent_session_id"] = parent_session_id;
        auto resp = transport_.request("GET", "/v1/sessions", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);
        auto fetcher = [this, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET", "/v1/sessions", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    // GET /v1/sessions/hierarchy — full session tree.
    nlohmann::json hierarchy() {
        auto resp = transport_.request("GET", "/v1/sessions/hierarchy");
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/sessions/info — session-system info.
    nlohmann::json info() {
        auto resp = transport_.request("GET", "/v1/sessions/info");
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/sessions/stats/summary — session statistics.
    nlohmann::json stats() {
        auto resp = transport_.request("GET", "/v1/sessions/stats/summary");
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/sessions/{session_id}/children
    nlohmann::json get_children(const std::string& session_id,
                                 int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET",
            "/v1/sessions/" + session_id + "/children", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);
        if (data.is_array()) return data;
        if (data.is_object() && data.contains("items")) return data["items"];
        return data;
    }

    // POST /v1/sessions/{session_id}/aggregate (AggregateChildrenRequest).
    nlohmann::json aggregate_children(const std::string& session_id,
                                       const std::string& aggregation_mode = "summary") {
        nlohmann::json body = {{"aggregation_mode", aggregation_mode}};
        auto resp = transport_.request("POST",
            "/v1/sessions/" + session_id + "/aggregate", body);
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
