using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using NUnit.Framework;

namespace Ensoul.Tests
{
    [TestFixture]
    public class PaginationTests
    {
        private const string Page1Json = @"{
            ""items"": [
                {""id"": ""p1"", ""name"": ""Alice"", ""domain"": ""test"", ""created_at"": ""2024-01-01T00:00:00Z""},
                {""id"": ""p2"", ""name"": ""Bob"", ""domain"": ""test"", ""created_at"": ""2024-01-01T00:00:00Z""}
            ],
            ""total"": 4,
            ""page"": 1,
            ""per_page"": 2,
            ""pages"": 2
        }";

        private const string Page2Json = @"{
            ""items"": [
                {""id"": ""p3"", ""name"": ""Carol"", ""domain"": ""test"", ""created_at"": ""2024-01-01T00:00:00Z""},
                {""id"": ""p4"", ""name"": ""Dave"", ""domain"": ""test"", ""created_at"": ""2024-01-01T00:00:00Z""}
            ],
            ""total"": 4,
            ""page"": 2,
            ""per_page"": 2,
            ""pages"": 2
        }";

        [Test]
        public async Task FromResponse_ParsesItemsCorrectly()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json));

            var page = await client.Personas.ListAsync(perPage: 2);

            Assert.That(page.Items, Has.Count.EqualTo(2));
            Assert.That(page.Items[0].Id, Is.EqualTo("p1"));
            Assert.That(page.Items[1].Id, Is.EqualTo("p2"));
        }

        [Test]
        public async Task FromResponse_ParsesTotalAndPages()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json));

            var page = await client.Personas.ListAsync(perPage: 2);

            Assert.That(page.Total, Is.EqualTo(4));
            Assert.That(page.Pages, Is.EqualTo(2));
        }

        [Test]
        public async Task HasNextPage_True_WhenMorePages()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json));

            var page = await client.Personas.ListAsync(perPage: 2);

            // page=1, pages=2 → has next
            Assert.That(page.HasNextPage, Is.True);
        }

        [Test]
        public async Task HasNextPage_False_OnLastPage()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page2Json));

            var page = await client.Personas.ListAsync(perPage: 2);

            // page=2, pages=2 → no next
            Assert.That(page.HasNextPage, Is.False);
        }

        [Test]
        public async Task HasNextPage_False_OnSinglePage()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaListJson));

            var page = await client.Personas.ListAsync();

            // pages=1, page=1 → no next
            Assert.That(page.HasNextPage, Is.False);
        }

        [Test]
        public async Task NextPage_RequestsCorrectPage()
        {
            int callCount = 0;
            HttpRequestMessage? secondRequest = null;
            using var client = Fixtures.MakeClient(req =>
            {
                callCount++;
                if (callCount == 1)
                    return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json);
                secondRequest = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page2Json);
            });

            var page1 = await client.Personas.ListAsync(perPage: 2);
            var page2 = await page1.NextPageAsync();

            Assert.That(secondRequest, Is.Not.Null);
            Assert.That(secondRequest!.RequestUri!.Query, Does.Contain("page=2"));
        }

        [Test]
        public async Task NextPage_ReturnsNextItems()
        {
            int callCount = 0;
            using var client = Fixtures.MakeClient(_ =>
            {
                callCount++;
                return callCount == 1
                    ? MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json)
                    : MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page2Json);
            });

            var page1 = await client.Personas.ListAsync(perPage: 2);
            var page2 = await page1.NextPageAsync();

            Assert.That(page2.Items, Has.Count.EqualTo(2));
            Assert.That(page2.Items[0].Id, Is.EqualTo("p3"));
            Assert.That(page2.Items[1].Id, Is.EqualTo("p4"));
        }

        [Test]
        public async Task GetAllPages_SinglePage_YieldsAllItems()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.PersonaListJson));

            var page = await client.Personas.ListAsync();
            var allItems = new List<PersonaResponse>();
            await foreach (var item in page.GetAllPagesAsync())
                allItems.Add(item);

            Assert.That(allItems, Has.Count.EqualTo(2));
        }

        [Test]
        public async Task GetAllPages_MultiPage_YieldsAllItems()
        {
            int callCount = 0;
            using var client = Fixtures.MakeClient(_ =>
            {
                callCount++;
                return callCount == 1
                    ? MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json)
                    : MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page2Json);
            });

            var page = await client.Personas.ListAsync(perPage: 2);
            var allItems = new List<PersonaResponse>();
            await foreach (var item in page.GetAllPagesAsync())
                allItems.Add(item);

            Assert.That(allItems, Has.Count.EqualTo(4));
            Assert.That(allItems[0].Id, Is.EqualTo("p1"));
            Assert.That(allItems[2].Id, Is.EqualTo("p3"));
        }

        [Test]
        public async Task PageNumber_MatchesResponsePage()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json));

            var page = await client.Personas.ListAsync();

            Assert.That(page.PageNumber, Is.EqualTo(1));
        }

        [Test]
        public async Task PerPage_MatchesResponsePerPage()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json));

            var page = await client.Personas.ListAsync(perPage: 2);

            Assert.That(page.PerPage, Is.EqualTo(2));
        }

        [Test]
        public async Task Items_IsCorrectCount()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Page1Json));

            var page = await client.Personas.ListAsync();

            Assert.That(page.Items, Has.Count.EqualTo(2));
        }
    }
}
