#pragma once

#include <stdexcept>
#include <string>
#include <vector>
#include <map>

namespace ensoul {

class EnsoulError : public std::runtime_error {
public:
    explicit EnsoulError(const std::string& message)
        : std::runtime_error(message) {}
};

class ApiError : public EnsoulError {
public:
    int status_code;
    std::string error;
    std::string request_id;

    ApiError(int status_code, const std::string& error,
             const std::string& message, const std::string& request_id = "")
        : EnsoulError(message), status_code(status_code),
          error(error), request_id(request_id) {}
};

class AuthenticationError : public ApiError {
public:
    using ApiError::ApiError;
};

class AuthorizationError : public ApiError {
public:
    std::string required_tier;
    std::string current_tier;

    AuthorizationError(int status_code, const std::string& error,
                       const std::string& message, const std::string& request_id = "",
                       const std::string& required_tier = "",
                       const std::string& current_tier = "")
        : ApiError(status_code, error, message, request_id),
          required_tier(required_tier), current_tier(current_tier) {}
};

class NotFoundError : public ApiError {
public:
    std::string resource_type;
    std::string resource_id;

    NotFoundError(int status_code, const std::string& error,
                  const std::string& message, const std::string& request_id = "",
                  const std::string& resource_type = "",
                  const std::string& resource_id = "")
        : ApiError(status_code, error, message, request_id),
          resource_type(resource_type), resource_id(resource_id) {}
};

class RateLimitError : public ApiError {
public:
    int retry_after;

    RateLimitError(int status_code, const std::string& error,
                   const std::string& message, const std::string& request_id = "",
                   int retry_after = 0)
        : ApiError(status_code, error, message, request_id),
          retry_after(retry_after) {}
};

struct ErrorDetail {
    std::string field;
    std::string message;
    std::string type;
};

class ValidationError : public ApiError {
public:
    std::vector<ErrorDetail> details;

    ValidationError(int status_code, const std::string& error,
                    const std::string& message, const std::string& request_id = "",
                    const std::vector<ErrorDetail>& details = {})
        : ApiError(status_code, error, message, request_id),
          details(details) {}
};

class ConflictError : public ApiError {
public:
    using ApiError::ApiError;
};

class ServerError : public ApiError {
public:
    using ApiError::ApiError;
};

void raise_for_status(
    int status_code,
    const std::string& body,
    const std::map<std::string, std::string>& headers = {});

} // namespace ensoul
