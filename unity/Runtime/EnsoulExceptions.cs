using System;
using System.Collections.Generic;

namespace Ensoul
{
    /// Base class for all Ensoul SDK exceptions.
    public class EnsoulException : Exception
    {
        public EnsoulException(string message) : base(message) { }
        public EnsoulException(string message, Exception inner) : base(message, inner) { }
    }

    /// Returned when the API responds with an error status code.
    public class ApiException : EnsoulException
    {
        public int StatusCode { get; }
        public string Error { get; }
        public string? RequestId { get; }

        public ApiException(int statusCode, string error, string message, string? requestId = null)
            : base(message)
        {
            StatusCode = statusCode;
            Error = error;
            RequestId = requestId;
        }
    }

    /// HTTP 401 — authentication failed or token missing/expired.
    public class AuthenticationException : ApiException
    {
        public AuthenticationException(int statusCode, string error, string message, string? requestId = null)
            : base(statusCode, error, message, requestId) { }
    }

    /// HTTP 403 — authenticated but not permitted.
    public class AuthorizationException : ApiException
    {
        public string? RequiredTier { get; }
        public string? CurrentTier { get; }

        public AuthorizationException(int statusCode, string error, string message,
            string? requestId = null, string? requiredTier = null, string? currentTier = null)
            : base(statusCode, error, message, requestId)
        {
            RequiredTier = requiredTier;
            CurrentTier = currentTier;
        }
    }

    /// HTTP 404 — requested resource does not exist.
    public class NotFoundException : ApiException
    {
        public string? ResourceType { get; }
        public string? ResourceId { get; }

        public NotFoundException(int statusCode, string error, string message,
            string? requestId = null, string? resourceType = null, string? resourceId = null)
            : base(statusCode, error, message, requestId)
        {
            ResourceType = resourceType;
            ResourceId = resourceId;
        }
    }

    /// HTTP 409 — resource already exists or state conflict.
    public class ConflictException : ApiException
    {
        public ConflictException(int statusCode, string error, string message, string? requestId = null)
            : base(statusCode, error, message, requestId) { }
    }

    /// HTTP 422 — request body failed validation.
    public class ValidationException : ApiException
    {
        public List<ErrorDetail> Details { get; }

        public ValidationException(int statusCode, string error, string message,
            string? requestId = null, List<ErrorDetail>? details = null)
            : base(statusCode, error, message, requestId)
        {
            Details = details ?? new List<ErrorDetail>();
        }
    }

    /// HTTP 429 — too many requests.
    public class RateLimitException : ApiException
    {
        /// Seconds to wait before retrying (0 if header not present).
        public double RetryAfter { get; }

        public RateLimitException(int statusCode, string error, string message,
            string? requestId = null, double retryAfter = 0)
            : base(statusCode, error, message, requestId)
        {
            RetryAfter = retryAfter;
        }
    }

    /// HTTP 500 / 503 — server-side failure.
    public class ServerException : ApiException
    {
        public ServerException(int statusCode, string error, string message, string? requestId = null)
            : base(statusCode, error, message, requestId) { }
    }

    /// Field-level validation detail.
    public class ErrorDetail
    {
        public string Field { get; }
        public string Message { get; }
        public string Type { get; }

        public ErrorDetail(string field, string message, string type)
        {
            Field = field;
            Message = message;
            Type = type;
        }
    }
}
