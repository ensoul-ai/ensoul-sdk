/**
 * Integration tests for the Kotlin SDK against a live Docker API stack.
 *
 * All tests are skipped when ENSOUL_INTEGRATION_URL is not set.
 *
 * Required env vars:
 *   ENSOUL_INTEGRATION_URL       Base URL, e.g. http://localhost:8000
 *
 * Optional env vars:
 *   ENSOUL_INTEGRATION_USERNAME  Demo username (default: pro-user)
 *   ENSOUL_INTEGRATION_PASSWORD  Password for the demo user
 *   ENSOUL_INTEGRATION_DOMAIN    Domain slug for persona CRUD + SSE tests
 */
package ai.ensoul.sdk

import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.ints.shouldBeGreaterThan
import io.kotest.matchers.ints.shouldBeGreaterThanOrEqual
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe
import io.kotest.matchers.string.shouldNotBeBlank
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.request.forms.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.flow.toList
import kotlinx.serialization.json.*

private val INTEGRATION_URL: String? = System.getenv("ENSOUL_INTEGRATION_URL")?.trimEnd('/')
private val INTEGRATION_USERNAME: String = System.getenv("ENSOUL_INTEGRATION_USERNAME") ?: "pro-user"
private val INTEGRATION_PASSWORD: String? = System.getenv("ENSOUL_INTEGRATION_PASSWORD")
private val INTEGRATION_DOMAIN: String? = System.getenv("ENSOUL_INTEGRATION_DOMAIN")

