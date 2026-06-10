#pragma once

#include <string>
#include <map>

namespace ensoul {

inline constexpr const char* DEFAULT_BASE_URL = "https://api.ensoul-ai.com";
inline constexpr long DEFAULT_TIMEOUT_MS = 30000;
inline constexpr int DEFAULT_MAX_RETRIES = 2;
inline constexpr const char* API_VERSION = "v1";

struct ClientConfig {
    std::string base_url = DEFAULT_BASE_URL;
    std::string api_key;
    std::string bearer_token;
    long timeout_ms = DEFAULT_TIMEOUT_MS;
    int max_retries = DEFAULT_MAX_RETRIES;
    std::map<std::string, std::string> custom_headers;

    std::string api_url() const {
        std::string url = base_url;
        while (!url.empty() && url.back() == '/') url.pop_back();
        return url + "/" + API_VERSION;
    }
};

} // namespace ensoul
