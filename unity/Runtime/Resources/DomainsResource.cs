using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class DomainsResource
    {
        private readonly EnsoulHttpClient _client;

        public DomainsResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<Page<JObject>> ListAsync(
            int page = 1,
            int perPage = 20,
            Dictionary<string, object?> extras = null)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    queryParams[kv.Key] = kv.Value;

            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/domains", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get, "/v1/domains", queryParams,
                obj => obj);
        }

        public async Task<JObject> GetAsync(string domainId)
        {
            var response = await _client.RequestAsync(HttpMethod.Get, $"/v1/domains/{domainId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> CreateAsync(Dictionary<string, object?> body)
        {
            var response = await _client.RequestAsync(HttpMethod.Post, "/v1/domains", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> UpdateAsync(string domainId, Dictionary<string, object?> body)
        {
            var response = await _client.RequestAsync(HttpMethod.Put, $"/v1/domains/{domainId}", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task DeleteAsync(string domainId)
            => await _client.DeleteAsync($"/v1/domains/{domainId}");

        public async Task<JObject> ValidateAsync(string domainId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/domains/{domainId}/validate", json: new Dictionary<string, object?>());
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
