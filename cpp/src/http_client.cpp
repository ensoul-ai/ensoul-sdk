#include "ensoul/http_client.hpp"
#include "ensoul/errors.hpp"
#include <httplib.h>
#include <thread>
#include <chrono>
#include <random>
#include <algorithm>
#include <set>
#include <sstream>
#include <cstdlib>

namespace ensoul {

static const std::set<int> RETRY_STATUS_CODES = {429, 500, 502, 503};
static const char* SDK_USER_AGENT = "ensoul-cpp/0.1.0";

std::string normalize_path(const std::string& path) {
    if (path.empty()) return "/v1/";
    if (path.find("/v1/") == 0 || path.find("/v1?") == 0) return path;
    if (path.find("/health") == 0 || path.find("/auth") == 0) return path;
    std::string p = path;
    if (p.front() != '/') p = "/" + p;
    return "/v1" + p;
}

static std::string build_query_string(const std::map<std::string, std::string>& params) {
    if (params.empty()) return "";
    std::ostringstream oss;
    bool first = true;
    for (const auto& [key, value] : params) {
        if (!first) oss << "&";
        first = false;
        // Simple URL encoding for common characters
        for (char c : key) {
            if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
                oss << c;
            } else {
                oss << '%' << std::uppercase << std::hex
                    << static_cast<int>(static_cast<unsigned char>(c));
            }
        }
        oss << '=';
        for (char c : value) {
            if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
                oss << c;
            } else {
                oss << '%' << std::uppercase << std::hex
                    << static_cast<int>(static_cast<unsigned char>(c));
            }
        }
    }
    return oss.str();
}

static double retry_wait(int attempt) {
    // Exponential backoff with jitter, capped at 30s
    double base = std::min(30.0, std::pow(2.0, attempt));
    static thread_local std::mt19937 gen(std::random_device{}());
    std::uniform_real_distribution<double> dist(0.0, base);
    return dist(gen);
}

struct HttpClient::Impl {
    httplib::Client client;
    ClientConfig config;
    std::unique_ptr<AuthProvider> auth;
    RateLimitTracker rate_limiter;

    Impl(const ClientConfig& cfg)
        : client(cfg.base_url), config(cfg) {
        // Set timeout (convert ms to seconds)
        int timeout_sec = static_cast<int>(cfg.timeout_ms / 1000);
        if (timeout_sec < 1) timeout_sec = 1;
        client.set_connection_timeout(timeout_sec);
        client.set_read_timeout(timeout_sec);
        client.set_write_timeout(timeout_sec);

        // Follow HTTP redirects (API uses 307 on paths without trailing slash)
        client.set_follow_location(true);

        // Build auth provider
        auth = make_auth(cfg.api_key, cfg.bearer_token);
    }
};

HttpClient::HttpClient(const ClientConfig& config)
    : impl_(std::make_unique<Impl>(config)) {}

HttpClient::~HttpClient() = default;

HttpResponse HttpClient::request(
    const std::string& method,
    const std::string& path,
    const nlohmann::json& json_body,
    const std::map<std::string, std::string>& params,
    const std::map<std::string, std::string>& extra_headers,
    bool stream)
{
    std::string normalized = normalize_path(path);

    // Append query params
    if (!params.empty()) {
        normalized += "?" + build_query_string(params);
    }

    // Build headers
    httplib::Headers headers;
    headers.emplace("User-Agent", SDK_USER_AGENT);
    headers.emplace("Accept", "application/json");

    // Auth headers
    if (impl_->auth) {
        for (const auto& [k, v] : impl_->auth->auth_headers()) {
            headers.emplace(k, v);
        }
    }

    // Custom headers from config
    for (const auto& [k, v] : impl_->config.custom_headers) {
        headers.emplace(k, v);
    }

    // Extra headers per-request
    for (const auto& [k, v] : extra_headers) {
        headers.emplace(k, v);
    }

    // If streaming, add Accept for SSE
    if (stream) {
        headers.erase("Accept");
        headers.emplace("Accept", "text/event-stream");
    }

    // Build body string
    std::string body_str;
    std::string content_type = "application/json";
    if (!json_body.is_null()) {
        body_str = json_body.dump();
    }

    int max_retries = impl_->config.max_retries;

    for (int attempt = 0; attempt <= max_retries; ++attempt) {
        // Check rate limit wait
        auto [should_wait, wait_time] = impl_->rate_limiter.should_wait();
        if (should_wait) {
            auto wait_ms = static_cast<long long>(wait_time * 1000);
            std::this_thread::sleep_for(std::chrono::milliseconds(wait_ms));
        }

        try {
            httplib::Result result;

            if (method == "GET") {
                result = impl_->client.Get(normalized, headers);
            } else if (method == "POST") {
                result = impl_->client.Post(normalized, headers, body_str, content_type);
            } else if (method == "PUT") {
                result = impl_->client.Put(normalized, headers, body_str, content_type);
            } else if (method == "PATCH") {
                result = impl_->client.Patch(normalized, headers, body_str, content_type);
            } else if (method == "DELETE") {
                result = impl_->client.Delete(normalized, headers);
            } else {
                throw EnsoulError("Unsupported HTTP method: " + method);
            }

            if (!result) {
                auto err = result.error();
                std::string err_msg = "HTTP request failed: ";
                switch (err) {
                    case httplib::Error::Connection:
                        err_msg += "Connection error"; break;
                    case httplib::Error::Read:
                        err_msg += "Read error"; break;
                    case httplib::Error::Write:
                        err_msg += "Write error"; break;
                    case httplib::Error::ConnectionTimeout:
                        err_msg += "Connection timeout"; break;
                    default:
                        err_msg += "Unknown error"; break;
                }

                if (attempt < max_retries) {
                    double wait = retry_wait(attempt);
                    std::this_thread::sleep_for(
                        std::chrono::milliseconds(static_cast<long long>(wait * 1000)));
                    continue;
                }
                throw EnsoulError(err_msg);
            }

            // Update rate limit tracker from response headers
            std::map<std::string, std::string> resp_headers;
            for (const auto& [k, v] : result->headers) {
                resp_headers[k] = v;
            }
            impl_->rate_limiter.update(resp_headers);

            int status = result->status;

            // Check for retryable status codes
            if (RETRY_STATUS_CODES.count(status) && attempt < max_retries) {
                double wait = retry_wait(attempt);
                // For 429, use Retry-After if available
                if (status == 429) {
                    auto it = resp_headers.find("Retry-After");
                    if (it == resp_headers.end()) it = resp_headers.find("retry-after");
                    if (it != resp_headers.end()) {
                        try {
                            wait = std::stod(it->second);
                        } catch (...) {}
                    }
                }
                std::this_thread::sleep_for(
                    std::chrono::milliseconds(static_cast<long long>(wait * 1000)));
                continue;
            }

            // Raise for non-stream error statuses
            if (!stream && status >= 400) {
                raise_for_status(status, result->body, resp_headers);
            }

            return HttpResponse{status, result->body, resp_headers};

        } catch (const EnsoulError&) {
            throw;
        } catch (const std::exception& e) {
            if (attempt < max_retries) {
                double wait = retry_wait(attempt);
                std::this_thread::sleep_for(
                    std::chrono::milliseconds(static_cast<long long>(wait * 1000)));
                continue;
            }
            throw EnsoulError(std::string("Request failed: ") + e.what());
        }
    }

    // Should not reach here, but just in case
    throw EnsoulError("Request failed after all retries");
}

