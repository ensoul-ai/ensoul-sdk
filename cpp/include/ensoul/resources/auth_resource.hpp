#pragma once

#include <string>
#include <vector>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/generated/auth.hpp"

namespace ensoul {

class AuthResourceNS {
public:
    explicit AuthResourceNS(IHttpTransport& transport) : transport_(transport) {}

    TokenResponse token(const std::string& username, const std::string& password) {
        std::map<std::string, std::string> form = {
            {"username", username},
            {"password", password},
            {"grant_type", "password"}
        };
        auto resp = transport_.post_form("/v1/auth/token", form);
        return nlohmann::json::parse(resp.body).get<TokenResponse>();
    }

    TokenResponse refresh(const std::string& refresh_token) {
        nlohmann::json body = {
            {"refresh_token", refresh_token},
            {"grant_type", "refresh_token"}
        };
        auto resp = transport_.request("POST", "/v1/auth/refresh", body);
        return nlohmann::json::parse(resp.body).get<TokenResponse>();
    }

    UserResponse me() {
        auto resp = transport_.request("GET", "/v1/auth/me");
        return nlohmann::json::parse(resp.body).get<UserResponse>();
    }

    APIKeyResponse create_api_key(const std::string& name,
                                   int expires_days = 365,
                                   const std::vector<std::string>& scopes = {}) {
        nlohmann::json body = {{"name", name}, {"expires_days", expires_days}};
        if (!scopes.empty()) body["scopes"] = scopes;
        auto resp = transport_.request("POST", "/v1/api-keys", body);
        return nlohmann::json::parse(resp.body).get<APIKeyResponse>();
    }

    std::vector<APIKeyResponse> list_api_keys() {
        auto resp = transport_.request("GET", "/v1/api-keys");
        auto data = nlohmann::json::parse(resp.body);
        std::vector<APIKeyResponse> keys;
        auto items = data.is_array() ? data : (data.contains("items") ? data["items"] : nlohmann::json::array());
        for (const auto& item : items) {
            keys.push_back(item.get<APIKeyResponse>());
        }
        return keys;
    }

    void revoke_api_key(const std::string& key_id) {
        transport_.request("DELETE", "/v1/api-keys/" + key_id);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
