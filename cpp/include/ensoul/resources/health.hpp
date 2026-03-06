#pragma once

#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"

namespace ensoul {

class HealthResource {
public:
    explicit HealthResource(IHttpTransport& transport) : transport_(transport) {}

    nlohmann::json check() {
        auto resp = transport_.get_raw("/health");
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json ready() {
        auto resp = transport_.get_raw("/health/ready");
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json live() {
        auto resp = transport_.get_raw("/health/live");
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