HttpResponse HttpClient::post_form(
    const std::string& path,
    const std::map<std::string, std::string>& form_data)
{
    std::string normalized = normalize_path(path);

    httplib::Headers headers;
    headers.emplace("User-Agent", SDK_USER_AGENT);
    headers.emplace("Accept", "application/json");

    if (impl_->auth) {
        for (const auto& [k, v] : impl_->auth->auth_headers()) {
            headers.emplace(k, v);
        }
    }
    for (const auto& [k, v] : impl_->config.custom_headers) {
        headers.emplace(k, v);
    }

    // Build URL-encoded form body
    std::string body = build_query_string(form_data);
    std::string content_type = "application/x-www-form-urlencoded";

    auto result = impl_->client.Post(normalized, headers, body, content_type);

    if (!result) {
        throw EnsoulError("Form POST request failed: connection error");
    }

    std::map<std::string, std::string> resp_headers;
    for (const auto& [k, v] : result->headers) {
        resp_headers[k] = v;
    }
    impl_->rate_limiter.update(resp_headers);

    if (result->status >= 400) {
        raise_for_status(result->status, result->body, resp_headers);
    }

    return HttpResponse{result->status, result->body, resp_headers};
}

HttpResponse HttpClient::get_raw(
    const std::string& path,
    const std::map<std::string, std::string>& params)
{
    // No /v1/ prefix normalization for raw paths
    std::string full_path = path;
    if (!params.empty()) {
        full_path += "?" + build_query_string(params);
    }

    httplib::Headers headers;
    headers.emplace("User-Agent", SDK_USER_AGENT);
    headers.emplace("Accept", "application/json");

    if (impl_->auth) {
        for (const auto& [k, v] : impl_->auth->auth_headers()) {
            headers.emplace(k, v);
        }
    }
    for (const auto& [k, v] : impl_->config.custom_headers) {
        headers.emplace(k, v);
    }

    auto result = impl_->client.Get(full_path, headers);

    if (!result) {
        throw EnsoulError("GET raw request failed: connection error");
    }

    std::map<std::string, std::string> resp_headers;
    for (const auto& [k, v] : result->headers) {
        resp_headers[k] = v;
    }

    if (result->status >= 400) {
        raise_for_status(result->status, result->body, resp_headers);
    }

    return HttpResponse{result->status, result->body, resp_headers};
}

std::string HttpClient::stream_sse_raw(
    const std::string& method,
    const std::string& path,
    const nlohmann::json& json_body,
    const std::map<std::string, std::string>& params)
{
    // Use the request method with stream=true to get the raw SSE body
    auto resp = request(method, path, json_body, params, {}, true);

    if (resp.status_code >= 400) {
        raise_for_status(resp.status_code, resp.body, resp.headers);
    }

    return resp.body;
}

// Convenience methods
HttpResponse HttpClient::get(const std::string& path,
                              const std::map<std::string, std::string>& params) {
    return request("GET", path, nullptr, params);
}

HttpResponse HttpClient::post(const std::string& path,
                               const nlohmann::json& json_body,
                               const std::map<std::string, std::string>& params) {
    return request("POST", path, json_body, params);
}

HttpResponse HttpClient::put(const std::string& path,
                              const nlohmann::json& json_body) {
    return request("PUT", path, json_body);
}

HttpResponse HttpClient::patch(const std::string& path,
                                const nlohmann::json& json_body) {
    return request("PATCH", path, json_body);
}

HttpResponse HttpClient::del(const std::string& path) {
    return request("DELETE", path);
}

} // namespace ensoul
