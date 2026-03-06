using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class AuthResource
    {
        private readonly EnsoulHttpClient _client;

        public AuthResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<TokenResponse> TokenAsync(string username, string password)
        {
            var formData = new Dictionary<string, string>
            {
                ["username"] = username,
                ["password"] = password,
                ["grant_type"] = "password"
            };
            var response = await _client.PostFormAsync("/v1/auth/token", formData);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text).ToObject<TokenResponse>(JsonSerializer.Create(EnsoulHttpClient.JsonSettings));
        }

        public async Task<TokenResponse> RefreshAsync(string refreshToken)
        {
            var body = new Dictionary<string, object?>
            {
                ["refresh_token"] = refreshToken,
                ["grant_type"] = "refresh_token"
            };
            return await _client.PostAsync<TokenResponse>("/v1/auth/refresh", body);
        }

        public async Task<UserResponse> MeAsync()
            => await _client.GetAsync<UserResponse>("/v1/auth/me");

        public async Task<APIKeyResponse> CreateApiKeyAsync(
            string name,
            int expiresDays = 365,
            List<string> scopes = null)
        {
            var body = new Dictionary<string, object?> { ["name"] = name, ["expires_days"] = expiresDays };
            if (scopes != null) body["scopes"] = scopes;
            return await _client.PostAsync<APIKeyResponse>("/v1/api-keys", body);
        }

        public async Task<List<APIKeyResponse>> ListApiKeysAsync()
        {
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/api-keys");
            var text = await response.Content.ReadAsStringAsync();
            var token = JToken.Parse(text);
            if (token is JArray arr)
                return arr.Select(t => t.ToObject<APIKeyResponse>(JsonSerializer.Create(EnsoulHttpClient.JsonSettings))).ToList();
            var obj = (JObject)token;
            var items = obj["items"] as JArray;
            return items?.Select(t => t.ToObject<APIKeyResponse>(JsonSerializer.Create(EnsoulHttpClient.JsonSettings))).ToList()
                ?? new List<APIKeyResponse>();
        }

        public async Task RevokeApiKeyAsync(string keyId)
            => await _client.DeleteAsync($"/v1/api-keys/{keyId}");
    }
}
