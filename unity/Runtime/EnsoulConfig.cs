using System;
using System.Collections.Generic;

namespace Ensoul
{
    public class EnsoulConfig
    {
        public const string DefaultBaseUrl = "https://api.ensoul-ai.com";
        // Inference endpoints (domain generation, chat) run real-time LLM calls that
        // routinely take 30-120s+; 30s timed out the documented domains.generate "easy path".
        public static readonly TimeSpan DefaultTimeout = TimeSpan.FromSeconds(300);
        public const int DefaultMaxRetries = 2;
        public const string ApiVersion = "v1";

        public string BaseUrl { get; }
        public string? ApiKey { get; }
        public string? BearerToken { get; }
        public TimeSpan Timeout { get; }
        public int MaxRetries { get; }
        public Dictionary<string, string> CustomHeaders { get; }

        public string ApiUrl => $"{BaseUrl.TrimEnd('/')}/{ApiVersion}";

        public EnsoulConfig(
            string? baseUrl = null,
            string? apiKey = null,
            string? bearerToken = null,
            TimeSpan? timeout = null,
            int maxRetries = DefaultMaxRetries,
            Dictionary<string, string>? customHeaders = null)
        {
            BaseUrl = baseUrl ?? Environment.GetEnvironmentVariable("ENSOUL_BASE_URL") ?? DefaultBaseUrl;
            ApiKey = apiKey ?? Environment.GetEnvironmentVariable("ENSOUL_API_KEY");
            BearerToken = bearerToken;
            Timeout = timeout ?? DefaultTimeout;
            MaxRetries = maxRetries;
            CustomHeaders = customHeaders ?? new Dictionary<string, string>();
        }
    }
}
