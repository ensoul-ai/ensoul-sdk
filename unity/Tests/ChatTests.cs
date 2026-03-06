using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using NUnit.Framework;

namespace Ensoul.Tests
{
    [TestFixture]
    public class ChatTests
    {
        [Test]
        public async Task Send_SendsPost_WithCorrectBody()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.ChatResponseJson);
            });

            await client.Chat.SendAsync("p1", "Hello!");

            Assert.That(captured, Is.Not.Null);
            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Post));
            Assert.That(captured.RequestUri!.AbsolutePath, Does.Contain("/personas/p1/chat"));
        }

        [Test]
        public async Task Send_DecodesChatResponse()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.ChatResponseJson));

            var result = await client.Chat.SendAsync("p1", "Hello!");

            Assert.That(result.Response, Is.EqualTo("Hello, human!"));
            Assert.That(result.ConversationId, Is.EqualTo("conv-1"));
            Assert.That(result.Model, Is.EqualTo("claude-3"));
            Assert.That(result.LatencyMs, Is.EqualTo(200));
        }

        [Test]
        public async Task Send_TokenUsage_HasCorrectValues()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.ChatResponseJson));

            var result = await client.Chat.SendAsync("p1", "Hello!");

            Assert.That(result.TokenUsage, Is.Not.Null);
            Assert.That(result.TokenUsage.InputTokens, Is.EqualTo(10));
            Assert.That(result.TokenUsage.OutputTokens, Is.EqualTo(5));
            Assert.That(result.TokenUsage.TotalTokens, Is.EqualTo(15));
        }

        [Test]
        public async Task Stream_SendsPost_ToStreamPath()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK,
                    "data: {\"chunk\": \"Hello\"}\n\n");
            });

            using var stream = await client.Chat.StreamAsync("p1", "Hi");

            Assert.That(captured, Is.Not.Null);
            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Post));
            Assert.That(captured.RequestUri!.AbsolutePath, Does.Contain("/personas/p1/chat/stream"));
        }

        [Test]
        public async Task GetConversations_SendsGet_WithPagination()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.ConversationListJson);
            });

            await client.Chat.GetConversationsAsync("p1", page: 2, perPage: 5);

            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Get));
            Assert.That(captured.RequestUri!.Query, Does.Contain("page=2"));
            Assert.That(captured.RequestUri.Query, Does.Contain("per_page=5"));
        }

        [Test]
        public async Task GetConversations_DecodesConversationList()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.ConversationListJson));

            var page = await client.Chat.GetConversationsAsync("p1");

            Assert.That(page.Items, Has.Count.EqualTo(1));
            Assert.That(page.Items[0].ConversationId, Is.EqualTo("conv-1"));
            Assert.That(page.Items[0].MessageCount, Is.EqualTo(5));
        }

        [Test]
        public async Task GetConversation_SendsGet_ToCorrectPath()
        {
            HttpRequestMessage? captured = null;
            using var client = Fixtures.MakeClient(req =>
            {
                captured = req;
                return MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.ConversationJson);
            });

            await client.Chat.GetConversationAsync("p1", "conv-1");

            Assert.That(captured!.Method, Is.EqualTo(HttpMethod.Get));
            Assert.That(captured.RequestUri!.AbsolutePath, Does.Contain("/personas/p1/conversations/conv-1"));
        }

        [Test]
        public async Task GetConversation_DecodesConversationResponse()
        {
            using var client = Fixtures.MakeClient(_ =>
                MockHttpHandler.MakeResponse(HttpStatusCode.OK, Fixtures.ConversationJson));

            var result = await client.Chat.GetConversationAsync("p1", "conv-1");

            Assert.That(result.ConversationId, Is.EqualTo("conv-1"));
            Assert.That(result.PersonaId, Is.EqualTo("p1"));
            Assert.That(result.Messages, Has.Count.EqualTo(2));
            Assert.That(result.Messages[0].Role, Is.EqualTo("user"));
            Assert.That(result.MessageCount, Is.EqualTo(2));
            Assert.That(result.TotalTokens, Is.EqualTo(50));
        }
    }
}
