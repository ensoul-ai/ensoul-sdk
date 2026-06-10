using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    /// <summary>
    /// Memory resource. Maps to the <c>/v1/memory/*</c> API namespace.
    ///
    /// As of API 0.2.0 the memory routes were rebased off
    /// <c>/v1/personas/{id}/memories</c> onto <c>/v1/memory/{personaId}</c>.
    /// <c>MemoryCreate</c> has no memory_type / importance fields — only
    /// content, source, and optional references.
    /// </summary>
    public class MemoryResource
    {
        private readonly EnsoulHttpClient _client;

        public MemoryResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        /// <summary>GET /v1/memory/stats — global memory statistics.</summary>
        public async Task<JObject> StatsAsync()
        {
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/memory/stats");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/memory/{personaId} — add a memory (<c>MemoryCreate</c>).</summary>
        public async Task<JObject> CreateAsync(
            string personaId,
            string content,
            string source = "user",
            Dictionary<string, object?> references = null)
        {
            var body = new Dictionary<string, object?>
            {
                ["content"] = content,
                ["source"] = source
            };
            if (references != null) body["references"] = references;
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/memory/{personaId}", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>
        /// GET /v1/memory/{personaId} — list memories.
        ///
        /// Returns the <c>MemoriesResponse</c> shape
        /// <c>{ persona_id, memories, working_memory, total }</c> (not a paginated
        /// envelope — the API does not page this route).
        /// </summary>
        public async Task<JObject> ListAsync(string personaId, int limit = 50, int offset = 0)
        {
            var queryParams = new Dictionary<string, object?> { ["limit"] = limit, ["offset"] = offset };
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/memory/{personaId}", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>DELETE /v1/memory/{personaId} — delete all memories for a persona.</summary>
        public async Task ClearAsync(string personaId)
            => await _client.DeleteAsync($"/v1/memory/{personaId}");

        /// <summary>DELETE /v1/memory/{personaId}/{memoryId} — delete one memory.</summary>
        public async Task DeleteAsync(string personaId, string memoryId)
            => await _client.DeleteAsync($"/v1/memory/{personaId}/{memoryId}");

        /// <summary>PATCH /v1/memory/{personaId}/{memoryId}/access — record an access.</summary>
        public async Task<JObject> UpdateAccessAsync(string personaId, string memoryId)
        {
            var response = await _client.RequestAsync(
                new HttpMethod("PATCH"), $"/v1/memory/{personaId}/{memoryId}/access",
                json: new Dictionary<string, object?>());
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/memory/{personaId}/batch — add many memories at once.</summary>
        public async Task<JObject> BatchCreateAsync(
            string personaId,
            List<Dictionary<string, object?>> memories)
        {
            var body = new Dictionary<string, object?> { ["memories"] = memories };
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/memory/{personaId}/batch", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/memory/{personaId}/consolidate — consolidate memories.</summary>
        public async Task<JObject> ConsolidateAsync(string personaId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/memory/{personaId}/consolidate",
                json: new Dictionary<string, object?>());
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/memory/{personaId}/generate — generate memories.</summary>
        public async Task<JObject> GenerateAsync(
            string personaId,
            Dictionary<string, object?> options = null)
        {
            var body = options ?? new Dictionary<string, object?>();
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/memory/{personaId}/generate", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/memory/{personaId}/working — working-memory snapshot.</summary>
        public async Task<JObject> WorkingAsync(string personaId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/memory/{personaId}/working");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/memory/{personaId}/knowledge — retrieve RAG knowledge.</summary>
        public async Task<JObject> GetKnowledgeAsync(string personaId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/memory/{personaId}/knowledge");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/memory/{personaId}/knowledge — add RAG knowledge (<c>KnowledgeCreate</c>).</summary>
        public async Task<JObject> AddKnowledgeAsync(string personaId, string content, string source)
        {
            var body = new Dictionary<string, object?> { ["content"] = content, ["source"] = source };
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/memory/{personaId}/knowledge", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
