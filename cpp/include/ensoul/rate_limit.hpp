#pragma once

#include <string>
#include <map>
#include <mutex>
#include <chrono>
#include <optional>
#include <algorithm>

namespace ensoul {

struct RateLimitInfo {
    int limit = 0;
    int remaining = 0;
    double reset = 0.0;       // Unix timestamp
    double retry_after = 0.0; // seconds to wait (only on 429)

    static std::optional<RateLimitInfo> from_headers(const std::map<std::string, std::string>& headers) {
        auto find_header = [&](const std::string& name) -> std::optional<std::string> {
            auto it = headers.find(name);
            if (it != headers.end()) return it->second;
            // Try lowercase
            std::string lower = name;
            std::transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
            for (const auto& [k, v] : headers) {
                std::string lk = k;
                std::transform(lk.begin(), lk.end(), lk.begin(), ::tolower);
                if (lk == lower) return v;
            }
            return std::nullopt;
        };

        auto limit_raw = find_header("X-RateLimit-Limit");
        auto remaining_raw = find_header("X-RateLimit-Remaining");
        auto reset_raw = find_header("X-RateLimit-Reset");

        if (!limit_raw || !remaining_raw || !reset_raw) return std::nullopt;

        try {
            RateLimitInfo info;
            info.limit = std::stoi(*limit_raw);
            info.remaining = std::stoi(*remaining_raw);
            info.reset = std::stod(*reset_raw);
            auto retry_raw = find_header("Retry-After");
            if (retry_raw) {
                info.retry_after = std::stod(*retry_raw);
            }
            return info;
        } catch (...) {
            return std::nullopt;
        }
    }
};

class RateLimitTracker {
public:
    void update(const std::map<std::string, std::string>& headers) {
        auto parsed = RateLimitInfo::from_headers(headers);
        if (parsed) {
            std::lock_guard<std::mutex> lock(mutex_);
            info_ = *parsed;
            has_info_ = true;
        }
    }

    std::pair<bool, double> should_wait() const {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!has_info_) return {false, 0.0};

        if (info_.remaining > 0) return {false, 0.0};

        double now = std::chrono::duration<double>(
            std::chrono::system_clock::now().time_since_epoch()).count();
        double seconds_until_reset = info_.reset - now;
        if (seconds_until_reset <= 0.0) return {false, 0.0};

        return {true, seconds_until_reset};
    }

private:
    mutable std::mutex mutex_;
    RateLimitInfo info_;
    bool has_info_ = false;
};

} // namespace ensoul
