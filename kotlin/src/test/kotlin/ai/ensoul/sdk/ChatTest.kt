package ai.ensoul.sdk

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import io.ktor.client.engine.mock.*
import io.ktor.http.*

class ChatTest : FunSpec({

    fun makeClient(handler: suspend MockRequestHandleScope.(io.ktor.client.request.HttpRequestData) -> io.ktor.client.request.HttpResponseData): EnsoulClient {
        val engine = MockEngine(handler)
        val config = ClientConfig(apiKey = "test-key")
        val httpClient = EnsoulHttpClient(config, engine)
        return EnsoulClient.withHttpClient(config, httpClient)
    }

    test("chat.send sends POST with correct body") {
        var capturedMethod: HttpMethod? = null
        var capturedPath: String? = null

        val chatResponseJson = """
            {
              "response": "Hello, human!",
              "conversation_id": "conv-1",
              "token_usage": {"input_tokens": 10, "output_tokens": 5, "total_tokens": 15},
              "latency_ms": 200,
              "model": "claude-3"
            }
        """.trimIndent()

        val client = makeClient { request ->
            capturedMethod = request.method
            capturedPath = request.url.encodedPath
            respond(
                content = chatResponseJson,
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString()),
            )
        }

        val result = client.chat.send(
            personaId = "p1",
            message = "Hello",
        )
        capturedMethod shouldBe HttpMethod.Post
        capturedPath shouldBe "/v1/personas/p1/chat"
        result.response shouldBe "Hello, human!"
        result.conversationId shouldBe "conv-1"
        result.tokenUsage.totalTokens shouldBe 15
        client.close()
    }

    test("chat.getConversation sends GET and returns ConversationResponse") {
        var capturedMethod: HttpMethod? = null
        var capturedPath: String? = null

        val convJson = """
            {
              "conversation_id": "conv-1",
              "persona_id": "p1",
              "messages": [
                {"role": "user", "content": "Hello", "timestamp": "2024-01-01T00:00:00Z"},
                {"role": "assistant", "content": "Hi!", "timestamp": "2024-01-01T00:00:01Z"}
              ],
              "created_at": "2024-01-01T00:00:00Z",
              "updated_at": "2024-01-01T00:00:01Z",
              "message_count": 2,
              "total_tokens": 50
            }
        """.trimIndent()

        val client = makeClient { request ->
            capturedMethod = request.method
            capturedPath = request.url.encodedPath
            respond(
                content = convJson,
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString()),
            )
        }

        val result = client.chat.getConversation(personaId = "p1", conversationId = "conv-1")
        capturedMethod shouldBe HttpMethod.Get
        capturedPath shouldBe "/v1/personas/p1/conversations/conv-1"
        result.conversationId shouldBe "conv-1"
        result.personaId shouldBe "p1"
        result.messages.size shouldBe 2
        result.messageCount shouldBe 2
        client.close()
    }
})
