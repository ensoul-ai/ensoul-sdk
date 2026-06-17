using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul
{
    /// <summary>
    /// Internal HTTP transport layer. Handles auth, retries, rate limits, and error mapping.
    /// </summary>
    public class EnsoulHttpClient : IDisposable
    {
        private const string UserAgent = "ensoul-csharp/0.1.0";
        private static readonly HashSet<int> RetryStatusCodes = new HashSet<int> { 429, 500, 502, 503 };
        private static readonly JsonSerializerSettings NullIgnoreSettings =
            new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore };

        /// <summary>Shared JSON serializer settings used by resources for deserialization.</summary>
        public static readonly JsonSerializerSettings JsonSettings =
            new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore };

        private readonly EnsoulConfig _config;
        private readonly HttpClient _http;
        private readonly IAuthProvider _auth;
        private readonly RateLimitTracker _rateLimiter;
        private readonly Random _random = new Random();
        private bool _disposed;

        public EnsoulHttpClient(EnsoulConfig config, HttpMessageHandler? handler = null)
        {
            _config = config;
            _auth = BuildAuth(config);
            _rateLimiter = new RateLimitTracker();

            _http = handler != null
                ? new HttpClient(handler)
                : new HttpClient();

            _http.Timeout = config.Timeout;
            _http.DefaultRequestHeaders.UserAgent.TryParseAdd(UserAgent);
            _http.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/json"));

            foreach (var kv in config.CustomHeaders)
                _http.DefaultRequestHeaders.TryAddWithoutValidation(kv.Key, kv.Value);
        }

        private static IAuthProvider BuildAuth(EnsoulConfig config)
        {
            if (config.ApiKey != null) return new ApiKeyAuth(config.ApiKey);
            if (config.BearerToken != null) return new BearerAuth(config.BearerToken);
            return new ApiKeyAuth("");
        }

        public static string NormalizePath(string path)
        {
            var versionPrefix = $"/{EnsoulConfig.ApiVersion}/";
            var noSlash = path.TrimStart('/');
            if (noSlash.StartsWith($"{EnsoulConfig.ApiVersion}/") || path.StartsWith(versionPrefix))
                return path.StartsWith("/") ? path : $"/{path}";
            return $"/{EnsoulConfig.ApiVersion}/{noSlash}";
        }

        private double ComputeRetryWait(int attempt, double? retryAfter)
        {
            if (retryAfter.HasValue && retryAfter.Value > 0)
                return retryAfter.Value;
            var baseWait = Math.Min(0.5 * Math.Pow(2, attempt), 30.0);
            var jitter = _random.NextDouble();
            return baseWait + jitter;
        }

        private string BuildUrl(string normalizedPath, Dictionary<string, object?>? queryParams)
        {
            var baseUri = new Uri(_config.BaseUrl.TrimEnd('/'));
            var url = new Uri(baseUri, normalizedPath).ToString();

            if (queryParams == null || queryParams.Count == 0)
                return url;

            var queryParts = new List<string>();
            foreach (var kv in queryParams)
            {
                if (kv.Value == null) continue;
                queryParts.Add($"{Uri.EscapeDataString(kv.Key)}={Uri.EscapeDataString(kv.Value.ToString()!)}");
            }

            return queryParts.Count > 0 ? $"{url}?{string.Join("&", queryParts)}" : url;
        }

        private string BuildRawUrl(string path, Dictionary<string, object?>? queryParams)
        {
            var baseUri = new Uri(_config.BaseUrl.TrimEnd('/'));
            var url = new Uri(baseUri, path.StartsWith("/") ? path : $"/{path}").ToString();

            if (queryParams == null || queryParams.Count == 0)
                return url;

            var queryParts = new List<string>();
            foreach (var kv in queryParams)
            {
                if (kv.Value == null) continue;
                queryParts.Add($"{Uri.EscapeDataString(kv.Key)}={Uri.EscapeDataString(kv.Value.ToString()!)}");
            }

            return queryParts.Count > 0 ? $"{url}?{string.Join("&", queryParts)}" : url;
        }

        public async Task<HttpResponseMessage> RequestAsync(
            HttpMethod method,
            string path,
            Dictionary<string, object?>? json = null,
            Dictionary<string, object?>? queryParams = null,
            Dictionary<string, string>? headers = null,
            bool stream = false,
            CancellationToken cancellationToken = default)
        {
            var normalizedPath = NormalizePath(path);
            Exception? lastException = null;

            for (int attempt = 0; attempt <= _config.MaxRetries; attempt++)
            {
                var (shouldWait, waitSeconds) = _rateLimiter.ShouldWait();
                if (shouldWait)
                    await Task.Delay(TimeSpan.FromSeconds(waitSeconds), cancellationToken);

                try
                {
                    var url = BuildUrl(normalizedPath, queryParams);
                    var request = new HttpRequestMessage(method, url);

                    // Auth headers
                    foreach (var kv in _auth.GetAuthHeaders())
                        request.Headers.TryAddWithoutValidation(kv.Key, kv.Value);

                    // Custom per-request headers
                    if (headers != null)
                        foreach (var kv in headers)
                            request.Headers.TryAddWithoutValidation(kv.Key, kv.Value);

                    // JSON body
                    if (json != null)
                    {
                        var bodyJson = JsonConvert.SerializeObject(json, NullIgnoreSettings);
                        request.Content = new StringContent(bodyJson, Encoding.UTF8, "application/json");
                    }

                    var completionOption = stream
                        ? HttpCompletionOption.ResponseHeadersRead
                        : HttpCompletionOption.ResponseContentRead;

                    var response = await _http.SendAsync(request, completionOption, cancellationToken);

                    // Update rate limit state from response headers
                    var responseHeaders = response.Headers
                        .ToDictionary(h => h.Key, h => (IEnumerable<string>)h.Value);
                    _rateLimiter.Update(responseHeaders);

                    var statusCode = (int)response.StatusCode;

                    // Retry on transient errors (not on last attempt)
                    if (RetryStatusCodes.Contains(statusCode) && attempt < _config.MaxRetries)
                    {
                        double? retryAfter = null;
                        if (statusCode == 429 &&
                            response.Headers.TryGetValues("Retry-After", out var retryAfterValues))
                        {
                            if (double.TryParse(retryAfterValues.FirstOrDefault(), out var ra))
                                retryAfter = ra;
                        }
                        var waitMs = (int)(ComputeRetryWait(attempt, retryAfter) * 1000);
                        await Task.Delay(waitMs, cancellationToken);
                        response.Dispose();
                        continue;
                    }

                    // Throw for error status codes
                    if (!stream && statusCode >= 400)
                    {
                        var bodyText = await response.Content.ReadAsStringAsync();
                        ErrorHandler.ThrowForStatus(statusCode, bodyText, responseHeaders);
                    }

                    return response;
                }
                catch (EnsoulException)
                {
                    // Re-throw SDK errors immediately — do not retry
                    throw;
                }
                catch (Exception ex) when (!(ex is OperationCanceledException))
                {
                    lastException = ex;
                    if (attempt < _config.MaxRetries)
                    {
                        var waitMs = (int)(ComputeRetryWait(attempt, null) * 1000);
                        await Task.Delay(waitMs, cancellationToken);
                    }
                }
            }

            throw lastException ?? new EnsoulException("Exhausted retries without a response");
        }

        public async Task<T> GetAsync<T>(
            string path,
            Dictionary<string, object?>? queryParams = null,
            CancellationToken cancellationToken = default)
        {
            var response = await RequestAsync(HttpMethod.Get, path, queryParams: queryParams,
                cancellationToken: cancellationToken);
            var body = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<T>(body, NullIgnoreSettings)!;
        }

        /// <summary>
        /// Raw GET — does NOT prepend /v1/. Used for health endpoints like /health.
        /// </summary>
        public async Task<HttpResponseMessage> GetRawAsync(
            string path,
            Dictionary<string, object?>? queryParams = null,
            CancellationToken cancellationToken = default)
        {
            var url = BuildRawUrl(path, queryParams);
            var request = new HttpRequestMessage(HttpMethod.Get, url);
            foreach (var kv in _auth.GetAuthHeaders())
                request.Headers.TryAddWithoutValidation(kv.Key, kv.Value);

            var response = await _http.SendAsync(request, cancellationToken);
            var statusCode = (int)response.StatusCode;
            if (statusCode >= 400)
            {
                var bodyText = await response.Content.ReadAsStringAsync();
                var responseHeaders = response.Headers
                    .ToDictionary(h => h.Key, h => (IEnumerable<string>)h.Value);
                ErrorHandler.ThrowForStatus(statusCode, bodyText, responseHeaders);
            }
            return response;
        }

        public async Task<T> PostAsync<T>(
            string path,
            Dictionary<string, object?>? json = null,
            Dictionary<string, object?>? queryParams = null,
            CancellationToken cancellationToken = default)
        {
            var response = await RequestAsync(HttpMethod.Post, path, json: json,
                queryParams: queryParams, cancellationToken: cancellationToken);
            var body = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<T>(body, NullIgnoreSettings)!;
        }

        public async Task<T> PutAsync<T>(
            string path,
            Dictionary<string, object?>? json = null,
            CancellationToken cancellationToken = default)
        {
            var response = await RequestAsync(HttpMethod.Put, path, json: json,
                cancellationToken: cancellationToken);
            var body = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<T>(body, NullIgnoreSettings)!;
        }

        public async Task<T> PatchAsync<T>(
            string path,
            Dictionary<string, object?>? json = null,
            CancellationToken cancellationToken = default)
        {
            var response = await RequestAsync(new HttpMethod("PATCH"), path, json: json,
                cancellationToken: cancellationToken);
            var body = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<T>(body, NullIgnoreSettings)!;
        }

        public async Task DeleteAsync(
            string path,
            CancellationToken cancellationToken = default)
        {
            await RequestAsync(HttpMethod.Delete, path, cancellationToken: cancellationToken);
        }

        /// <summary>POST form-encoded data; returns the raw HttpResponseMessage.</summary>
        public async Task<HttpResponseMessage> PostFormAsync(
            string path,
            Dictionary<string, string> formData,
            CancellationToken cancellationToken = default)
        {
            var normalizedPath = NormalizePath(path);
            var url = BuildUrl(normalizedPath, null);
            var request = new HttpRequestMessage(HttpMethod.Post, url);

            foreach (var kv in _auth.GetAuthHeaders())
                request.Headers.TryAddWithoutValidation(kv.Key, kv.Value);

            request.Content = new FormUrlEncodedContent(
                formData.Select(kv => new KeyValuePair<string, string>(kv.Key, kv.Value)));

            var response = await _http.SendAsync(request, cancellationToken);
            var statusCode = (int)response.StatusCode;

            if (statusCode >= 400)
            {
                var bodyText = await response.Content.ReadAsStringAsync();
                var responseHeaders = response.Headers
                    .ToDictionary(h => h.Key, h => (IEnumerable<string>)h.Value);
                ErrorHandler.ThrowForStatus(statusCode, bodyText, responseHeaders);
            }
            return response;
        }

        /// <summary>POST form-encoded data and deserialize the response body to T.</summary>
        public async Task<T> PostFormAsync<T>(
            string path,
            Dictionary<string, string> formData,
            CancellationToken cancellationToken = default)
        {
            var response = await PostFormAsync(path, formData, cancellationToken);
            var bodyText = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<T>(bodyText, NullIgnoreSettings)!;
        }

        public async Task<SseStream> StreamSseAsync(
            HttpMethod method,
            string path,
            Dictionary<string, object?>? json = null,
            Dictionary<string, object?>? queryParams = null,
            CancellationToken cancellationToken = default)
        {
            var response = await RequestAsync(method, path, json: json, queryParams: queryParams,
                stream: true, cancellationToken: cancellationToken);
            // RequestAsync skips the error check for streams (a 2xx body is the
            // live stream and must not be consumed here). A 4xx/5xx body is an
            // error payload, not SSE, so surface it rather than returning a
            // stream that would parse the error as events.
            var statusCode = (int)response.StatusCode;
            if (statusCode >= 400)
            {
                var bodyText = await response.Content.ReadAsStringAsync();
                var responseHeaders = response.Headers
                    .ToDictionary(h => h.Key, h => (IEnumerable<string>)h.Value);
                ErrorHandler.ThrowForStatus(statusCode, bodyText, responseHeaders);
            }
            return new SseStream(response);
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                _http.Dispose();
                _disposed = true;
            }
        }
    }
}
