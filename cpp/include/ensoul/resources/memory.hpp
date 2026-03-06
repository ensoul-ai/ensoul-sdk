#pragma once

#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"

namespace ensoul {

class MemoryResource {
public:
    explicit MemoryResource(IHttpTransport& transport) : transport_(transport) {}

    nlohmann::json create(const std::string& persona_id,
                           const std::string& content,
                           const std::string& memory_type = "episodic",
                           double importance = 0.5,
                           const nlohmann::json& metadata = nullptr) {
        nlohmann::json body = {
            {"content", content},
            {"memory_type", memory_type},
            {"importance", importance}
        };
        if (!metadata.is_null()) body["metadata"] = metadata;
        auto resp = transport_.request("POST",
            "/v1/personas/" + persona_id + "/memories", body);
        return nlohmann::json::parse(resp.body);
    }

    Page<nlohmann::json> list(const std::string& persona_id,
                               int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET",
            "/v1/personas/" + persona_id + "/memories", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);
        auto fetcher = [this, persona_id, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET",
                "/v1/personas/" + persona_id + "/memories", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    nlohmann::json get(const std::string& persona_id, const std::string& memory_id) {
        auto resp = transport_.request("GET",
            "/v1/personas/" + persona_id + "/memories/" + memory_id);
        return nlohmann::json::parse(resp.body);
    }

    void delete_(const std::string& persona_id, const std::string& memory_id) {
        transport_.request("DELETE",
            "/v1/personas/" + persona_id + "/memories/" + memory_id);
    }

    nlohmann::json batch_create(const std::string& persona_id,
                                 const nlohmann::json& memories) {
        nlohmann::json body = {{"memories", memories}};
        auto resp = transport_.request("POST",
            "/v1/personas/" + persona_id + "/memories/batch", body);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json consolidate(const std::string& persona_id) {
        auto resp = transport_.request("POST",
            "/v1/personas/" + persona_id + "/memories/consolidate",
            nlohmann::json::object());
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json query_knowledge(const std::string& persona_id,
                                    const std::string& query_str) {
        nlohmann::json body = {{"query", query_str}};
        auto resp = transport_.request("POST",
            "/v1/personas/" + persona_id + "/knowledge/query", body);
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
