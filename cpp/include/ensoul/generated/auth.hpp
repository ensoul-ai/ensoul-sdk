#pragma once

#include <string>
#include <vector>
#include <optional>
#include <nlohmann/json.hpp>

namespace ensoul {

struct TokenResponse {
    std::string access_token;
    std::string token_type = "bearer";
    int expires_in = 0;
    std::optional<std::string> refresh_token;
    std::optional<std::string> scope;
};

inline void from_json(const nlohmann::json& j, TokenResponse& t) {
    j.at("access_token").get_to(t.access_token);
    t.token_type = j.value("token_type", std::string("bearer"));
    t.expires_in = j.value("expires_in", 0);
    if (j.contains("refresh_token") && !j["refresh_token"].is_null())
        t.refresh_token = j["refresh_token"].get<std::string>();
    if (j.contains("scope") && !j["scope"].is_null())
        t.scope = j["scope"].get<std::string>();
}

struct APIKeyResponse {
    std::string key_id;
    std::string name;
    std::string key_preview;
    std::optional<std::string> full_key;
    std::optional<std::vector<std::string>> scopes;
    std::string created_at;
    std::string expires_at;
    std::optional<std::string> last_used_at;
    bool is_active = true;
};

inline void from_json(const nlohmann::json& j, APIKeyResponse& k) {
    j.at("key_id").get_to(k.key_id);
    j.at("name").get_to(k.name);
    j.at("key_preview").get_to(k.key_preview);
    j.at("created_at").get_to(k.created_at);
    j.at("expires_at").get_to(k.expires_at);
    k.is_active = j.value("is_active", true);
    if (j.contains("full_key") && !j["full_key"].is_null())
        k.full_key = j["full_key"].get<std::string>();
    if (j.contains("scopes") && !j["scopes"].is_null())
        k.scopes = j["scopes"].get<std::vector<std::string>>();
    if (j.contains("last_used_at") && !j["last_used_at"].is_null())
        k.last_used_at = j["last_used_at"].get<std::string>();
}

struct UserResponse {
    std::string consumer_id;
    std::string username;
    std::optional<std::string> email;
    std::string access_tier;
    std::optional<std::vector<std::string>> permissions;
    std::string created_at;
    bool is_active = true;
};

inline void from_json(const nlohmann::json& j, UserResponse& u) {
    j.at("consumer_id").get_to(u.consumer_id);
    j.at("username").get_to(u.username);
    j.at("access_tier").get_to(u.access_tier);
    j.at("created_at").get_to(u.created_at);
    u.is_active = j.value("is_active", true);
    if (j.contains("email") && !j["email"].is_null())
        u.email = j["email"].get<std::string>();
    if (j.contains("permissions") && !j["permissions"].is_null())
        u.permissions = j["permissions"].get<std::vector<std::string>>();
}

} // namespace ensoul
