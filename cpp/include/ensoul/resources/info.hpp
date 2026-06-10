#pragma once

#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"

namespace ensoul {

// Info resource.
//
// BREAKING (0.2.0): the four /v1/info/* routes (config, rate-limits, tiers,
// features) were replaced by a single GET /v1/api/info returning an
// APIInfoResponse blob. The convenience methods below each fetch that blob and
// return their relevant sub-section, so existing call sites keep working
// without four separate round-trips. The standalone config()/rate_limits()/
// tiers()/features() endpoints no longer exist server-side.
class InfoResource {
public:
    explicit InfoResource(IHttpTransport& transport) : transport_(transport) {}

    // GET /v1/api/info — full server info (APIInfoResponse).
    nlohmann::json get() {
        auto resp = transport_.request("GET", "/v1/api/info");
        return nlohmann::json::parse(resp.body);
    }

    // Full server configuration blob (alias for get()).
    nlohmann::json config() {
        return get();
    }

    // Rate-limiting configuration sub-section.
    nlohmann::json rate_limits() {
        auto data = get();
        return data.contains("rate_limiting") ? data["rate_limiting"]
                                              : nlohmann::json::object();
    }

    // Access-tier definitions sub-section.
    nlohmann::json tiers() {
        auto data = get();
        return data.contains("access_tiers") ? data["access_tiers"]
                                             : nlohmann::json::array();
    }

    // Feature-flags sub-section.
    nlohmann::json features() {
        auto data = get();
        return data.contains("features") ? data["features"]
                                         : nlohmann::json::object();
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
