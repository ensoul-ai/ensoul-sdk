#pragma once

#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"

namespace ensoul {

class DomainsResource {
public:
    explicit DomainsResource(IHttpTransport& transport) : transport_(transport) {}

    Page<nlohmann::json> list(int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET", "/v1/domains", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);

        auto fetcher = [this, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET", "/v1/domains", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    nlohmann::json get(const std::string& domain_id) {
        auto resp = transport_.request("GET", "/v1/domains/" + domain_id);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json create(const nlohmann::json& body) {
        auto resp = transport_.request("POST", "/v1/domains", body);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json update(const std::string& domain_id, const nlohmann::json& body) {
        auto resp = transport_.request("PUT", "/v1/domains/" + domain_id, body);
        return nlohmann::json::parse(resp.body);
    }

    void delete_(const std::string& domain_id) {
        transport_.request("DELETE", "/v1/domains/" + domain_id);
    }

    nlohmann::json validate(const std::string& domain_id) {
        auto resp = transport_.request("POST", "/v1/domains/" + domain_id + "/validate",
                                        nlohmann::json::object());
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
