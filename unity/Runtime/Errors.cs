using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using Newtonsoft.Json.Linq;

namespace Ensoul
{
    /// <summary>
    /// Static helper that maps HTTP error responses to typed SDK exceptions.
    /// </summary>
    public static class ErrorHandler
    {
        /// <summary>Overload accepting <see cref="HttpStatusCode"/> for convenience.</summary>
        public static void ThrowForStatus(
            HttpStatusCode statusCode,
            string body,
            IDictionary<string, IEnumerable<string>>? headers = null)
        {
            ThrowForStatus((int)statusCode, body, headers);
        }

        public static void ThrowForStatus(
            int statusCode,
            string body,
            IDictionary<string, IEnumerable<string>>? headers = null)
        {
            if (statusCode < 400) return;

            JObject? parsed = null;
            try
            {
                parsed = JObject.Parse(body);
            }
            catch
            {
                // Not valid JSON — use raw body as message
            }

            var error = parsed?["error"]?.Value<string>() ?? "Unknown Error";
            var message = parsed?["message"]?.Value<string>() ?? (string.IsNullOrWhiteSpace(body) ? "Unknown error" : body);
            var requestId = parsed?["request_id"]?.Value<string>();

            switch (statusCode)
            {
                case 401:
                    throw new AuthenticationException(statusCode, error, message, requestId);

                case 403:
                    throw new AuthorizationException(statusCode, error, message, requestId);

                case 404:
                    throw new NotFoundException(statusCode, error, message, requestId);

                case 409:
                    throw new ConflictException(statusCode, error, message, requestId);

                case 422:
                {
                    var details = new List<ErrorDetail>();
                    var rawDetails = parsed?["details"] as JArray;
                    if (rawDetails != null)
                    {
                        foreach (var item in rawDetails)
                        {
                            try
                            {
                                details.Add(new ErrorDetail(
                                    field: item["field"]?.Value<string>() ?? "",
                                    message: item["message"]?.Value<string>() ?? "",
                                    type: item["type"]?.Value<string>() ?? ""
                                ));
                            }
                            catch
                            {
                                // Skip malformed detail entries
                            }
                        }
                    }
                    throw new ValidationException(statusCode, error, message, requestId, details);
                }

                case 429:
                {
                    double retryAfter = 0;
                    if (headers != null)
                    {
                        var retryAfterHeader =
                            headers.TryGetValue("retry-after", out var raLower) ? raLower.FirstOrDefault() :
                            headers.TryGetValue("Retry-After", out var raTitle) ? raTitle.FirstOrDefault() : null;

                        if (retryAfterHeader != null)
                            double.TryParse(retryAfterHeader, out retryAfter);
                    }
                    throw new RateLimitException(statusCode, error, message, requestId, retryAfter);
                }

                case 500:
                case 503:
                    throw new ServerException(statusCode, error, message, requestId);

                default:
                    throw new ApiException(statusCode, error, message, requestId);
            }
        }
    }
}