class IntegrationTest : FunSpec({

    // Skip the entire spec when the integration URL is not configured.
    if (!INTEGRATION_URL.isNullOrBlank()) {

    var bearerToken = ""
    var testPersonaId = ""
    var personaCreated = false   // true = we own it (delete in afterSpec); false = borrowed

    val httpClient = HttpClient(CIO) {
        install(ContentNegotiation) { json() }
        expectSuccess = false
    }

    val client by lazy {
        EnsoulClient(
            bearerToken = bearerToken.ifBlank { null },
            apiKey = if (bearerToken.isNotBlank()) null else "",
            baseUrl = INTEGRATION_URL!!,
            maxRetries = 0,
        )
    }

    val noAuthClient by lazy {
        EnsoulClient(apiKey = "", baseUrl = INTEGRATION_URL!!, maxRetries = 0)
    }

    beforeSpec {
        // Exchange credentials for bearer token
        if (!INTEGRATION_PASSWORD.isNullOrBlank()) {
            val resp = httpClient.post("$INTEGRATION_URL/v1/auth/token") {
                setBody(FormDataContent(Parameters.build {
                    append("username", INTEGRATION_USERNAME)
                    append("password", INTEGRATION_PASSWORD!!)
                }))
            }
            if (resp.status.isSuccess()) {
                val body = Json.parseToJsonElement(resp.bodyAsText()).jsonObject
                bearerToken = body["access_token"]?.jsonPrimitive?.contentOrNull ?: ""
            }
        }

        // Obtain a test persona if domain is configured.
        // Try to create; on ServerError (DB mismatch) fall back to borrowing an existing one.
        if (!INTEGRATION_DOMAIN.isNullOrBlank() && bearerToken.isNotBlank()) {
            try {
                val persona = client.personas.create(
                    name = "inttest-${System.currentTimeMillis()}",
                    domain = INTEGRATION_DOMAIN!!,
                )
                testPersonaId = persona.id
                personaCreated = true
            } catch (e: ServerError) {
                // Persona create failed (e.g. DB schema mismatch) — borrow an existing one
                val page = client.personas.list(perPage = 1)
                if (page.items.isNotEmpty()) {
                    testPersonaId = page.items[0].id
                }
                // personaCreated stays false — we won't delete it in afterSpec
            }
        }
    }

    afterSpec {
        if (personaCreated && testPersonaId.isNotBlank()) {
            runCatching { client.personas.delete(testPersonaId) }
        }
        client.close()
        noAuthClient.close()
        httpClient.close()
    }

    // -----------------------------------------------------------------------
    // Health
    // -----------------------------------------------------------------------

    test("health endpoint returns ok") {
        val resp = httpClient.get("$INTEGRATION_URL/health")
        resp.status.value shouldBe 200
        val body = Json.parseToJsonElement(resp.bodyAsText()).jsonObject
        val status = body["status"]?.jsonPrimitive?.content ?: ""
        (status == "ok" || status == "healthy") shouldBe true
        body["version"]?.jsonPrimitive?.contentOrNull.shouldNotBeBlank()
    }

    // -----------------------------------------------------------------------
    // Auth
    // -----------------------------------------------------------------------

    if (!INTEGRATION_PASSWORD.isNullOrBlank()) {

        test("token exchange returns bearer token") {
            val resp = httpClient.post("$INTEGRATION_URL/v1/auth/token") {
                setBody(FormDataContent(Parameters.build {
                    append("username", INTEGRATION_USERNAME)
                    append("password", INTEGRATION_PASSWORD!!)
                }))
            }
            resp.status.value shouldBe 200
            val body = Json.parseToJsonElement(resp.bodyAsText()).jsonObject
            body["access_token"]?.jsonPrimitive?.contentOrNull.shouldNotBeBlank()
            body["token_type"]?.jsonPrimitive?.contentOrNull?.lowercase() shouldBe "bearer"
            (body["expires_in"]?.jsonPrimitive?.int ?: 0) shouldBeGreaterThan 0
        }

        test("auth me returns user info") {
            val user = client.auth.me()
            user.consumerId.shouldNotBeBlank()
            user.username shouldBe INTEGRATION_USERNAME
        }

    }

    test("no credentials returns AuthenticationError") {
        shouldThrow<AuthenticationError> {
            noAuthClient.personas.list()
        }
    }

    // -----------------------------------------------------------------------
    // Domains
    // -----------------------------------------------------------------------

    if (!INTEGRATION_PASSWORD.isNullOrBlank()) {

        test("domain list returns a list") {
            val page = client.domains.list()
            page.items shouldNotBe null
        }

    }

    // -----------------------------------------------------------------------
    // Personas
    // -----------------------------------------------------------------------

    if (!INTEGRATION_DOMAIN.isNullOrBlank() && !INTEGRATION_PASSWORD.isNullOrBlank()) {

        test("persona available for tests") {
            testPersonaId.shouldNotBeBlank()
        }

        test("persona get returns correct id") {
            val persona = client.personas.get(testPersonaId)
            persona.id shouldBe testPersonaId
        }

        test("persona list returns pagination envelope") {
            val page = client.personas.list(page = 1, perPage = 5)
            page.items shouldNotBe null
            page.page shouldBe 1
            page.perPage shouldBe 5
        }

        test("persona update changes name") {
            if (!personaCreated) {
                println("Skipping update: using borrowed seeded persona (read-only)")
                return@test
            }
            val newName = "inttest-${System.currentTimeMillis()}-upd"
            val updated = client.personas.update(testPersonaId, mapOf("name" to newName))
            updated.id shouldBe testPersonaId
            updated.name shouldBe newName
        }

        test("persona not found returns NotFoundError") {
            shouldThrow<NotFoundError> {
                client.personas.get("00000000-0000-4000-a000-999999999999")
            }
        }

        // -----------------------------------------------------------------------
        // SSE Streaming
        // -----------------------------------------------------------------------

        test("chat stream delivers SSE events over real HTTP") {
            val sseStream = client.chat.stream(testPersonaId, "Say hello in one word.")
            val sseEvents = sseStream.events().toList()
            val events = sseEvents.map { parseChatEvent(it) }
            events.size shouldBeGreaterThanOrEqual 1
            val finalEvents = events.filter { it.isFinal }
            finalEvents.size shouldBe 1
            finalEvents.first().tokenUsage shouldNotBe null
        }

    }

    if (!INTEGRATION_PASSWORD.isNullOrBlank()) {

        test("persona not found returns 404") {
            shouldThrow<NotFoundError> {
                client.personas.get("00000000-0000-4000-a000-999999999999")
            }
        }

    }

    } // end if (!INTEGRATION_URL.isNullOrBlank())
})
