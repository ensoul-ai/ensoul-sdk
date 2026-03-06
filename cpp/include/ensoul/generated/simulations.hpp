#pragma once

#include <string>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/generated/enums.hpp"

namespace ensoul {

struct SimulationDetailResponse {
    std::string id;
    std::string name;
    std::string domain_id;
    std::optional<std::string> description;
    SimulationStatus status = SimulationStatus::CREATED;
    std::optional<nlohmann::json> config;
    std::optional<int> participant_count;
    std::string created_at;
    std::optional<std::string> updated_at;
};

inline void from_json(const nlohmann::json& j, SimulationDetailResponse& s) {
    j.at("id").get_to(s.id);
    j.at("name").get_to(s.name);
    j.at("domain_id").get_to(s.domain_id);
    j.at("created_at").get_to(s.created_at);
    if (j.contains("status")) s.status = j["status"].get<SimulationStatus>();
    if (j.contains("description") && !j["description"].is_null())
        s.description = j["description"].get<std::string>();
    if (j.contains("config") && !j["config"].is_null())
        s.config = j["config"];
    if (j.contains("participant_count") && !j["participant_count"].is_null())
        s.participant_count = j["participant_count"].get<int>();
    if (j.contains("updated_at") && !j["updated_at"].is_null())
        s.updated_at = j["updated_at"].get<std::string>();
}

struct SchedulerWeights {
    double recency = 1.0;
    double affinity = 1.0;
    double diversity = 1.0;
};

inline void from_json(const nlohmann::json& j, SchedulerWeights& w) {
    w.recency = j.value("recency", 1.0);
    w.affinity = j.value("affinity", 1.0);
    w.diversity = j.value("diversity", 1.0);
}

struct ParticipantResponse {
    std::string persona_id;
    std::optional<std::string> joined_at;
    std::optional<std::string> status;
};

inline void from_json(const nlohmann::json& j, ParticipantResponse& p) {
    j.at("persona_id").get_to(p.persona_id);
    if (j.contains("joined_at") && !j["joined_at"].is_null())
        p.joined_at = j["joined_at"].get<std::string>();
    if (j.contains("status") && !j["status"].is_null())
        p.status = j["status"].get<std::string>();
}

} // namespace ensoul
