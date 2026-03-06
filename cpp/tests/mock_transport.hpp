#pragma once

#include <functional>
#include <vector>
#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"

namespace ensoul {
namespace testing {

struct CapturedRequest {
    std::string method;
    std::string path;
    nlohmann::json json_body;
    std::map<std::string, std::string> params;
    std::map<std::string, std::string> headers;
    bool is_form = false;
    std::map<std::string, std::string> form_data;
    bool is_raw = false;
    bool is_stream = false;
};

class MockTransport : public IHttpTransport {
public:
    using Handler = std::function<HttpResponse(const std::string&, const std::string&)>;

    Handler handler = [](const std::string&, const std::string&) {
        return HttpResponse{200, "{}", {}};
    };

    std::vector<CapturedRequest> captured_requests;

    CapturedRequest* last_request() {
        return captured_requests.empty() ? nullptr : &captured_requests.back();
    }

    void set_response(int status, const std::string& body,
                      const std::map<std::string, std::string>& headers = {}) {
        handler = [=](const std::string&, const std::string&) {
            return HttpResponse{status, body, headers};
        };
    }

    HttpResponse request(
        const std::string& method,
        const std::string& path,
        const nlohmann::json& json_body,
        const std::map<std::string, std::string>& params,
        const std::map<std::string, std::string>& headers,
        bool stream) override
    {
        CapturedRequest req;
        req.method = method;
        req.path = path;
        req.json_body = json_body;
        req.params = params;
        req.headers = headers;
        req.is_stream = stream;
        captured_requests.push_back(req);
        return handler(method, path);
    }

    HttpResponse post_form(
        const std::string& path,
        const std::map<std::string, std::string>& form_data) override
    {
        CapturedRequest req;
        req.method = "POST";
        req.path = path;
        req.is_form = true;
        req.form_data = form_data;
        captured_requests.push_back(req);
        return handler("POST", path);
    }

    HttpResponse get_raw(
        const std::string& path,
        const std::map<std::string, std::string>& params) override
    {
        CapturedRequest req;
        req.method = "GET";
        req.path = path;
        req.params = params;
        req.is_raw = true;
        captured_requests.push_back(req);
        return handler("GET", path);
    }

    std::string stream_sse_raw(
        const std::string& method,
        const std::string& path,
        const nlohmann::json& json_body,
        const std::map<std::string, std::string>& params) override
    {
        CapturedRequest req;
        req.method = method;
        req.path = path;
        req.json_body = json_body;
        req.params = params;
        req.is_stream = true;
        captured_requests.push_back(req);
        auto resp = handler(method, path);
        return resp.body;
    }
};

} // namespace testing
} // namespace ensoul
