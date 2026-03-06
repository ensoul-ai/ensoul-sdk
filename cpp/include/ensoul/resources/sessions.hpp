#pragma once

#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"

namespace ensoul {

class SessionsResource {
public:
    explicit SessionsResource(IHttpTransport& transport) : transport_(transport) {}

    nlohmann::json create(const std::string& persona_id,
                           int tier = 0,
                           const std::string& parent_session_id = "",
                           const std::string& system_instructions = "",
                           const nlohmann::json& extras = nullptr) {
        nlohmann::json body = {{"tier", tier}};
        if (!parent_session_id.empty()) body["parent_session_id"] = parent_session_id;
        if (!system_instructions.empty()) body["system_instructions"] = system_instructions;
        if (extras.is_object()) {
            for (auto& [k, v] : extras.items()) body[k] = v;
        }
        auto resp = transport_.request("POST",
            "/v1/personas/" + persona_id + "/sessions", body);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json get(const std::string& persona_id, const std::string& session_id) {
        auto resp = transport_.request("GET",
            "/v1/personas/" + persona_id + "/sessions/" + session_id);
        return nlohmann::json::parse(resp.body);
    }

    Page<nlohmann::json> list(const std::string& persona_id,
                               int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET",
            "/v1/personas/" + persona_id + "/sessions", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);
        auto fetcher = [this, persona_id, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET",
                "/v1/personas/" + persona_id + "/sessions", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    nlohmann::json get_children(const std::string& persona_id,
                                 const std::string& session_id) {
        auto resp = transport_.request("GET",
            "/v1/personas/" + persona_id + "/sessions/" + session_id + "/children");
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json aggregate_children(const std::string& persona_id,
                                       const std::string& session_id,
                                       const std::string& aggregation_mode = "summary") {
        nlohmann::json body = {{"aggregation_mode", aggregation_mode}};
        auto resp = transport_.request("POST",
            "/v1/personas/" + persona_id + "/sessions/" + session_id + "/aggregate", body);
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
