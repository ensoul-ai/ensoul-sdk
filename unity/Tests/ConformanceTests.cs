using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using NUnit.Framework;

namespace Ensoul.Tests
{
    /// <summary>
    /// Cross-SDK conformance tests for the Unity C# SDK.
    ///
    /// These tests run against a mock server started by the conformance orchestrator.
    /// They are automatically skipped when ENSOUL_CONFORMANCE_URL is not set,
    /// so regular test runs are unaffected.
    /// </summary>
    [TestFixture]
    public class ConformanceTests
    {
        private EnsoulClient _client;
        private string _conformanceUrl;

        [SetUp]
        public void SetUp()
        {
            _conformanceUrl = Environment.GetEnvironmentVariable("ENSOUL_CONFORMANCE_URL");
            if (string.IsNullOrEmpty(_conformanceUrl))
            {
                Assert.Ignore("ENSOUL_CONFORMANCE_URL not set");
                return;
            }

            var config = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "sk_test_123",
                maxRetries: 0
            );
            _client = new EnsoulClient(config);
        }

        [TearDown]
        public void TearDown() => _client?.Dispose();

        // ---------------------------------------------------------------------------
        // Personas
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestPersonaCreate()
        {
            var persona = await _client.Personas.CreateAsync(
                name: "Test Persona",
                domain: "test_domain",
                personalityData: new Dictionary<string, object?>
                {
                    ["trait_a"] = 75,
                    ["trait_b"] = 50
                }
            );

            Assert.That(persona.Id, Is.EqualTo("p_test_001"));
            Assert.That(persona.Name, Is.EqualTo("Test Persona"));
            Assert.That(persona.Domain, Is.EqualTo("test_domain"));
        }

        [Test]
        public async Task TestPersonaGet()
        {
            var persona = await _client.Personas.GetAsync("p_test_001");

            Assert.That(persona.Id, Is.EqualTo("p_test_001"));
            Assert.That(persona.Name, Is.EqualTo("Test Persona"));
            Assert.That(persona.Domain, Is.EqualTo("test_domain"));
        }

        [Test]
        public async Task TestPersonaListPagination()
        {
            var page = await _client.Personas.ListAsync(page: 1, perPage: 10);

            Assert.That(page.Items.Count, Is.GreaterThanOrEqualTo(1));
            Assert.That(page.Total, Is.EqualTo(25));
            Assert.That(page.PageNumber, Is.EqualTo(1));
            Assert.That(page.PerPage, Is.EqualTo(10));
            Assert.That(page.Pages, Is.EqualTo(3));
        }

        [Test]
        public void TestPersonaNotFound()
        {
            var ex = Assert.ThrowsAsync<NotFoundException>(async () =>
                await _client.Personas.GetAsync("nonexistent_persona_id")
            );

            Assert.That(ex.StatusCode, Is.EqualTo(404));
        }

        [Test]
        public async Task TestPersonaUpdate()
        {
            var persona = await _client.Personas.UpdateAsync(
                "p_test_001",
                new Dictionary<string, object?>
                {
                    ["name"] = "Updated Persona"
                }
            );

            Assert.That(persona.Name, Is.EqualTo("Updated Persona"));
        }

        [Test]
        public void TestPersonaDelete()
        {
            Assert.DoesNotThrowAsync(async () =>
                await _client.Personas.DeleteAsync("p_test_001")
            );
        }

        // ---------------------------------------------------------------------------
        // Chat
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestChatSend()
        {
            var response = await _client.Chat.SendAsync(
                personaId: "p_test_001",
                message: "Hello, how are you?"
            );

            Assert.That(response.Response, Is.Not.Empty);
            Assert.That(response.ConversationId, Is.Not.Empty);
            Assert.That(response.TokenUsage, Is.Not.Null);
            Assert.That(response.TokenUsage.TotalTokens, Is.GreaterThan(0));
        }

