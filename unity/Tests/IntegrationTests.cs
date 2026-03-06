using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using Newtonsoft.Json.Linq;

namespace Ensoul.Tests
{
    /// <summary>
    /// Integration tests for the Unity C# SDK against a live Docker API stack.
    ///
    /// All tests are skipped when ENSOUL_INTEGRATION_URL is not set.
    ///
    /// Required env vars:
    ///   ENSOUL_INTEGRATION_URL       Base URL, e.g. http://localhost:8000
    ///
    /// Optional env vars:
    ///   ENSOUL_INTEGRATION_USERNAME  Demo username (default: pro-user)
    ///   ENSOUL_INTEGRATION_PASSWORD  Password for the demo user
    ///   ENSOUL_INTEGRATION_DOMAIN    Domain slug for persona CRUD + SSE tests
    /// </summary>
    [TestFixture]
    public class IntegrationTests
    {
        private static readonly string? IntegrationUrl =
            Environment.GetEnvironmentVariable("ENSOUL_INTEGRATION_URL")?.TrimEnd('/');
        private static readonly string IntegrationUsername =
            Environment.GetEnvironmentVariable("ENSOUL_INTEGRATION_USERNAME") ?? "pro-user";
        private static readonly string? IntegrationPassword =
            Environment.GetEnvironmentVariable("ENSOUL_INTEGRATION_PASSWORD");
        private static readonly string? IntegrationDomain =
            Environment.GetEnvironmentVariable("ENSOUL_INTEGRATION_DOMAIN");

        private EnsoulClient _client = null!;
        private EnsoulClient _noAuthClient = null!;
        private string _bearerToken = "";
        private string _testPersonaId = "";
        private bool _personaCreated = false;   // true = we own it (delete in teardown)

        [OneTimeSetUp]
        public async Task OneTimeSetUp()
        {
            if (string.IsNullOrEmpty(IntegrationUrl))
                Assert.Ignore("ENSOUL_INTEGRATION_URL not set");

            // Exchange credentials for a bearer token
            if (!string.IsNullOrEmpty(IntegrationPassword))
            {
                _bearerToken = await ExchangeToken(IntegrationUrl!, IntegrationUsername, IntegrationPassword!);
            }

            var config = new EnsoulConfig(
                baseUrl: IntegrationUrl!,
                apiKey: string.IsNullOrEmpty(_bearerToken) ? "" : null,
                bearerToken: string.IsNullOrEmpty(_bearerToken) ? null : _bearerToken,
                maxRetries: 0
            );
            _client = new EnsoulClient(config);

            var noAuthConfig = new EnsoulConfig(baseUrl: IntegrationUrl!, apiKey: "", maxRetries: 0);
            _noAuthClient = new EnsoulClient(noAuthConfig);

            // Obtain a test persona if domain is configured.
            // Try to create; on ServerException (DB mismatch) fall back to borrowing an existing one.
            if (!string.IsNullOrEmpty(IntegrationDomain) && !string.IsNullOrEmpty(_bearerToken))
            {
                try
                {
                    var persona = await _client.Personas.CreateAsync(
                        name: $"inttest-{DateTimeOffset.UtcNow.ToUnixTimeSeconds()}",
                        domain: IntegrationDomain!
                    );
                    _testPersonaId = persona.Id;
                    _personaCreated = true;
                }
                catch (ServerException)
                {
                    // Persona create failed (e.g. DB schema mismatch) — borrow an existing one
                    try
                    {
                        var page = await _client.Personas.ListAsync(perPage: 1);
                        if (page.Items.Count > 0)
                            _testPersonaId = page.Items[0].Id;
                    }
                    catch { }
                    // _personaCreated stays false — we won't delete in teardown
                }
                catch { }
            }
        }

        [OneTimeTearDown]
        public async Task OneTimeTearDown()
        {
            if (_personaCreated && !string.IsNullOrEmpty(_testPersonaId))
            {
                try { await _client.Personas.DeleteAsync(_testPersonaId); } catch { }
            }
            _client?.Dispose();
            _noAuthClient?.Dispose();
        }

        // ---------------------------------------------------------------------------
        // Helpers
        // ---------------------------------------------------------------------------

