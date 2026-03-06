#pragma once

#include <string>
#include <vector>
#include <optional>
#include <nlohmann/json.hpp>

namespace ensoul {

struct PersonaCreate {
    std::string name;
    std::string domain;
    std::optional<std::string> archetype;
    std::optional<std::string> region;
    std::optional<nlohmann::json> personality_data;
    std::optional<int> age;
    std::optional<std::string> country;
    std::optional<std::string> city;
    std::optional<std::string> backstory;
    std::optional<std::vector<std::string>> core_values;
    std::optional<nlohmann::json> communication_style;
};

inline void to_json(nlohmann::json& j, const PersonaCreate& p) {
    j = nlohmann::json{{"name", p.name}, {"domain", p.domain}};
    if (p.archetype) j["archetype"] = *p.archetype;
    if (p.region) j["region"] = *p.region;
    if (p.personality_data) j["personality_data"] = *p.personality_data;
    if (p.age) j["age"] = *p.age;
    if (p.country) j["country"] = *p.country;
    if (p.city) j["city"] = *p.city;
    if (p.backstory) j["backstory"] = *p.backstory;
    if (p.core_values) j["core_values"] = *p.core_values;
    if (p.communication_style) j["communication_style"] = *p.communication_style;
}

struct PersonaResponse {
    std::string id;
    std::string name;
    std::string domain;
    std::optional<nlohmann::json> personality_data;
    std::optional<std::string> avatar_url;
    std::optional<std::string> archetype;
    std::optional<int> age;
    std::optional<std::string> country;
    std::optional<std::string> region;
    std::optional<std::string> city;
    std::optional<std::string> batch_id;
    std::string created_at;
};

inline void from_json(const nlohmann::json& j, PersonaResponse& p) {
    j.at("id").get_to(p.id);
    j.at("name").get_to(p.name);
    j.at("domain").get_to(p.domain);
    j.at("created_at").get_to(p.created_at);
    if (j.contains("personality_data") && !j["personality_data"].is_null())
        p.personality_data = j["personality_data"];
    if (j.contains("avatar_url") && !j["avatar_url"].is_null())
        p.avatar_url = j["avatar_url"].get<std::string>();
    if (j.contains("archetype") && !j["archetype"].is_null())
        p.archetype = j["archetype"].get<std::string>();
    if (j.contains("age") && !j["age"].is_null())
        p.age = j["age"].get<int>();
    if (j.contains("country") && !j["country"].is_null())
        p.country = j["country"].get<std::string>();
    if (j.contains("region") && !j["region"].is_null())
        p.region = j["region"].get<std::string>();
    if (j.contains("city") && !j["city"].is_null())
        p.city = j["city"].get<std::string>();
    if (j.contains("batch_id") && !j["batch_id"].is_null())
        p.batch_id = j["batch_id"].get<std::string>();
}

inline void to_json(nlohmann::json& j, const PersonaResponse& p) {
    j = nlohmann::json{{"id", p.id}, {"name", p.name}, {"domain", p.domain}, {"created_at", p.created_at}};
    if (p.personality_data) j["personality_data"] = *p.personality_data;
    if (p.avatar_url) j["avatar_url"] = *p.avatar_url;
    if (p.archetype) j["archetype"] = *p.archetype;
    if (p.age) j["age"] = *p.age;
    if (p.country) j["country"] = *p.country;
    if (p.region) j["region"] = *p.region;
    if (p.city) j["city"] = *p.city;
    if (p.batch_id) j["batch_id"] = *p.batch_id;
}

struct PersonaBatchResponse {
    int created = 0;
    std::vector<std::string> persona_ids;
    std::optional<std::string> batch_id;
    std::optional<std::string> domain;
};

inline void from_json(const nlohmann::json& j, PersonaBatchResponse& p) {
    j.at("created").get_to(p.created);
    j.at("persona_ids").get_to(p.persona_ids);
    if (j.contains("batch_id") && !j["batch_id"].is_null())
        p.batch_id = j["batch_id"].get<std::string>();
    if (j.contains("domain") && !j["domain"].is_null())
        p.domain = j["domain"].get<std::string>();
}

struct PersonalityVectorResponse {
    std::string persona_id;
    std::string domain;
    std::optional<nlohmann::json> personality_data;
    std::optional<nlohmann::json> communication_style;
    std::optional<std::vector<std::string>> core_values;
};

inline void from_json(const nlohmann::json& j, PersonalityVectorResponse& p) {
    j.at("persona_id").get_to(p.persona_id);
    j.at("domain").get_to(p.domain);
    if (j.contains("personality_data") && !j["personality_data"].is_null())
        p.personality_data = j["personality_data"];
    if (j.contains("communication_style") && !j["communication_style"].is_null())
        p.communication_style = j["communication_style"];
    if (j.contains("core_values") && !j["core_values"].is_null())
        p.core_values = j["core_values"].get<std::vector<std::string>>();
}

struct FilterOption {
    std::string id;
    std::string name;
    int count = 0;
};

inline void from_json(const nlohmann::json& j, FilterOption& f) {
    j.at("id").get_to(f.id);
    j.at("name").get_to(f.name);
    j.at("count").get_to(f.count);
}

struct PersonaFiltersResponse {
    std::optional<std::vector<FilterOption>> domains;
    std::optional<std::vector<FilterOption>> regions;
    std::optional<std::vector<FilterOption>> archetypes;
    std::optional<std::vector<FilterOption>> countries;
    std::optional<std::vector<FilterOption>> age_ranges;
    int total_personas = 0;
};

inline void from_json(const nlohmann::json& j, PersonaFiltersResponse& p) {
    p.total_personas = j.value("total_personas", 0);
    if (j.contains("domains") && !j["domains"].is_null())
        p.domains = j["domains"].get<std::vector<FilterOption>>();
    if (j.contains("regions") && !j["regions"].is_null())
        p.regions = j["regions"].get<std::vector<FilterOption>>();
    if (j.contains("archetypes") && !j["archetypes"].is_null())
        p.archetypes = j["archetypes"].get<std::vector<FilterOption>>();
    if (j.contains("countries") && !j["countries"].is_null())
        p.countries = j["countries"].get<std::vector<FilterOption>>();
    if (j.contains("age_ranges") && !j["age_ranges"].is_null())
        p.age_ranges = j["age_ranges"].get<std::vector<FilterOption>>();
}

} // namespace ensoul
