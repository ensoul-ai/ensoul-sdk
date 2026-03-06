#pragma once

#include <string>
#include <map>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/streaming.hpp"

namespace ensoul {

class AggregateResource {
public:
    explicit AggregateResource(IHttpTransport& transport) : transport_(transport) {}

    nlohmann::json query(const std::string& query_str,
                          const nlohmann::json& filters = nullptr,
                          const std::string& aggregation_mode = "") {
        nlohmann::json body = {{"query", query_str}};
        if (!filters.is_null()) body["filters"] = filters;
        if (!aggregation_mode.empty()) body["aggregation_mode"] = aggregation_mode;
        auto resp = transport_.request("POST", "/v1/aggregate/query", body);
        return nlohmann::json::parse(resp.body);
    }

    SseStream stream(const std::string& query_str,
                     const nlohmann::json& filters = nullptr,
                     const std::string& aggregation_mode = "",
                     double target_confidence = 0.95,
                     int min_samples = 100,
                     std::optional<int> max_samples = std::nullopt) {
        nlohmann::json body = {
            {"query", query_str},
            {"target_confidence", target_confidence},
            {"min_samples", min_samples}
        };
        if (!filters.is_null()) body["filters"] = filters;
        if (!aggregation_mode.empty()) body["aggregation_mode"] = aggregation_mode;
        if (max_samples) body["max_samples"] = *max_samples;
        auto raw = transport_.stream_sse_raw("POST", "/v1/aggregate/stream", body);
        return SseStream(raw);
    }

    SseStream grouped_stream(const std::string& query_str,
                              const std::string& group_by,
                              const nlohmann::json& filters = nullptr) {
        nlohmann::json body = {{"query", query_str}, {"group_by", group_by}};
        if (!filters.is_null()) body["filters"] = filters;
        auto raw = transport_.stream_sse_raw("POST", "/v1/aggregate/stream/grouped", body);
        return SseStream(raw);
    }

    nlohmann::json simulate(const std::string& scenario,
                             const nlohmann::json& target_cohort = nullptr,
                             int duration_days = 30,
                             const nlohmann::json& parameters = nullptr) {
        nlohmann::json body = {
            {"scenario", scenario},
            {"duration_days", duration_days}
        };
        if (!target_cohort.is_null()) body["target_cohort"] = target_cohort;
        if (!parameters.is_null()) body["parameters"] = parameters;
        auto resp = transport_.request("POST", "/v1/aggregate/simulate", body);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json trace_influence(const std::string& persona_id,
                                    const std::string& influence_type = "",
                                    const std::string& direction = "downstream",
                                    int max_depth = 3) {
        std::map<std::string, std::string> params = {
            {"direction", direction},
            {"max_depth", std::to_string(max_depth)}
        };
        if (!influence_type.empty()) params["influence_type"] = influence_type;
        auto resp = transport_.request("GET",
            "/v1/aggregate/influence/" + persona_id, nullptr, params);
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