        [Test]
        public async Task TestChatStreamSse()
        {
            using var stream = await _client.Chat.StreamAsync(
                personaId: "p_test_001",
                message: "Tell me about yourself."
            );

            var events = new List<ChatStreamEvent>();
            await foreach (var sseEvent in stream.Events())
            {
                events.Add(SseParser.ParseChatEvent(sseEvent));
            }

            Assert.That(events.Count, Is.EqualTo(5));

            // Check chunk ordering
            for (int i = 0; i < events.Count; i++)
            {
                Assert.That(events[i].ChunkIndex, Is.EqualTo(i));
            }

            // Final event
            var lastEvent = events[events.Count - 1];
            Assert.That(lastEvent.IsFinal, Is.True);
            Assert.That(lastEvent.TokenUsage, Is.Not.Null);

            // Non-final events
            for (int i = 0; i < events.Count - 1; i++)
            {
                Assert.That(events[i].IsFinal, Is.False);
            }
        }

        [Test]
        public async Task TestChatGetConversations()
        {
            var page = await _client.Chat.GetConversationsAsync("p_test_001");

            Assert.That(page.Items.Count, Is.GreaterThanOrEqualTo(1));
            Assert.That(page.Total, Is.EqualTo(2));
        }

        // ---------------------------------------------------------------------------
        // Domains
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestDomainList()
        {
            var page = await _client.Domains.ListAsync();

            Assert.That(page.Items.Count, Is.GreaterThanOrEqualTo(1));
        }

        [Test]
        public async Task TestDomainGet()
        {
            var domain = await _client.Domains.GetAsync("d_test_001");

            Assert.That(domain["id"]?.ToString(), Is.EqualTo("d_test_001"));
            Assert.That(domain["name"]?.ToString(), Is.EqualTo("Test Domain"));
        }

        // ---------------------------------------------------------------------------
        // Simulations
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestSimulationCreate()
        {
            var simulation = await _client.Simulations.CreateAsync(
                name: "Test Simulation",
                domainId: "d_test_001"
            );

            Assert.That(simulation.Id, Is.EqualTo("sim_test_001"));
            Assert.That(simulation.Status, Is.EqualTo(SimulationStatus.Created));
        }

        [Test]
        public async Task TestSimulationStart()
        {
            var result = await _client.Simulations.StartAsync("sim_test_001", ticks: 50);

            Assert.That(result["status"]?.ToString(), Is.EqualTo("running"));
            Assert.That(result["ticks_requested"]?.ToObject<int>(), Is.EqualTo(50));
        }

        // ---------------------------------------------------------------------------
        // Memory
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestMemoryCreate()
        {
            var memory = await _client.Memory.CreateAsync(
                personaId: "p_test_001",
                content: "Remembers meeting a friend at the park"
            );

            Assert.That(memory["id"]?.ToString(), Is.EqualTo("mem_test_001"));
        }

        [Test]
        public void TestMemoryDelete()
        {
            Assert.DoesNotThrowAsync(async () =>
                await _client.Memory.DeleteAsync("p_test_001", "mem_test_001")
            );
        }

        // ---------------------------------------------------------------------------
        // Sessions
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestSessionCreate()
        {
            var session = await _client.Sessions.CreateAsync(tier: 0);

            Assert.That(session["id"]?.ToString(), Is.EqualTo("sess_test_001"));
            Assert.That(session["tier"]?.ToObject<int>(), Is.EqualTo(0));
            Assert.That(session["parent_session_id"]?.Type, Is.EqualTo(Newtonsoft.Json.Linq.JTokenType.Null));
        }

        // ---------------------------------------------------------------------------
        // Aggregate
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestAggregateQuery()
        {
            var result = await _client.Aggregate.CountAsync(domain: "demo");

            Assert.That(result["sample_size"]?.ToObject<int>(), Is.EqualTo(500));
            Assert.That(result["confidence"]?.ToObject<double>(), Is.EqualTo(0.95));
        }

        // ---------------------------------------------------------------------------
        // Health
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestHealthCheck()
        {
            var health = await _client.Health.CheckAsync();

            Assert.That(health["status"]?.ToString(), Is.EqualTo("ok"));
        }

