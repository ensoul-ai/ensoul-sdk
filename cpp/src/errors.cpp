#include "ensoul/errors.hpp"
#include <nlohmann/json.hpp>

namespace ensoul {

void raise_for_status(
    int status_code,
    const std::string& body,
    const std::map<std::string, std::string>& headers)
{
    if (status_code < 400) return;

    nlohmann::json parsed;
    try {
        parsed = nlohmann::json::parse(body);
    } catch (...) {
        parsed = nlohmann::json::object();
    }

    std::string error = "Unknown Error";
    std::string message = "Unknown error";
    std::string request_id;

    if (parsed.contains("error") && parsed["error"].is_string()) {
        error = parsed["error"].get<std::string>();
    }
    if (parsed.contains("message") && parsed["message"].is_string()) {
        message = parsed["message"].get<std::string>();
    }
    if (parsed.contains("request_id") && parsed["request_id"].is_string()) {
        request_id = parsed["request_id"].get<std::string>();
    }

    switch (status_code) {
        case 401:
            throw AuthenticationError(status_code, error, message, request_id);
        case 403: {
            std::string required_tier, current_tier;
            if (parsed.contains("required_tier") && parsed["required_tier"].is_string()) {
                required_tier = parsed["required_tier"].get<std::string>();
            }
            if (parsed.contains("current_tier") && parsed["current_tier"].is_string()) {
                current_tier = parsed["current_tier"].get<std::string>();
            }
            throw AuthorizationError(status_code, error, message, request_id,
                                     required_tier, current_tier);
        }
        case 404: {
            std::string resource_type, resource_id;
            if (parsed.contains("resource_type") && parsed["resource_type"].is_string()) {
                resource_type = parsed["resource_type"].get<std::string>();
            }
            if (parsed.contains("resource_id") && parsed["resource_id"].is_string()) {
                resource_id = parsed["resource_id"].get<std::string>();
            }
            throw NotFoundError(status_code, error, message, request_id,
                                resource_type, resource_id);
        }
        case 409:
            throw ConflictError(status_code, error, message, request_id);
        case 422: {
            std::vector<ErrorDetail> details;
            if (parsed.contains("details") && parsed["details"].is_array()) {
                for (const auto& item : parsed["details"]) {
                    ErrorDetail d;
                    if (item.contains("field") && item["field"].is_string())
                        d.field = item["field"].get<std::string>();
                    if (item.contains("message") && item["message"].is_string())
                        d.message = item["message"].get<std::string>();
                    if (item.contains("type") && item["type"].is_string())
                        d.type = item["type"].get<std::string>();
                    details.push_back(d);
                }
            }
            throw ValidationError(status_code, error, message, request_id, details);
        }
        case 429: {
            int retry_after = 0;
            auto it = headers.find("Retry-After");
            if (it == headers.end()) it = headers.find("retry-after");
            if (it != headers.end()) {
                try { retry_after = std::stoi(it->second); } catch (...) {}
            }
            throw RateLimitError(status_code, error, message, request_id, retry_after);
        }
        case 500:
        case 503:
            throw ServerError(status_code, error, message, request_id);
        default:
            throw ApiError(status_code, error, message, request_id);
    }
}

} // namespace ensoul
