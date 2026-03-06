using System.Collections.Generic;

namespace Ensoul
{
    internal interface IAuthProvider
    {
        Dictionary<string, string> GetAuthHeaders();
    }

    internal class ApiKeyAuth : IAuthProvider
    {
        private readonly string _apiKey;
        public ApiKeyAuth(string apiKey) => _apiKey = apiKey;
        public Dictionary<string, string> GetAuthHeaders()
            => new Dictionary<string, string> { ["X-API-Key"] = _apiKey };
    }

    internal class BearerAuth : IAuthProvider
    {
        private readonly string _token;
        public BearerAuth(string token) => _token = token;
        public Dictionary<string, string> GetAuthHeaders()
            => new Dictionary<string, string> { ["Authorization"] = $"Bearer {_token}" };
    }
}
