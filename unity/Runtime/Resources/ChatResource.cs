using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;

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
    }
}
