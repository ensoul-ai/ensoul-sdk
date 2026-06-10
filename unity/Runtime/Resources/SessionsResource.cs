using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    /// <summary>
    /// Sessions resource. Hierarchical session orchestration under
    /// <c>/v1/sessions/*</c>.
    ///
    /// As of API 0.2.0 these routes are no longer nested under a persona: a
    /// session is created against the authenticated team/user context, so
    /// <see cref="CreateAsync"/> no longer takes a <c>personaId</c> (the
    /// <c>SessionCreate</c> body has no persona field). This is a distinct
    /// family from <c>/v1/chat/sessions</c> (chat-message threads).
    /// </summary>
    public class SessionsResource
    {
        private readonly EnsoulHttpClient _client;

        public SessionsResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        /// <summary>POST /v1/sessions — create a session (<c>SessionCreate</c>).</summary>
        public async Task<JObject> CreateAsync(
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
            var response = await _client.RequestAsync(HttpMethod.Post, "/v1/sessions", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/sessions/{sessionId}</summary>
        public async Task<JObject> GetAsync(string sessionId)
        {
            var response = await _client.RequestAsync(HttpMethod.Get, $"/v1/sessions/{sessionId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>DELETE /v1/sessions/{sessionId}</summary>
        public async Task DeleteAsync(string sessionId, bool cancelChildren = false)
        {
            var suffix = cancelChildren ? "?cancel_children=true" : "?cancel_children=false";
            await _client.DeleteAsync($"/v1/sessions/{sessionId}{suffix}");
        }

        /// <summary>GET /v1/sessions — list sessions (paginated).</summary>
        public async Task<Page<JObject>> ListAsync(
            int? tier = null,
            string status = null,
            string parentSessionId = null,
            int page = 1,
            int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            if (tier.HasValue) queryParams["tier"] = tier.Value;
            if (status != null) queryParams["status"] = status;
            if (parentSessionId != null) queryParams["parent_session_id"] = parentSessionId;
            var response = await _client.RequestAsync(
                HttpMethod.Get, "/v1/sessions", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get, "/v1/sessions", queryParams,
                obj => obj);
        }

        /// <summary>GET /v1/sessions/hierarchy — full session tree.</summary>
        public async Task<JObject> HierarchyAsync()
        {
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/sessions/hierarchy");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/sessions/info — session-system info.</summary>
        public async Task<JObject> InfoAsync()
        {
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/sessions/info");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/sessions/stats/summary — session statistics.</summary>
        public async Task<JObject> StatsAsync()
        {
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/sessions/stats/summary");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/sessions/{sessionId}/children</summary>
        public async Task<List<JObject>> GetChildrenAsync(string sessionId, int page = 1, int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/sessions/{sessionId}/children", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            var token = JToken.Parse(text);
            if (token is JArray arr)
                return arr.Select(t => (JObject)t).ToList();
            var obj = (JObject)token;
            var items = obj["items"] as JArray;
            return items?.Select(t => (JObject)t).ToList() ?? new List<JObject>();
        }

        /// <summary>POST /v1/sessions/{sessionId}/aggregate (<c>AggregateChildrenRequest</c>).</summary>
        public async Task<JObject> AggregateChildrenAsync(
            string sessionId,
            string aggregationMode = "summary")
        {
            var body = new Dictionary<string, object?> { ["aggregation_mode"] = aggregationMode };
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/sessions/{sessionId}/aggregate", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
