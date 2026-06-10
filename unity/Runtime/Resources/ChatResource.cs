using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class ChatResource
    {
        private readonly EnsoulHttpClient _client;

        public ChatResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<ChatResponse> SendAsync(
            string personaId,
            string message,
            string conversationId = null,
            string userId = null,
            int maxTokens = 1024,
            double temperature = 1.0,
            bool includeMemories = true,
            bool includeKnowledge = true)
        {
            var body = new Dictionary<string, object?>
            {
                ["message"] = message,
                ["max_tokens"] = maxTokens,
                ["temperature"] = temperature,
                ["include_memories"] = includeMemories,
                ["include_knowledge"] = includeKnowledge
            };
            if (conversationId != null) body["conversation_id"] = conversationId;
            if (userId != null) body["user_id"] = userId;
            return await _client.PostAsync<ChatResponse>($"/v1/personas/{personaId}/chat", body);
        }

        public async Task<SseStream> StreamAsync(
            string personaId,
            string message,
            Dictionary<string, object?> extras = null)
        {
            var body = new Dictionary<string, object?> { ["message"] = message };
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    body[kv.Key] = kv.Value;
            return await _client.StreamSseAsync(HttpMethod.Post, $"/v1/personas/{personaId}/chat/stream", body);
        }

        public async Task<Page<ConversationListItem>> GetConversationsAsync(
            string personaId,
            int page = 1,
            int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/personas/{personaId}/conversations", queryParams: queryParams);
            return await Page<ConversationListItem>.FromResponseAsync(
                response, _client, HttpMethod.Get,
                $"/v1/personas/{personaId}/conversations", queryParams,
                obj => obj.ToObject<ConversationListItem>(JsonSerializer.Create(EnsoulHttpClient.JsonSettings)));
        }

        public async Task<ConversationResponse> GetConversationAsync(string personaId, string conversationId)
            => await _client.GetAsync<ConversationResponse>(
                $"/v1/personas/{personaId}/conversations/{conversationId}");

        // -- Chat sessions (persisted conversation history) --------------------

        /// <summary>POST /v1/chat/sessions</summary>
        public async Task<JObject> CreateSessionAsync(
            string teamId,
            string userId,
            string domainId,
            string personaId = null,
            string mode = null,
            List<string> participantPersonaIds = null,
            string title = null)
        {
            var body = new Dictionary<string, object?>
            {
                ["team_id"] = teamId,
                ["user_id"] = userId,
                ["domain_id"] = domainId
            };
            if (personaId != null) body["persona_id"] = personaId;
            if (mode != null) body["mode"] = mode;
            if (participantPersonaIds != null) body["participant_persona_ids"] = participantPersonaIds;
            if (title != null) body["title"] = title;
            var response = await _client.RequestAsync(HttpMethod.Post, "/v1/chat/sessions", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/chat/sessions</summary>
        public async Task<JObject> ListSessionsAsync(
            string userId,
            string mode = null,
            string domainId = null,
            bool? includeArchived = null,
            int page = 1,
            int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?>
            {
                ["user_id"] = userId,
                ["page"] = page,
                ["per_page"] = perPage
            };
            if (mode != null) queryParams["mode"] = mode;
            if (domainId != null) queryParams["domain_id"] = domainId;
            if (includeArchived.HasValue) queryParams["include_archived"] = includeArchived.Value;
            var response = await _client.RequestAsync(
                HttpMethod.Get, "/v1/chat/sessions", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/chat/sessions/stats</summary>
        public async Task<JObject> SessionStatsAsync(
            string teamId,
            string startDate,
            string endDate)
        {
            var queryParams = new Dictionary<string, object?>
            {
                ["team_id"] = teamId,
                ["start_date"] = startDate,
                ["end_date"] = endDate
            };
            var response = await _client.RequestAsync(
                HttpMethod.Get, "/v1/chat/sessions/stats", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/chat/sessions/{sessionId}</summary>
        public async Task<JObject> GetSessionAsync(string sessionId, string userId = null)
        {
            var queryParams = new Dictionary<string, object?>();
            if (userId != null) queryParams["user_id"] = userId;
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/chat/sessions/{sessionId}", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>PATCH /v1/chat/sessions/{sessionId}</summary>
        public async Task<JObject> UpdateSessionAsync(
            string sessionId,
            string title = null,
            bool? isArchived = null)
        {
            var body = new Dictionary<string, object?>();
            if (title != null) body["title"] = title;
            if (isArchived.HasValue) body["is_archived"] = isArchived.Value;
            var response = await _client.RequestAsync(
                new HttpMethod("PATCH"), $"/v1/chat/sessions/{sessionId}", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>DELETE /v1/chat/sessions/{sessionId} — 204 No Content.</summary>
        public async Task DeleteSessionAsync(string sessionId)
        {
            await _client.RequestAsync(HttpMethod.Delete, $"/v1/chat/sessions/{sessionId}");
        }

        /// <summary>POST /v1/chat/sessions/{sessionId}/archive</summary>
        public async Task<JObject> ArchiveSessionAsync(string sessionId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/chat/sessions/{sessionId}/archive",
                json: new Dictionary<string, object?>());
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/chat/sessions/{sessionId}/messages</summary>
        public async Task<JObject> AddMessageAsync(
            string sessionId,
            string role,
            string content,
            int? inputTokens = null,
            int? outputTokens = null,
            string modelUsed = null,
            Dictionary<string, object?> metadata = null)
        {
            var body = new Dictionary<string, object?>
            {
                ["role"] = role,
                ["content"] = content
            };
            if (inputTokens.HasValue) body["input_tokens"] = inputTokens.Value;
            if (outputTokens.HasValue) body["output_tokens"] = outputTokens.Value;
            if (modelUsed != null) body["model_used"] = modelUsed;
            if (metadata != null) body["metadata"] = metadata;
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/chat/sessions/{sessionId}/messages", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/chat/sessions/{sessionId}/messages — returns a bare JSON array.</summary>
        public async Task<JArray> GetMessagesAsync(
            string sessionId,
            int? limit = null,
            int? offset = null)
        {
            var queryParams = new Dictionary<string, object?>();
            if (limit.HasValue) queryParams["limit"] = limit.Value;
            if (offset.HasValue) queryParams["offset"] = offset.Value;
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/chat/sessions/{sessionId}/messages", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JArray.Parse(text);
        }
    }
}