        // ---------------------------------------------------------------------------
        // Info
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestInfoConfig()
        {
            var info = await _client.Info.ConfigAsync();

            Assert.That(info["api_version"]?.ToString(), Is.EqualTo("1.0.0"));
            Assert.That(info["max_batch_size"]?.ToObject<int>(), Is.EqualTo(100));
        }

        // ---------------------------------------------------------------------------
        // Auth Resources
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestAuthTokenExchange()
        {
            var token = await _client.Auth.TokenAsync("testuser", "testpass");

            Assert.That(token.AccessToken, Is.Not.Empty);
            Assert.That(token.TokenType, Is.EqualTo("bearer"));
        }

        [Test]
        public async Task TestAuthMe()
        {
            var user = await _client.Auth.MeAsync();

            Assert.That(user.ConsumerId, Is.EqualTo("user_test_001"));
        }

        // ---------------------------------------------------------------------------
        // Frameworks
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestFrameworkUpdate()
        {
            var framework = await _client.Frameworks.UpdateAsync(
                "fw_test_001",
                new Dictionary<string, object?>
                {
                    ["name"] = "Big Five Updated"
                }
            );

            Assert.That(framework["id"]?.ToString(), Is.EqualTo("fw_test_001"));
            Assert.That(framework["name"]?.ToString(), Is.EqualTo("Big Five Updated"));
        }

        // ---------------------------------------------------------------------------
        // Errors
        // ---------------------------------------------------------------------------

        [Test]
        public void TestErrorRateLimit()
        {
            var rateLimitConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "sk_test_123",
                maxRetries: 0,
                customHeaders: new Dictionary<string, string>
                {
                    ["X-Trigger-RateLimit"] = "true"
                }
            );
            using var rateLimitClient = new EnsoulClient(rateLimitConfig);

            var ex = Assert.ThrowsAsync<RateLimitException>(async () =>
                await rateLimitClient.Personas.ListAsync()
            );

