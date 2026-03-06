/**
 * Cross-SDK conformance tests for the Kotlin SDK.
 *
 * These tests run against a mock server started by the conformance orchestrator.
 * They are automatically skipped when ENSOUL_CONFORMANCE_URL is not set,
 * so regular `./gradlew test` runs are unaffected.
 */
package ai.ensoul.sdk

import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.ints.shouldBeGreaterThan
import io.kotest.matchers.ints.shouldBeGreaterThanOrEqual
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe
import io.kotest.matchers.string.shouldNotBeBlank
import io.ktor.http.*
import kotlinx.coroutines.flow.toList
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.double
import kotlinx.serialization.json.int
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonPrimitive

private val CONFORMANCE_URL: String? = System.getenv("ENSOUL_CONFORMANCE_URL")

class ConformanceTest : FunSpec({

    // Skip the entire spec when the conformance URL is not configured.
    if (!CONFORMANCE_URL.isNullOrBlank()) {

    // Shared client with valid API key auth, retries disabled.
    val client by lazy {
        EnsoulClient(
            apiKey = "sk_test_123",
            baseUrl = CONFORMANCE_URL!!,
            maxRetries = 0,
            customHeaders = mapOf("X-SDK-Language" to "kotlin"),
        )
    }

    // Client with no credentials for auth-failure tests.
    val noAuthClient by lazy {
        EnsoulClient(
            apiKey = "",
            baseUrl = CONFORMANCE_URL!!,
            maxRetries = 0,
        )
    }

    afterSpec {
        client.close()
        noAuthClient.close()
    }

    // -----------------------------------------------------------------------
    // Personas
    // -----------------------------------------------------------------------

    test("persona create") {
        val persona = client.personas.create(
            name = "Test Persona",
            domain = "test_domain",
            personalityData = mapOf("trait_a" to 75, "trait_b" to 50),
        )
        persona.id shouldBe "p_test_001"
        persona.name shouldBe "Test Persona"
        persona.domain shouldBe "test_domain"
    }

    test("persona get") {
        val persona = client.personas.get("p_test_001")
        persona.id shouldBe "p_test_001"
        persona.name shouldBe "Test Persona"
        persona.domain shouldBe "test_domain"
    }

    test("persona update") {
        val persona = client.personas.update(
            "p_test_001",
            fields = mapOf("name" to "Updated Persona"),
        )
        persona.name shouldBe "Updated Persona"
    }

    test("persona delete") {
        // DELETE returns void — no exception means success.
        client.personas.delete("p_test_001")
    }

    test("persona list pagination") {
        val page = client.personas.list(page = 1, perPage = 10)
        page.items.size shouldBeGreaterThan 0
        page.total shouldBe 25
        page.page shouldBe 1
        page.perPage shouldBe 10
        page.pages shouldBe 3
    }

    test("persona not found") {
        val error = shouldThrow<NotFoundError> {
            client.personas.get("nonexistent_persona_id")
        }
        error.statusCode shouldBe 404
    }

    // -----------------------------------------------------------------------
    // Chat
    // -----------------------------------------------------------------------

    test("chat send") {
        val response = client.chat.send("p_test_001", "Hello, how are you?")
        response.response.shouldNotBeBlank()
        response.conversationId.shouldNotBeBlank()
        response.tokenUsage.totalTokens shouldBeGreaterThan 0
    }

    test("chat stream SSE") {
        val stream = client.chat.stream("p_test_001", "Tell me about yourself.")
        val sseEvents = stream.events().toList()
        val chatEvents = sseEvents
            .filter { it.event == "chunk" }
            .map { parseChatEvent(it) }

        chatEvents.size shouldBe 5

        // Check chunk ordering
        chatEvents.forEachIndexed { i, event ->
            event.chunkIndex shouldBe i
            event.conversationId shouldBe "conv_stream_001"
        }

        // Final event
        val last = chatEvents.last()
        last.isFinal shouldBe true
        last.tokenUsage shouldNotBe null
        last.tokenUsage!!["total_tokens"]!! shouldBeGreaterThan 0

        // Non-final events
        chatEvents.dropLast(1).forEach { event ->
            event.isFinal shouldBe false
        }
    }

    test("chat get conversations") {
        val page = client.chat.getConversations("p_test_001")
        page.items.size shouldBeGreaterThanOrEqual 1
        page.total shouldBe 2
    }

    // -----------------------------------------------------------------------
    // Domains
    // -----------------------------------------------------------------------

    test("domain list") {
        val page = client.domains.list()
        page.items.size shouldBeGreaterThan 0
    }

    test("domain get") {
        val domain = client.domains.get("d_test_001")
        domain["id"]!!.jsonPrimitive.contentOrNull shouldBe "d_test_001"
        domain["name"]!!.jsonPrimitive.contentOrNull shouldBe "Test Domain"
    }

    // -----------------------------------------------------------------------
    // Simulations
    // -----------------------------------------------------------------------

    test("simulation create") {
        val sim = client.simulations.create(
            name = "Test Simulation",
            domainId = "d_test_001",
        )
        sim.id shouldBe "sim_test_001"
        sim.status.name.lowercase() shouldBe "created"
    }

    test("simulation start") {
        val result = client.simulations.start("sim_test_001", ticks = 50)
        result["status"]!!.jsonPrimitive.contentOrNull shouldBe "running"
        result["ticks_requested"]!!.jsonPrimitive.int shouldBe 50
    }

    // -----------------------------------------------------------------------
    // Memory
    // -----------------------------------------------------------------------

    test("memory create") {
        val mem = client.memory.create(
            personaId = "p_test_001",
            content = "Test memory content",
        )
        mem["id"]!!.jsonPrimitive.contentOrNull shouldBe "mem_test_001"
    }

    test("memory delete") {
        // DELETE returns void — no exception means success.
        client.memory.delete("p_test_001", "mem_test_001")
    }

    // -----------------------------------------------------------------------
    // Sessions
    // -----------------------------------------------------------------------

    test("session create") {
        val session = client.sessions.create(personaId = "p_test_001")
        session["id"]!!.jsonPrimitive.contentOrNull shouldBe "sess_test_001"
        session["tier"]!!.jsonPrimitive.int shouldBe 0
        session["parent_session_id"]!! shouldBe kotlinx.serialization.json.JsonNull
    }

    // -----------------------------------------------------------------------
    // Aggregate
    // -----------------------------------------------------------------------

    test("aggregate query") {
        val result = client.aggregate.query(query = "What do you think about X?")
        result["sample_size"]!!.jsonPrimitive.int shouldBe 500
        result["confidence"]!!.jsonPrimitive.double shouldBe 0.95
    }

    // -----------------------------------------------------------------------
    // Health
    // -----------------------------------------------------------------------

    test("health check") {
        val result = client.health.check()
        result["status"]!!.jsonPrimitive.contentOrNull shouldBe "ok"
    }

    // -----------------------------------------------------------------------
    // Info
    // -----------------------------------------------------------------------

    test("info config") {
        val result = client.info.config()
        result["api_version"]!!.jsonPrimitive.contentOrNull shouldBe "1.0.0"
        result["max_batch_size"]!!.jsonPrimitive.int shouldBe 100
    }

    // -----------------------------------------------------------------------
    // Auth Resources
    // -----------------------------------------------------------------------

    test("auth token exchange") {
        val token = client.auth.token(username = "testuser", password = "testpass")
        token.accessToken.shouldNotBeBlank()
        token.tokenType shouldBe "bearer"
    }

    test("auth me") {
        val user = client.auth.me()
        user.consumerId shouldBe "user_test_001"
    }

    // -----------------------------------------------------------------------
    // Frameworks
    // -----------------------------------------------------------------------

    test("framework update") {
        val fw = client.frameworks.update(
            "fw_test_001",
            body = mapOf("name" to "Big Five Updated"),
        )
        fw["id"]!!.jsonPrimitive.contentOrNull shouldBe "fw_test_001"
        fw["name"]!!.jsonPrimitive.contentOrNull shouldBe "Big Five Updated"
    }

    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    test("error rate limit") {
        val error = shouldThrow<RateLimitError> {
            client.httpClient.request(
                method = HttpMethod.Get,
                path = "/v1/personas",
                headers = mapOf("X-Trigger-RateLimit" to "true"),
            )
        }
        error.retryAfter shouldBe 30
    }

    test("error validation") {
        val error = shouldThrow<ValidationError> {
            client.httpClient.post("/v1/personas", json = emptyMap())
        }
        error.statusCode shouldBe 422
        error.details.size shouldBeGreaterThan 0
    }

    test("error authentication") {
        val error = shouldThrow<AuthenticationError> {
            noAuthClient.personas.list()
        }
        error.statusCode shouldBe 401
    }

    test("error server") {
        val error = shouldThrow<ServerError> {
            client.httpClient.request(
                method = HttpMethod.Get,
                path = "/v1/personas",
                headers = mapOf("X-Trigger-ServerError" to "true"),
            )
        }
        error.statusCode shouldBe 500
    }

    test("error authorization forbidden") {
        val error = shouldThrow<AuthorizationError> {
            client.httpClient.request(
                method = HttpMethod.Get,
                path = "/v1/personas",
                headers = mapOf("X-Trigger-Forbidden" to "true"),
            )
        }
        error.statusCode shouldBe 403
    }

    test("error retry 503") {
        val retryClient = EnsoulClient(
            apiKey = "sk_test_123",
            baseUrl = CONFORMANCE_URL!!,
            maxRetries = 2,
            customHeaders = mapOf("X-SDK-Language" to "kotlin"),
        )
        try {
            // First request gets 503, retry succeeds with persona list.
            val page = retryClient.httpClient.request(
                method = HttpMethod.Get,
                path = "/v1/personas",
                headers = mapOf("X-Trigger-503-Once" to "true"),
            )
            // If we get here without exception, the retry succeeded.
            page.status.value shouldBe 200
        } finally {
            retryClient.close()
        }
    }

    // -----------------------------------------------------------------------
    // Auth
    // -----------------------------------------------------------------------

    test("auth api key header") {
        // If we can list personas successfully, the X-Api-Key header was accepted.
        val page = client.personas.list()
        page.items.size shouldBeGreaterThan 0
    }

    test("auth no credentials") {
        shouldThrow<AuthenticationError> {
            noAuthClient.personas.list()
        }
    }

    test("auth bearer token") {
        val bearerClient = EnsoulClient(
            bearerToken = "test_token_123",
            baseUrl = CONFORMANCE_URL!!,
            maxRetries = 0,
        )
        try {
            val page = bearerClient.personas.list()
            page.items.size shouldBeGreaterThan 0
        } finally {
            bearerClient.close()
        }
    }

    // -----------------------------------------------------------------------
    // Client Configuration
    // -----------------------------------------------------------------------

    test("client custom base url") {
        // Verify the client respects custom baseUrl by connecting to the mock server.
        val customClient = EnsoulClient(
            apiKey = "sk_test_123",
            baseUrl = CONFORMANCE_URL!!,
            maxRetries = 0,
        )
        try {
            val page = customClient.personas.list()
            page.items.size shouldBeGreaterThan 0
        } finally {
            customClient.close()
        }
    }

    // -----------------------------------------------------------------------
    // Pagination
    // -----------------------------------------------------------------------

    test("pagination auto fetch") {
        val page = client.frameworks.list(perPage = 2)
        val allItems = page.autoPagingFlow().toList()
        allItems.size shouldBe 3
    }

    } // if CONFORMANCE_URL
})
