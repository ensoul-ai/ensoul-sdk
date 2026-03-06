#pragma once

#include <string>
#include <map>
#include <memory>
#include <functional>
#include <nlohmann/json.hpp>
#include "ensoul/config.hpp"
#include "ensoul/auth.hpp"
#include "ensoul/rate_limit.hpp"

namespace ensoul {

struct HttpResponse {
    int status_code = 0;
    std::string body;
    std::map<std::string, std::string> headers;
};

class IHttpTransport {
public:
    virtual ~IHttpTransport() = default;

    virtual HttpResponse request(
        const std::string& method,
        const std::string& path,
        const nlohmann::json& json_body = nullptr,
        const std::map<std::string, std::string>& params = {},
        const std::map<std::string, std::string>& headers = {},
        bool stream = false) = 0;

    virtual HttpResponse post_form(
        const std::string& path,
        const std::map<std::string, std::string>& form_data) = 0;

    virtual HttpResponse get_raw(
        const std::string& path,
        const std::map<std::string, std::string>& params = {}) = 0;

    virtual std::string stream_sse_raw(
        const std::string& method,
        const std::string& path,
        const nlohmann::json& json_body = nullptr,
        const std::map<std::string, std::string>& params = {}) = 0;
};

class HttpClient : public IHttpTransport {
public:
    explicit HttpClient(const ClientConfig& config);
    ~HttpClient() override;

    HttpResponse request(
        const std::string& method,
        const std::string& path,
        const nlohmann::json& json_body = nullptr,
        const std::map<std::string, std::string>& params = {},
        const std::map<std::string, std::string>& headers = {},
        bool stream = false) override;

    HttpResponse post_form(
        const std::string& path,
        const std::map<std::string, std::string>& form_data) override;

    HttpResponse get_raw(
        const std::string& path,
        const std::map<std::string, std::string>& params = {}) override;

    std::string stream_sse_raw(
        const std::string& method,
        const std::string& path,
        const nlohmann::json& json_body = nullptr,
        const std::map<std::string, std::string>& params = {}) override;

    // Convenience methods
    HttpResponse get(const std::string& path,
                     const std::map<std::string, std::string>& params = {});
    HttpResponse post(const std::string& path,
                      const nlohmann::json& json_body = nullptr,
                      const std::map<std::string, std::string>& params = {});
    HttpResponse put(const std::string& path,
                     const nlohmann::json& json_body = nullptr);
    HttpResponse patch(const std::string& path,
                       const nlohmann::json& json_body = nullptr);
    HttpResponse del(const std::string& path);

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

std::string normalize_path(const std::string& path);

} // namespace ensoul
