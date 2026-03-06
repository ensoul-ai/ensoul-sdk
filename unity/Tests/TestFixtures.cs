using System;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;

namespace Ensoul.Tests
{
    public static class Fixtures
    {
        public const string PersonaJson = @"{
            ""id"": ""p1"",
            ""name"": ""Alice"",
            ""domain"": ""test-domain"",
            ""created_at"": ""2024-01-01T00:00:00Z""
        }";

        public const string PersonaListJson = @"{
            ""items"": [
                {""id"": ""p1"", ""name"": ""Alice"", ""domain"": ""test-domain"", ""created_at"": ""2024-01-01T00:00:00Z""},
                {""id"": ""p2"", ""name"": ""Bob"", ""domain"": ""test-domain"", ""created_at"": ""2024-01-01T00:00:00Z""}
            ],
            ""total"": 2,
            ""page"": 1,
            ""per_page"": 20,
            ""pages"": 1
        }";

        public const string ChatResponseJson = @"{
            ""response"": ""Hello, human!"",
            ""conversation_id"": ""conv-1"",
            ""token_usage"": {""input_tokens"": 10, ""output_tokens"": 5, ""total_tokens"": 15},
            ""latency_ms"": 200,
            ""model"": ""claude-3""
        }";

        public const string ConversationJson = @"{
            ""conversation_id"": ""conv-1"",
            ""persona_id"": ""p1"",
            ""messages"": [
                {""role"": ""user"", ""content"": ""Hello"", ""timestamp"": ""2024-01-01T00:00:00Z""},
                {""role"": ""assistant"", ""content"": ""Hi!"", ""timestamp"": ""2024-01-01T00:00:01Z""}
            ],
            ""created_at"": ""2024-01-01T00:00:00Z"",
            ""updated_at"": ""2024-01-01T00:00:01Z"",
            ""message_count"": 2,
            ""total_tokens"": 50
        }";

        public const string Error401Json = @"{""error"": ""Unauthorized"", ""message"": ""Token missing""}";
        public const string Error403Json = @"{""error"": ""Forbidden"", ""message"": ""Insufficient permissions""}";
        public const string Error404Json = @"{""error"": ""Not Found"", ""message"": ""Persona not found""}";
        public const string Error422Json = @"{
            ""error"": ""Validation Error"",
            ""message"": ""Request failed validation"",
            ""details"": [{""field"": ""name"", ""message"": ""Field required"", ""type"": ""missing""}]
        }";
        public const string Error429Json = @"{""error"": ""Rate Limited"", ""message"": ""Too many requests""}";
        public const string Error500Json = @"{""error"": ""Internal Server Error"", ""message"": ""Unexpected failure""}";

        public const string BatchResponseJson = @"{
            ""created"": 2,
            ""persona_ids"": [""p1"", ""p2""],
            ""batch_id"": ""batch-1"",
            ""domain"": ""test-domain""
        }";

        public const string PersonalityJson = @"{
            ""persona_id"": ""p1"",
            ""domain"": ""test-domain"",
            ""personality_data"": {""trait"": ""value""},
            ""core_values"": [""honesty"", ""kindness""]
        }";

        public const string FiltersJson = @"{
            ""domains"": [{""id"": ""d1"", ""name"": ""Test"", ""count"": 10}],
            ""total_personas"": 100
        }";

        public const string ConversationListJson = @"{
            ""items"": [
                {""conversation_id"": ""conv-1"", ""persona_id"": ""p1"", ""created_at"": ""2024-01-01T00:00:00Z"", ""updated_at"": ""2024-01-01T00:00:01Z"", ""message_count"": 5}
            ],
            ""total"": 1,
            ""page"": 1,
            ""per_page"": 20,
            ""pages"": 1,
            ""persona_id"": ""p1""
        }";

        /// Helper to create a test client with mock handler (async delegate).
        public static EnsoulClient MakeClient(Func<HttpRequestMessage, Task<HttpResponseMessage>> handler)
        {
            var mockHandler = new MockHttpHandler { Handler = handler };
            var config = new EnsoulConfig(apiKey: "test-key");
            return EnsoulClient.WithHttpClient(config, mockHandler);
        }

        /// Sync overload.
        public static EnsoulClient MakeClient(Func<HttpRequestMessage, HttpResponseMessage> handler)
        {
            return MakeClient(req => Task.FromResult(handler(req)));
        }
    }
}
