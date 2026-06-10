#pragma once

#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"

namespace ensoul {

class FrameworksResource {
public:
    explicit FrameworksResource(IHttpTransport& transport) : transport_(transport) {}

    Page<nlohmann::json> list(int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET", "/v1/frameworks", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);
        auto fetcher = [this, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET", "/v1/frameworks", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    nlohmann::json get(const std::string& framework_id) {
        auto resp = transport_.request("GET", "/v1/frameworks/" + framework_id);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json create(const nlohmann::json& body) {
        auto resp = transport_.request("POST", "/v1/frameworks", body);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json update(const std::string& framework_id, const nlohmann::json& body) {
        auto resp = transport_.request("PUT", "/v1/frameworks/" + framework_id, body);
        return nlohmann::json::parse(resp.body);
    }

    void delete_(const std::string& framework_id) {
        transport_.request("DELETE", "/v1/frameworks/" + framework_id);
    }

    // GET /v1/frameworks/{framework_id}/validations
    nlohmann::json validations(const std::string& framework_id) {
        auto resp = transport_.request("GET",
            "/v1/frameworks/" + framework_id + "/validations");
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json get_instruments(const std::string& framework_id) {
        auto resp = transport_.request("GET",
            "/v1/frameworks/" + framework_id + "/instruments");
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
