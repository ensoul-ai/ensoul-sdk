using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using NUnit.Framework;

namespace Ensoul.Tests
{
    [TestFixture]
    public class PersonasTests
    {
        [Test]
        public async Task Create_SendsPost_ToCorrectPath()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaJson);
            });

            await client.Personas.CreateAsync("Alice", "test-domain");

            Assert.That(captured, Is.Not.Null);
            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Post));
            Assert.That(captured.RequestUri!.AbsolutePath, Does.Contain("/personas"));
        }

        [Test]
        public async Task Create_DecodesPersonaResponse()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaJson));

            var result = await client.Personas.CreateAsync("Alice", "test-domain");

            Assert.That(result.Id, Is.EqualTo("p1"));
            Assert.That(result.Name, Is.EqualTo("Alice"));
            Assert.That(result.Domain, Is.EqualTo("test-domain"));
        }

        [Test]
        public async Task Create_IncludesApiKeyHeader()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaJson);
            });

            await client.Personas.CreateAsync("Alice", "test-domain");

            Assert.That(captured, Is.Not.Null);
            Assert.That(captured!.Headers.Contains("X-API-Key"), Is.True);
        }

        [Test]
        public async Task Get_SendsGet_ToCorrectPath()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaJson);
            });

            await client.Personas.GetAsync("p1");

            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Get));
            Assert.That(captured.RequestUri!.AbsolutePath, Does.Contain("/personas/p1"));
        }

        [Test]
        public async Task Get_DecodesPersonaResponse()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaJson));

            var result = await client.Personas.GetAsync("p1");

            Assert.That(result.Id, Is.EqualTo("p1"));
            Assert.That(result.Name, Is.EqualTo("Alice"));
        }

        [Test]
        public async Task List_SendsGet_WithQueryParams()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaListJson);
            });

            await client.Personas.ListAsync(page: 2, perPage: 10);

            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Get));
            Assert.That(captured.RequestUri!.Query, Does.Contain("page=2"));
            Assert.That(captured.RequestUri.Query, Does.Contain("per_page=10"));
        }

        [Test]
        public async Task List_DecodesPageWithItems()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaListJson));

            var page = await client.Personas.ListAsync();

            Assert.That(page.Items, Has.Count.EqualTo(2));
            Assert.That(page.Items[0].Name, Is.EqualTo("Alice"));
            Assert.That(page.Items[1].Name, Is.EqualTo("Bob"));
            Assert.That(page.Total, Is.EqualTo(2));
        }

        [Test]
        public async Task List_HasNextPage_ReturnsFalse_OnSinglePage()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaListJson));

            var page = await client.Personas.ListAsync();

            // pages=1, page=1 → no next page
            Assert.That(page.HasNextPage, Is.False);
        }

        [Test]
        public async Task Delete_SendsDelete_ToCorrectPath()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.NoContent, "");
            });

            await client.Personas.DeleteAsync("p1");

            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Delete));
            Assert.That(captured.RequestUri!.AbsolutePath, Does.Contain("/personas/p1"));
        }

        [Test]
        public async Task BatchCreate_SendsPost_ToBatchPath()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.BatchResponseJson);
            });

            var personas = new List<Dictionary<string, object?>>
            {
                new() { ["name"] = "Alice", ["domain"] = "test-domain" },
                new() { ["name"] = "Bob", ["domain"] = "test-domain" }
            };
            await client.Personas.BatchCreateAsync(personas);

            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Post));
            Assert.That(captured.RequestUri!.AbsolutePath, Does.Contain("/personas/batch"));
        }

        [Test]
        public async Task BatchCreate_DecodesBatchResponse()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.BatchResponseJson));

            var personas = new List<Dictionary<string, object?>>
            {
                new() { ["name"] = "Alice", ["domain"] = "test-domain" }
            };
            var result = await client.Personas.BatchCreateAsync(personas);

            Assert.That(result.Created, Is.EqualTo(2));
            Assert.That(result.PersonaIds, Has.Count.EqualTo(2));
            Assert.That(result.PersonaIds[0], Is.EqualTo("p1"));
        }

        [Test]
        public async Task GetPersonality_DecodesPersonalityVector()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonalityJson));

            var result = await client.Personas.GetPersonalityAsync("p1");

            Assert.That(result.PersonaId, Is.EqualTo("p1"));
            Assert.That(result.Domain, Is.EqualTo("test-domain"));
            Assert.That(result.CoreValues, Contains.Item("honesty"));
        }

        [Test]
        public async Task GetFilters_DecodesFiltersResponse()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.FiltersJson));

            var result = await client.Personas.GetFiltersAsync();

            Assert.That(result.TotalPersonas, Is.EqualTo(100));
            Assert.That(result.Domains, Has.Count.EqualTo(1));
            Assert.That(result.Domains![0].Id, Is.EqualTo("d1"));
        }
    }
}
