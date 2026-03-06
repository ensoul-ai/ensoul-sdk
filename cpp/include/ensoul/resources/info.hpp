#pragma once

#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"

namespace ensoul {

class InfoResource {
public:
    explicit InfoResource(IHttpTransport& transport) : transport_(transport) {}

    nlohmann::json config() {
        auto resp = transport_.request("GET", "/v1/info/config");
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json rate_limits() {
        auto resp = transport_.request("GET", "/v1/info/rate-limits");
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json tiers() {
        auto resp = transport_.request("GET", "/v1/info/tiers");
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json features() {
        auto resp = transport_.request("GET", "/v1/info/features");
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
