#pragma once

#include <string>
#include <map>
#include <chrono>
#include <memory>

namespace ensoul {

class AuthProvider {
public:
    virtual ~AuthProvider() = default;
    virtual std::map<std::string, std::string> auth_headers() const = 0;
};

class ApiKeyAuth : public AuthProvider {
public:
    explicit ApiKeyAuth(const std::string& api_key) : api_key_(api_key) {}

    std::map<std::string, std::string> auth_headers() const override {
        return {{"X-API-Key", api_key_}};
    }

private:
    std::string api_key_;
};

class BearerAuth : public AuthProvider {
public:
    std::string access_token;
    std::string refresh_token;
    double expires_at = 0.0;  // Unix timestamp

    explicit BearerAuth(const std::string& token,
                        const std::string& refresh = "",
                        double expires_at = 0.0)
        : access_token(token), refresh_token(refresh), expires_at(expires_at) {}

    std::map<std::string, std::string> auth_headers() const override {
        return {{"Authorization", "Bearer " + access_token}};
    }

    bool is_expired() const {
        if (expires_at <= 0.0) return false;
        return current_time_seconds() >= expires_at;
    }

    bool needs_refresh() const {
        if (expires_at <= 0.0) return false;
        return current_time_seconds() >= (expires_at - REFRESH_BUFFER_SECONDS);
    }

private:
    static constexpr double REFRESH_BUFFER_SECONDS = 60.0;

    static double current_time_seconds() {
        auto now = std::chrono::system_clock::now();
        return std::chrono::duration<double>(now.time_since_epoch()).count();
    }
};

inline std::unique_ptr<AuthProvider> make_auth(const std::string& api_key,
                                                const std::string& bearer_token) {
    if (!bearer_token.empty()) {
        return std::make_unique<BearerAuth>(bearer_token);
    }
    return std::make_unique<ApiKeyAuth>(api_key);
}

} // namespace ensoul
