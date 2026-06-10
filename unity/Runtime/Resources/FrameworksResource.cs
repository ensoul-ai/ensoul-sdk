using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class FrameworksResource
    {
        private readonly EnsoulHttpClient _client;

        public FrameworksResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<Page<JObject>> ListAsync(int page = 1, int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/frameworks", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get, "/v1/frameworks", queryParams,
                obj => obj);
        }

        public async Task<JObject> GetAsync(string frameworkId)
        {
            var response = await _client.RequestAsync(HttpMethod.Get, $"/v1/frameworks/{frameworkId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> CreateAsync(Dictionary<string, object?> body)
        {
            var response = await _client.RequestAsync(HttpMethod.Post, "/v1/frameworks", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> UpdateAsync(string frameworkId, Dictionary<string, object?> body)
        {
            var response = await _client.RequestAsync(HttpMethod.Put, $"/v1/frameworks/{frameworkId}", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task DeleteAsync(string frameworkId)
            => await _client.DeleteAsync($"/v1/frameworks/{frameworkId}");

        /// <summary>GET /v1/frameworks/{frameworkId}/validations</summary>
        public async Task<JObject> ValidationsAsync(string frameworkId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/frameworks/{frameworkId}/validations");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<List<JObject>> GetInstrumentsAsync(string frameworkId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/frameworks/{frameworkId}/instruments");
            var text = await response.Content.ReadAsStringAsync();
            var token = JToken.Parse(text);
            if (token is JArray arr)
                return arr.Select(t => (JObject)t).ToList();
            var obj = (JObject)token;
            var items = obj["items"] as JArray;
            return items?.Select(t => (JObject)t).ToList() ?? new List<JObject>();
        }
    }
}
