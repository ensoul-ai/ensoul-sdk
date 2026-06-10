#pragma once

#include <string>
#include <map>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/streaming.hpp"

namespace ensoul {

// Aggregate resource.
//
// As of API 0.2.0 the old POST /v1/aggregate/query was removed and split into
// GET /v1/aggregate/count (counts) + GET /v1/aggregate/stats (statistics).
// POST /v1/aggregate/simulate was renamed to POST /v1/aggregate/simulation.
class AggregateResource {
public:
    explicit AggregateResource(IHttpTransport& transport) : transport_(transport) {}

    // GET /v1/aggregate/count — count personas matching a filter.
    nlohmann::json count(const std::string& domain = "",
                         const std::string& filters = "",
                         const std::string& region = "",
                         const std::string& archetype = "",
                         std::optional<int> age_min = std::nullopt,
                         std::optional<int> age_max = std::nullopt) {
        std::map<std::string, std::string> params;
        if (!domain.empty()) params["domain"] = domain;
        if (!filters.empty()) params["filters"] = filters;
        if (!region.empty()) params["region"] = region;
        if (!archetype.empty()) params["archetype"] = archetype;
        if (age_min) params["age_min"] = std::to_string(*age_min);
        if (age_max) params["age_max"] = std::to_string(*age_max);
        auto resp = transport_.request("GET", "/v1/aggregate/count", nullptr, params);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/aggregate/stats — aggregate query statistics.
    nlohmann::json stats() {
        auto resp = transport_.request("GET", "/v1/aggregate/stats");
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/aggregate/stream — SSE stream of progress events.
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

    // POST /v1/aggregate/stream/grouped
    SseStream grouped_stream(const std::string& query_str,
                              const std::string& group_by,
                              const nlohmann::json& filters = nullptr) {
        nlohmann::json body = {{"query", query_str}, {"group_by", group_by}};
        if (!filters.is_null()) body["filters"] = filters;
        auto raw = transport_.stream_sse_raw("POST", "/v1/aggregate/stream/grouped", body);
        return SseStream(raw);
    }

    // POST /v1/aggregate/simulation (SimulationRequest).
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
        auto resp = transport_.request("POST", "/v1/aggregate/simulation", body);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/aggregate/influence/{persona_id}
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
