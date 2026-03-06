#pragma once

#include <string>
#include <map>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"
#include "ensoul/streaming.hpp"
#include "ensoul/generated/simulations.hpp"

namespace ensoul {

class SimulationsResource {
public:
    explicit SimulationsResource(IHttpTransport& transport) : transport_(transport) {}

    SimulationDetailResponse create(const std::string& name,
                                     const std::string& domain_id,
                                     const std::string& description = "",
                                     const nlohmann::json& config = nullptr,
                                     const nlohmann::json& participant_persona_ids = nullptr) {
        nlohmann::json body = {{"name", name}, {"domain_id", domain_id}};
        if (!description.empty()) body["description"] = description;
        if (!config.is_null()) body["config"] = config;
        if (!participant_persona_ids.is_null()) body["participant_persona_ids"] = participant_persona_ids;
        auto resp = transport_.request("POST", "/v1/simulations", body);
        return nlohmann::json::parse(resp.body).get<SimulationDetailResponse>();
    }

    SimulationDetailResponse get(const std::string& simulation_id) {
        auto resp = transport_.request("GET", "/v1/simulations/" + simulation_id);
        return nlohmann::json::parse(resp.body).get<SimulationDetailResponse>();
    }

    Page<nlohmann::json> list(int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET", "/v1/simulations", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);
        auto fetcher = [this, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET", "/v1/simulations", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    nlohmann::json start(const std::string& simulation_id,
                          std::optional<int> ticks = std::nullopt) {
        nlohmann::json body = nlohmann::json::object();
        if (ticks) body["ticks"] = *ticks;
        auto resp = transport_.request("POST", "/v1/simulations/" + simulation_id + "/start", body);
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json pause(const std::string& simulation_id) {
        auto resp = transport_.request("POST", "/v1/simulations/" + simulation_id + "/pause",
                                        nlohmann::json::object());
        return nlohmann::json::parse(resp.body);
    }

    nlohmann::json stop(const std::string& simulation_id) {
        auto resp = transport_.request("POST", "/v1/simulations/" + simulation_id + "/stop",
                                        nlohmann::json::object());
        return nlohmann::json::parse(resp.body);
    }

    SseStream stream(const std::string& simulation_id) {
        auto raw = transport_.stream_sse_raw("GET",
            "/v1/simulations/" + simulation_id + "/stream");
        return SseStream(raw);
    }

    Page<nlohmann::json> get_events(const std::string& simulation_id,
                                     int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET",
            "/v1/simulations/" + simulation_id + "/events", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);
        auto fetcher = [this, simulation_id, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET",
                "/v1/simulations/" + simulation_id + "/events", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    nlohmann::json get_history(const std::string& simulation_id) {
        auto resp = transport_.request("GET", "/v1/simulations/" + simulation_id + "/history");
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