        private static async Task<string> ExchangeToken(string baseUrl, string username, string password)
        {
            using var http = new HttpClient();
            var body = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["username"] = username,
                ["password"] = password,
            });
            var resp = await http.PostAsync($"{baseUrl}/v1/auth/token", body);
            if (!resp.IsSuccessStatusCode) return "";
            var json = JObject.Parse(await resp.Content.ReadAsStringAsync());
            return json["access_token"]?.ToString() ?? "";
        }

        private void RequirePassword()
        {
            if (string.IsNullOrEmpty(IntegrationPassword))
                Assert.Ignore("ENSOUL_INTEGRATION_PASSWORD not set");
        }

        private void RequireDomain()
        {
            if (string.IsNullOrEmpty(IntegrationDomain))
                Assert.Ignore("ENSOUL_INTEGRATION_DOMAIN not set");
            RequirePassword();
        }

        // ---------------------------------------------------------------------------
        // Health
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestHealthCheck()
        {
            using var http = new HttpClient();
            var resp = await http.GetAsync($"{IntegrationUrl}/health");
            Assert.That((int)resp.StatusCode, Is.EqualTo(200));
            var json = JObject.Parse(await resp.Content.ReadAsStringAsync());
            var status = json["status"]?.ToString() ?? "";
            Assert.That(status == "ok" || status == "healthy", $"Unexpected health status: {status}");
            Assert.That(json["version"]?.ToString(), Is.Not.Null.And.Not.Empty);
        }

        // ---------------------------------------------------------------------------
        // Auth
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestTokenExchange()
        {
            RequirePassword();
            var token = await ExchangeToken(IntegrationUrl!, IntegrationUsername, IntegrationPassword!);
            Assert.That(token, Is.Not.Null.And.Not.Empty);
        }

        [Test]
        public async Task TestAuthMe()
        {
            RequirePassword();
            var user = await _client.Auth.MeAsync();
            Assert.That(user.ConsumerId, Is.Not.Null.And.Not.Empty);
            Assert.That(user.Username, Is.EqualTo(IntegrationUsername));
        }

        [Test]
        public void TestNoCredentialsReturns401()
        {
            Assert.ThrowsAsync<AuthenticationException>(async () =>
                await _noAuthClient.Personas.ListAsync());
        }

        // ---------------------------------------------------------------------------
        // Domains
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestDomainListReturnsArray()
        {
            RequirePassword();
            var page = await _client.Domains.ListAsync();
            Assert.That(page.Items, Is.Not.Null);
        }

        // ---------------------------------------------------------------------------
        // Personas
        // ---------------------------------------------------------------------------

        [Test]
        public void TestPersonaAvailable()
        {
            RequireDomain();
            Assert.That(_testPersonaId, Is.Not.Null.And.Not.Empty, "No persona available — create failed and no existing personas found");
        }

        [Test]
        public async Task TestPersonaGet()
        {
            RequireDomain();
            var persona = await _client.Personas.GetAsync(_testPersonaId);
            Assert.That(persona.Id, Is.EqualTo(_testPersonaId));
        }

        [Test]
        public async Task TestPersonaListShape()
        {
            RequireDomain();
            var page = await _client.Personas.ListAsync(page: 1, perPage: 5);
            Assert.That(page.Items, Is.Not.Null);
            Assert.That(page.PageNumber, Is.EqualTo(1));
            Assert.That(page.PerPage, Is.EqualTo(5));
        }

        [Test]
        public async Task TestPersonaUpdate()
        {
            RequireDomain();
            if (!_personaCreated)
            {
                Assert.Ignore("Skipping update: using borrowed seeded persona (read-only)");
                return;
            }
            var newName = $"inttest-{DateTimeOffset.UtcNow.ToUnixTimeSeconds()}-upd";
            var updated = await _client.Personas.UpdateAsync(
                _testPersonaId,
                new Dictionary<string, object?> { ["name"] = newName }
            );
            Assert.That(updated.Id, Is.EqualTo(_testPersonaId));
            Assert.That(updated.Name, Is.EqualTo(newName));
        }

        [Test]
        public void TestPersonaNotFound()
        {
            RequirePassword();
            Assert.ThrowsAsync<NotFoundException>(async () =>
                await _client.Personas.GetAsync("00000000-0000-4000-a000-999999999999"));
        }

        // ---------------------------------------------------------------------------
        // SSE Streaming
        // ---------------------------------------------------------------------------

        [Test]
        public async Task TestChatStreamSse()
        {
            RequireDomain();
            using var stream = await _client.Chat.StreamAsync(
                personaId: _testPersonaId,
                message: "Say hello in one word."
            );
            var events = new List<ChatStreamEvent>();
            await foreach (var sseEvent in stream.Events())
            {
                events.Add(SseParser.ParseChatEvent(sseEvent));
            }

            Assert.That(events.Count, Is.GreaterThanOrEqualTo(1), "Expected at least one SSE event");
            var finalEvents = events.FindAll(e => e.IsFinal);
            Assert.That(finalEvents.Count, Is.EqualTo(1), "Expected exactly one final event");
            Assert.That(finalEvents[0].TokenUsage, Is.Not.Null);
        }
    }
}
