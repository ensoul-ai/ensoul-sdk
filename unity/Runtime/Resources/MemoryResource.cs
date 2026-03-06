using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class MemoryResource
    {
        private readonly EnsoulHttpClient _client;

        public MemoryResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<JObject> CreateAsync(
            string personaId,
            string content,
            string memoryType = "episodic",
            double importance = 0.5,
            Dictionary<string, object?> metadata = null)
        {
            var body = new Dictionary<string, object?>
            {
                ["content"] = content,
                ["memory_type"] = memoryType,
                ["importance"] = importance
            };
            if (metadata != null) body["metadata"] = metadata;
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/personas/{personaId}/memories", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<Page<JObject>> ListAsync(string personaId, int page = 1, int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/personas/{personaId}/memories", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get,
                $"/v1/personas/{personaId}/memories", queryParams,
                obj => obj);
        }

        public async Task<JObject> GetAsync(string personaId, string memoryId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/personas/{personaId}/memories/{memoryId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task DeleteAsync(string personaId, string memoryId)
            => await _client.DeleteAsync($"/v1/personas/{personaId}/memories/{memoryId}");

        public async Task<JObject> BatchCreateAsync(
            string personaId,
            List<Dictionary<string, object?>> memories)
        {
            var body = new Dictionary<string, object?> { ["memories"] = memories };
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/personas/{personaId}/memories/batch", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> ConsolidateAsync(string personaId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/personas/{personaId}/memories/consolidate",
                json: new Dictionary<string, object?>());
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> QueryKnowledgeAsync(string personaId, string query)
        {
            var body = new Dictionary<string, object?> { ["query"] = query };
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/personas/{personaId}/knowledge/query", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
