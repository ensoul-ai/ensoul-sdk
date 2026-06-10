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
import io.kotest.matchers.string.shouldContain
import io.kotest.matchers.string.shouldNotBeBlank
import io.ktor.http.*
import kotlinx.coroutines.flow.toList
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.double
import kotlinx.serialization.json.int
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
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
        val session = client.sessions.create()
        session["id"]!!.jsonPrimitive.contentOrNull shouldBe "sess_test_001"
        session["tier"]!!.jsonPrimitive.int shouldBe 0
        session["parent_session_id"]!! shouldBe kotlinx.serialization.json.JsonNull
    }

    // -----------------------------------------------------------------------
    // Aggregate
    // -----------------------------------------------------------------------

    test("aggregate count") {
        val result = client.aggregate.count(domain = "test_domain")
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

    // -----------------------------------------------------------------------
    // Chat sessions (persisted history)
    // -----------------------------------------------------------------------

    test("create session") {
        val session = client.chat.createSession(
            teamId = "team_test_001",
            userId = "user_test_001",
            domainId = "d_test_001",
            personaId = "persona_test_001",
            title = "Test Chat Session",
        )
        session["id"]!!.jsonPrimitive.contentOrNull shouldBe "csess_test_001"
        session["is_archived"]!!.jsonPrimitive.boolean shouldBe false
    }

    test("list sessions") {
        val result = client.chat.listSessions(userId = "user_test_001")
        result["sessions"]!!.jsonArray.size shouldBeGreaterThanOrEqual 1
        result["pagination"]!!.jsonObject["total"]!!.jsonPrimitive.int shouldBe 1
    }

    test("session stats") {
        val result = client.chat.sessionStats(
            teamId = "team_test_001",
            startDate = "2025-01-01",
            endDate = "2025-01-31",
        )
        result["total"]!!.jsonPrimitive.int shouldBe 7
    }

    test("get session") {
        val session = client.chat.getSession("csess_test_001")
        session["id"]!!.jsonPrimitive.contentOrNull shouldBe "csess_test_001"
        session["messages"]!!.jsonArray.size shouldBeGreaterThanOrEqual 1
    }

    test("update session") {
        val session = client.chat.updateSession("csess_test_001", title = "Renamed")
        session["id"]!!.jsonPrimitive.contentOrNull shouldBe "csess_test_001"
    }

    test("archive session") {
        val session = client.chat.archiveSession("csess_test_001")
        session["id"]!!.jsonPrimitive.contentOrNull shouldBe "csess_test_001"
    }

    test("delete session") {
        // 204 No Content — no exception means success.
        client.chat.deleteSession("csess_test_001")
    }

    test("add message") {
        val message = client.chat.addMessage(
            "csess_test_001",
            role = "assistant",
            content = "Hi",
        )
        message["id"]!!.jsonPrimitive.contentOrNull shouldBe "msg_test_002"
        message["role"]!!.jsonPrimitive.contentOrNull shouldBe "assistant"
    }

    test("get messages") {
        val messages = client.chat.getMessages("csess_test_001")
        messages.size shouldBe 2
        messages[0]["role"]!!.jsonPrimitive.contentOrNull shouldBe "user"
    }

    // -----------------------------------------------------------------------
    // Simulation participants and event ticks
    // -----------------------------------------------------------------------

    test("list participants") {
        val result = client.simulations.listParticipants("sim_test_001")
        result["total"]!!.jsonPrimitive.int shouldBe 2
        result["items"]!!.jsonArray.size shouldBe 2
    }

    test("add participants") {
        val sim = client.simulations.addParticipants("sim_test_001", listOf("persona_test_001"))
        sim["id"]!!.jsonPrimitive.contentOrNull shouldBe "sim_test_001"
    }

    test("event ticks") {
        val result = client.simulations.getEventTicks("sim_test_001")
        result["ticks"]!!.jsonArray.size shouldBe 3
    }

    // -----------------------------------------------------------------------
    // Audit and verification
    // -----------------------------------------------------------------------

    test("audit get event") {
        val event = client.audit.getEvent("evt_test_001")
        event["event_id"]!!.jsonPrimitive.contentOrNull shouldBe "evt_test_001"
        event["event_hash"]!!.jsonPrimitive.content.shouldNotBeBlank()
    }

    test("audit get commitment") {
        val commitment = client.audit.getCommitment("cmt_test_001")
        commitment["commitment_id"]!!.jsonPrimitive.contentOrNull shouldBe "cmt_test_001"
        commitment["event_count"]!!.jsonPrimitive.int shouldBe 42
    }

    test("audit get proof") {
        val proof = client.audit.getProof("evt_test_001")
        proof["verified"]!!.jsonPrimitive.boolean shouldBe true
        proof["proof_path"]!!.jsonArray.size shouldBe 2
    }

    test("audit verify") {
        val result = client.audit.verify("evt_test_001")
        result["verified"]!!.jsonPrimitive.boolean shouldBe true
    }

    test("audit signing key") {
        val pem = client.audit.getSigningKey()
        pem shouldContain "BEGIN PUBLIC KEY"
    }

    } // if CONFORMANCE_URL
})