            Assert.That(ex.StatusCode, Is.EqualTo(429));
            Assert.That(ex.RetryAfter, Is.EqualTo(30));
        }

        [Test]
        public void TestErrorValidation()
        {
            // POST an empty body to /v1/personas to trigger 422
            var ex = Assert.ThrowsAsync<ValidationException>(async () =>
                await _client.Personas.CreateAsync(name: "", domain: "")
            );

            Assert.That(ex.StatusCode, Is.EqualTo(422));
            Assert.That(ex.Details.Count, Is.GreaterThanOrEqualTo(1));
        }

        [Test]
        public void TestErrorAuthentication()
        {
            var noAuthConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "",
                maxRetries: 0
            );
            using var noAuthClient = new EnsoulClient(noAuthConfig);

            var ex = Assert.ThrowsAsync<AuthenticationException>(async () =>
                await noAuthClient.Personas.ListAsync()
            );

            Assert.That(ex.StatusCode, Is.EqualTo(401));
        }

        [Test]
        public void TestErrorServer()
        {
            var serverErrorConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "sk_test_123",
                maxRetries: 0,
                customHeaders: new Dictionary<string, string>
                {
                    ["X-Trigger-ServerError"] = "true"
                }
            );
            using var serverErrorClient = new EnsoulClient(serverErrorConfig);

            var ex = Assert.ThrowsAsync<ServerException>(async () =>
                await serverErrorClient.Personas.ListAsync()
            );

            Assert.That(ex.StatusCode, Is.EqualTo(500));
        }

        [Test]
        public void TestErrorAuthorizationForbidden()
        {
            var forbiddenConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "sk_test_123",
                maxRetries: 0,
                customHeaders: new Dictionary<string, string>
                {
                    ["X-Trigger-Forbidden"] = "true"
                }
            );
            using var forbiddenClient = new EnsoulClient(forbiddenConfig);

            var ex = Assert.ThrowsAsync<AuthorizationException>(async () =>
                await forbiddenClient.Personas.ListAsync()
            );

            Assert.That(ex.StatusCode, Is.EqualTo(403));
        }

        [Test]
        public async Task TestErrorRetry503()
        {
            var retryConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "sk_test_123",
                maxRetries: 2,
                customHeaders: new Dictionary<string, string>
                {
                    ["X-Trigger-503-Once"] = "true",
                    ["X-SDK-Language"] = "csharp-retry-test"
                }
            );
            using var retryClient = new EnsoulClient(retryConfig);

            // First call gets 503, retries, second call succeeds
            var page = await retryClient.Personas.ListAsync();

            Assert.That(page.Items.Count, Is.GreaterThanOrEqualTo(1));
        }

        // ---------------------------------------------------------------------------
        // Auth
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestAuthApiKeyHeader()
        {
            // If we can list personas successfully, the X-API-Key header was accepted
            var page = await _client.Personas.ListAsync();

            Assert.That(page.Items.Count, Is.GreaterThanOrEqualTo(1));
        }

        [Test]
        public void TestAuthNoCredentials()
        {
            var noAuthConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "",
                maxRetries: 0
            );
            using var noAuthClient = new EnsoulClient(noAuthConfig);

            Assert.ThrowsAsync<AuthenticationException>(async () =>
                await noAuthClient.Personas.ListAsync()
            );
        }

        [Test]
        public async Task TestAuthBearerToken()
        {
            var bearerConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                bearerToken: "test_token_123",
                maxRetries: 0
            );
            using var bearerClient = new EnsoulClient(bearerConfig);

            var page = await bearerClient.Personas.ListAsync();

            Assert.That(page.Items.Count, Is.GreaterThanOrEqualTo(1));
        }

        // ---------------------------------------------------------------------------
        // Pagination
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestPaginationAutoFetch()
        {
            var firstPage = await _client.Frameworks.ListAsync(perPage: 2);

            var allItems = new List<Newtonsoft.Json.Linq.JObject>();
            await foreach (var item in firstPage.GetAllPagesAsync())
            {
                allItems.Add(item);
            }

            Assert.That(allItems.Count, Is.EqualTo(3));
        }

        // ---------------------------------------------------------------------------
        // Client Configuration
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestClientCustomBaseUrl()
        {
            // Verify the client respects custom baseUrl by connecting to mock server
            var customConfig = new EnsoulConfig(
                baseUrl: _conformanceUrl,
                apiKey: "sk_test_123",
                maxRetries: 0
            );
            using var customClient = new EnsoulClient(customConfig);

            var page = await customClient.Personas.ListAsync();

            Assert.That(page.Items.Count, Is.GreaterThanOrEqualTo(1));
        }

        // ---------------------------------------------------------------------------
        // Chat sessions (persisted history)
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestCreateSession()
        {
            var session = await _client.Chat.CreateSessionAsync(
                teamId: "team_test_001",
                userId: "user_test_001",
                domainId: "d_test_001",
                personaId: "persona_test_001",
                title: "Test Chat Session"
            );

            Assert.That(session["id"]?.ToString(), Is.EqualTo("csess_test_001"));
            Assert.That(session["is_archived"]?.ToObject<bool>(), Is.False);
        }

        [Test]
        public async Task TestListSessions()
        {
            var result = await _client.Chat.ListSessionsAsync(userId: "user_test_001");

            Assert.That(((Newtonsoft.Json.Linq.JArray)result["sessions"]).Count, Is.GreaterThanOrEqualTo(1));
            Assert.That(result["pagination"]?["total"]?.ToObject<int>(), Is.EqualTo(1));
        }

        [Test]
        public async Task TestSessionStats()
        {
            var result = await _client.Chat.SessionStatsAsync(
                teamId: "team_test_001",
                startDate: "2025-01-01",
                endDate: "2025-01-31"
            );

            Assert.That(result["total"]?.ToObject<int>(), Is.EqualTo(7));
        }

        [Test]
        public async Task TestGetSession()
        {
            var session = await _client.Chat.GetSessionAsync("csess_test_001");

            Assert.That(session["id"]?.ToString(), Is.EqualTo("csess_test_001"));
            Assert.That(((Newtonsoft.Json.Linq.JArray)session["messages"]).Count, Is.GreaterThanOrEqualTo(1));
        }

        [Test]
        public async Task TestUpdateSession()
        {
            var session = await _client.Chat.UpdateSessionAsync("csess_test_001", title: "Renamed");

            Assert.That(session["id"]?.ToString(), Is.EqualTo("csess_test_001"));
        }

        [Test]
        public async Task TestArchiveSession()
        {
            var session = await _client.Chat.ArchiveSessionAsync("csess_test_001");

            Assert.That(session["id"]?.ToString(), Is.EqualTo("csess_test_001"));
        }

        [Test]
        public void TestDeleteSession()
        {
            // 204 No Content — completes without raising.
            Assert.DoesNotThrowAsync(async () =>
                await _client.Chat.DeleteSessionAsync("csess_test_001")
            );
        }

        [Test]
        public async Task TestAddMessage()
        {
            var message = await _client.Chat.AddMessageAsync(
                "csess_test_001", role: "assistant", content: "Hi");

            Assert.That(message["id"]?.ToString(), Is.EqualTo("msg_test_002"));
            Assert.That(message["role"]?.ToString(), Is.EqualTo("assistant"));
        }

        [Test]
        public async Task TestGetMessages()
        {
            var messages = await _client.Chat.GetMessagesAsync("csess_test_001");

            Assert.That(messages.Count, Is.EqualTo(2));
            Assert.That(messages[0]["role"]?.ToString(), Is.EqualTo("user"));
        }

        // ---------------------------------------------------------------------------
        // Simulation participants and event ticks
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestListParticipants()
        {
            var result = await _client.Simulations.ListParticipantsAsync("sim_test_001");

            Assert.That(result["total"]?.ToObject<int>(), Is.EqualTo(2));
            Assert.That(((Newtonsoft.Json.Linq.JArray)result["items"]).Count, Is.EqualTo(2));
        }

        [Test]
        public async Task TestAddParticipants()
        {
            var sim = await _client.Simulations.AddParticipantsAsync(
                "sim_test_001", new List<string> { "persona_test_001" });

            Assert.That(sim["id"]?.ToString(), Is.EqualTo("sim_test_001"));
        }

        [Test]
        public async Task TestEventTicks()
        {
            var result = await _client.Simulations.GetEventTicksAsync("sim_test_001");

            Assert.That(((Newtonsoft.Json.Linq.JArray)result["ticks"]).Count, Is.EqualTo(3));
        }

        // ---------------------------------------------------------------------------
        // Audit and verification
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestAuditGetEvent()
        {
            var ev = await _client.Audit.GetEventAsync("evt_test_001");

            Assert.That(ev["event_id"]?.ToString(), Is.EqualTo("evt_test_001"));
            Assert.That(ev["event_hash"], Is.Not.Null);
        }

        [Test]
        public async Task TestAuditGetCommitment()
        {
            var commitment = await _client.Audit.GetCommitmentAsync("cmt_test_001");

            Assert.That(commitment["commitment_id"]?.ToString(), Is.EqualTo("cmt_test_001"));
            Assert.That(commitment["event_count"]?.ToObject<int>(), Is.EqualTo(42));
        }

        [Test]
        public async Task TestAuditGetProof()
        {
            var proof = await _client.Audit.GetProofAsync("evt_test_001");

            Assert.That(proof["verified"]?.ToObject<bool>(), Is.True);
            Assert.That(((Newtonsoft.Json.Linq.JArray)proof["proof_path"]).Count, Is.EqualTo(2));
        }

        [Test]
        public async Task TestAuditVerify()
        {
            var result = await _client.Audit.VerifyAsync("evt_test_001");

            Assert.That(result["verified"]?.ToObject<bool>(), Is.True);
        }

        [Test]
        public async Task TestAuditSigningKey()
        {
            var pem = await _client.Audit.GetSigningKeyAsync();

            Assert.That(pem, Does.Contain("BEGIN PUBLIC KEY"));
        }
    }
}
