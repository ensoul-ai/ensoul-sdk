using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class SessionsResource
    {
        private readonly EnsoulHttpClient _client;

        public SessionsResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<JObject> CreateAsync(
            string personaId,
            int tier = 0,
            string parentSessionId = null,
            string systemInstructions = null,
            Dictionary<string, object?> extras = null)
        {
            var body = new Dictionary<string, object?> { ["tier"] = tier };
            if (parentSessionId != null) body["parent_session_id"] = parentSessionId;
            if (systemInstructions != null) body["system_instructions"] = systemInstructions;
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    body[kv.Key] = kv.Value;
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/personas/{personaId}/sessions", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> GetAsync(string personaId, string sessionId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/personas/{personaId}/sessions/{sessionId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<Page<JObject>> ListAsync(string personaId, int page = 1, int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/personas/{personaId}/sessions", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get,
                $"/v1/personas/{personaId}/sessions", queryParams,
                obj => obj);
        }

        public async Task<List<JObject>> GetChildrenAsync(string personaId, string sessionId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/personas/{personaId}/sessions/{sessionId}/children");
            var text = await response.Content.ReadAsStringAsync();
            var token = JToken.Parse(text);
            if (token is JArray arr)
                return arr.Select(t => (JObject)t).ToList();
            var obj = (JObject)token;
            var items = obj["items"] as JArray;
            return items?.Select(t => (JObject)t).ToList() ?? new List<JObject>();
        }

        public async Task<JObject> AggregateChildrenAsync(
            string personaId,
            string sessionId,
            string aggregationMode = "summary")
        {
            var body = new Dictionary<string, object?> { ["aggregation_mode"] = aggregationMode };
            var response = await _client.RequestAsync(
                HttpMethod.Post,
                $"/v1/personas/{personaId}/sessions/{sessionId}/aggregate",
                json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
