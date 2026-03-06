package ai.ensoul.sdk

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import io.ktor.client.engine.mock.*
import io.ktor.http.*
import kotlinx.coroutines.flow.toList
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonPrimitive

class PaginationTest : FunSpec({

    fun makePageClient(
        page1Json: String,
        page2Json: String? = null,
    ): EnsoulClient {
        var callCount = 0
        val engine = MockEngine { _ ->
            callCount++
            val body = if (callCount == 1) page1Json else (page2Json ?: page1Json)
            respond(
                content = body,
                status = HttpStatusCode.OK,
                headers = headersOf(HttpHeaders.ContentType, ContentType.Application.Json.toString()),
            )
        }
        val config = ClientConfig(apiKey = "test-key")
        val httpClient = EnsoulHttpClient(config, engine)
        return EnsoulClient.withHttpClient(config, httpClient)
    }

    fun makeMultiPagePage(
        items: List<JsonObject>,
        total: Int,
        page: Int,
        pages: Int,
        client: EnsoulHttpClient,
    ): Page<JsonObject> = Page(
        items = items,
        total = total,
        page = page,
        perPage = 2,
        pages = pages,
        client = client,
        method = "GET",
        path = "/v1/test",
        params = emptyMap(),
        deserializer = { it },
    )

    fun jsonObj(id: String): JsonObject {
        return kotlinx.serialization.json.buildJsonObject {
            put("id", kotlinx.serialization.json.JsonPrimitive(id))
        }
    }

    test("Page.hasNextPage returns true when page < pages") {
        val page = Page(
            items = listOf(jsonObj("a"), jsonObj("b")),
            total = 4,
            page = 1,
            perPage = 2,
            pages = 2,
            client = EnsoulHttpClient(ClientConfig(apiKey = "test-key")),
            method = "GET",
            path = "/v1/test",
            params = emptyMap(),
            deserializer = { it },
        )
        page.hasNextPage() shouldBe true
    }

    test("Page.hasNextPage returns false on last page") {
        val page = Page(
            items = listOf(jsonObj("a"), jsonObj("b")),
            total = 2,
            page = 1,
            perPage = 2,
            pages = 1,
            client = EnsoulHttpClient(ClientConfig(apiKey = "test-key")),
            method = "GET",
            path = "/v1/test",
            params = emptyMap(),
            deserializer = { it },
        )
        page.hasNextPage() shouldBe false
    }

    test("Page.iterator iterates current page items") {
        val items = listOf(jsonObj("x"), jsonObj("y"), jsonObj("z"))
        val page = Page(
            items = items,
            total = 3,
            page = 1,
            perPage = 3,
            pages = 1,
            client = EnsoulHttpClient(ClientConfig(apiKey = "test-key")),
            method = "GET",
            path = "/v1/test",
            params = emptyMap(),
            deserializer = { it },
        )
        val collected = mutableListOf<JsonObject>()
        for (item in page) {
            collected.add(item)
        }
        collected.size shouldBe 3
        collected[0]["id"]?.jsonPrimitive?.content shouldBe "x"
        collected[1]["id"]?.jsonPrimitive?.content shouldBe "y"
        collected[2]["id"]?.jsonPrimitive?.content shouldBe "z"
    }

    test("Page.autoPagingFlow yields all items across pages") {
        val page2Json = """
            {
              "items": [
                {"id":"p3","name":"Carol","domain":"test","created_at":"2024-01-01T00:00:00Z"},
                {"id":"p4","name":"Dave","domain":"test","created_at":"2024-01-01T00:00:00Z"}
              ],
              "total": 4,
              "page": 2,
              "per_page": 2,
              "pages": 2
            }
        """.trimIndent()

        val client = makePageClient(
            page1Json = """
                {
                  "items": [
                    {"id":"p1","name":"Alice","domain":"test","created_at":"2024-01-01T00:00:00Z"},
                    {"id":"p2","name":"Bob","domain":"test","created_at":"2024-01-01T00:00:00Z"}
                  ],
                  "total": 4,
                  "page": 1,
                  "per_page": 2,
                  "pages": 2
                }
            """.trimIndent(),
            page2Json = page2Json,
        )

        val page = client.personas.list(perPage = 2)
        val allItems = page.autoPagingFlow().toList()
        allItems.size shouldBe 4
        client.close()
    }
})
