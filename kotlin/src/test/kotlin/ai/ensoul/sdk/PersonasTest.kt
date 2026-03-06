package ai.ensoul.sdk

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import io.ktor.client.engine.mock.*
import io.ktor.http.*

class PersonasTest : FunSpec({

    fun makeClient(handler: suspend MockRequestHandleScope.(io.ktor.client.request.HttpRequestData) -> io.ktor.client.request.HttpResponseData): EnsoulClient {
        val engine = MockEngine(handler)
        val config = ClientConfig(apiKey = "test-key")
        val httpClient = EnsoulHttpClient(config, engine)
        return EnsoulClient.withHttpClient(config, httpClient)
    }

    val personaJson = """
        {
          "id": "p1",
          "name": "Alice",
          "domain": "test-domain",
          "created_at": "2024-01-01T00:00:00Z"
        }
    """.trimIndent()

    test("personas.create sends POST and returns PersonaResponse") {
        var capturedMethod: HttpMethod? = null
        var capturedPath: String? = null

        val client = makeClient { request ->
            capturedMethod = request.method
            capturedPath = request.url.encodedPath
            respond(
                content = personaJson,
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString()),
            )
        }

        val persona = client.personas.create(name = "Alice", domain = "test-domain")
        capturedMethod shouldBe HttpMethod.Post
        capturedPath shouldBe "/v1/personas"
        persona.id shouldBe "p1"
        persona.name shouldBe "Alice"
        persona.domain shouldBe "test-domain"
        client.close()
    }

    test("personas.get sends GET and returns PersonaResponse") {
        var capturedMethod: HttpMethod? = null
        var capturedPath: String? = null

        val client = makeClient { request ->
            capturedMethod = request.method
            capturedPath = request.url.encodedPath
            respond(
                content = personaJson,
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString()),
            )
        }

        val persona = client.personas.get("p1")
        capturedMethod shouldBe HttpMethod.Get
        capturedPath shouldBe "/v1/personas/p1"
        persona.id shouldBe "p1"
        client.close()
    }

    test("personas.list returns Page with items") {
        val listJson = """
            {
              "items": [
                {"id": "p1", "name": "Alice", "domain": "test-domain", "created_at": "2024-01-01T00:00:00Z"},
                {"id": "p2", "name": "Bob", "domain": "test-domain", "created_at": "2024-01-01T00:00:00Z"}
              ],
              "total": 2,
              "page": 1,
              "per_page": 20,
              "pages": 1
            }
        """.trimIndent()

        val client = makeClient { _ ->
            respond(
                content = listJson,
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString()),
            )
        }

        val page = client.personas.list()
        page.items.size shouldBe 2
        page.total shouldBe 2
        page.page shouldBe 1
        page.pages shouldBe 1
        page.hasNextPage() shouldBe false
        page.items[0].id shouldBe "p1"
        page.items[1].name shouldBe "Bob"
        client.close()
    }

    test("personas.delete sends DELETE") {
        var capturedMethod: HttpMethod? = null
        var capturedPath: String? = null

        val client = makeClient { request ->
            capturedMethod = request.method
            capturedPath = request.url.encodedPath
            respond(
                content = "",
                status = HttpStatusCode.NoContent,
            )
        }

        client.personas.delete("p1")
        capturedMethod shouldBe HttpMethod.Delete
        capturedPath shouldBe "/v1/personas/p1"
        client.close()
    }
})
