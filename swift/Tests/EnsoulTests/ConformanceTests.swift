/// Cross-SDK conformance tests for the Swift SDK.
///
/// These tests run against a mock server started by the conformance orchestrator.
/// They are automatically skipped when `ENSOUL_CONFORMANCE_URL` is not set,
/// so regular `swift test` runs are unaffected.
///
/// Mock server details:
///   - Auth: accepts `X-Api-Key: sk_test_123` or `Authorization: Bearer test_token_123`
///   - Trigger headers: `X-Trigger-RateLimit: true` -> 429, `X-Trigger-ServerError: true` -> 500
///   - Empty POST body to /v1/personas -> 422 with details array
///   - GET /v1/personas/nonexistent_persona_id -> 404
import XCTest
@testable import Ensoul

@available(iOS 15.0, macOS 12.0, *)
final class ConformanceTests: XCTestCase {

    var client: EnsoulClient!

    /// Base URL of the conformance mock server.
    /// When not set, every test in this class is skipped via `XCTSkip`.
    private static let conformanceURL = ProcessInfo.processInfo.environment["ENSOUL_CONFORMANCE_URL"]

    override func setUp() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set — skipping conformance tests")
        }
        client = EnsoulClient(
            apiKey: "sk_test_123",
            baseURL: url,
            maxRetries: 0,
            customHeaders: ["X-SDK-Language": "swift"]
        )
    }

    // MARK: - Personas

    /// 1. Create a persona and verify the response fields match the fixture.
    func test_persona_create() async throws {
        let persona = try await client.personas.create(
            name: "Test Persona",
            domain: "test_domain"
        )
        XCTAssertEqual(persona.id, "p_test_001")
        XCTAssertEqual(persona.name, "Test Persona")
        XCTAssertEqual(persona.domain, "test_domain")
    }

    /// 2. Get a persona by ID and verify the response.
    func test_persona_get() async throws {
        let persona = try await client.personas.get("p_test_001")
        XCTAssertEqual(persona.id, "p_test_001")
        XCTAssertEqual(persona.name, "Test Persona")
        XCTAssertEqual(persona.domain, "test_domain")
    }

    /// 3. List personas with pagination and verify envelope fields.
    func test_persona_list_pagination() async throws {
        let page = try await client.personas.list(page: 1, perPage: 10)
        XCTAssertGreaterThanOrEqual(page.items.count, 1)
        XCTAssertEqual(page.total, 25)
        XCTAssertEqual(page.page, 1)
        XCTAssertEqual(page.perPage, 10)
        XCTAssertEqual(page.pages, 3)
    }

    /// 4. Getting a nonexistent persona throws NotFoundError with status 404.
    func test_persona_not_found() async throws {
        do {
            _ = try await client.personas.get("nonexistent_persona_id")
            XCTFail("Expected NotFoundError to be thrown")
        } catch let error as NotFoundError {
            XCTAssertEqual(error.statusCode, 404)
        } catch {
            XCTFail("Expected NotFoundError, got \(type(of: error)): \(error)")
        }
    }

    /// 15. Update a persona and verify the response fields.
    func test_persona_update() async throws {
        let persona = try await client.personas.update(
            "p_test_001",
            name: "Updated Persona"
        )
        XCTAssertEqual(persona.id, "p_test_001")
        XCTAssertEqual(persona.name, "Updated Persona")
    }

    /// 16. Delete a persona — should not throw.
    func test_persona_delete() async throws {
        do {
            try await client.personas.delete("p_test_001")
        } catch {
            XCTFail("Expected delete to succeed without throwing, got: \(error)")
        }
    }

    // MARK: - Chat

    /// 5. Send a chat message and verify the response fields.
    func test_chat_send() async throws {
        let response = try await client.chat.send(
            personaId: "p_test_001",
            message: "Hello, how are you?"
        )
        XCTAssertFalse(response.response.isEmpty)
        XCTAssertFalse(response.conversationId.isEmpty)
        XCTAssertGreaterThan(response.tokenUsage.totalTokens, 0)
    }

    /// 6. Stream a chat via SSE and verify chunk ordering and final event.
    func test_chat_stream_sse() async throws {
        let stream = client.chat.stream(
            personaId: "p_test_001",
            message: "Tell me about yourself."
        )

        var events: [ChatStreamEvent] = []
        for try await rawEvent in stream {
            let chatEvent = try parseChatEvent(rawEvent)
            events.append(chatEvent)
        }

        XCTAssertEqual(events.count, 5, "Expected 5 SSE chunk events")

        // Check chunk ordering and conversation ID
        for (i, event) in events.enumerated() {
            XCTAssertEqual(event.chunkIndex, i, "Chunk index mismatch at position \(i)")
            XCTAssertEqual(event.conversationId, "conv_stream_001")
        }

        // Final event has is_final=true and token_usage
        let lastEvent = events[events.count - 1]
        XCTAssertTrue(lastEvent.isFinal)
        XCTAssertNotNil(lastEvent.tokenUsage)
        XCTAssertGreaterThan(lastEvent.tokenUsage?["total_tokens"] ?? 0, 0)

        // Non-final events have is_final=false
        for event in events.dropLast() {
            XCTAssertFalse(event.isFinal)
        }
    }

    /// 17. Get conversations for a persona and verify pagination envelope.
    func test_chat_get_conversations() async throws {
        let page = try await client.chat.getConversations(personaId: "p_test_001")
        XCTAssertGreaterThanOrEqual(page.items.count, 1)
        XCTAssertEqual(page.total, 2)
    }

    // MARK: - Domains

    /// 7. List domains and verify at least one item is returned.
    func test_domain_list() async throws {
        let page = try await client.domains.list()
        XCTAssertGreaterThanOrEqual(page.items.count, 1)
    }

    /// 18. Get a single domain by ID and verify response fields.
    func test_domain_get() async throws {
        let domain = try await client.domains.get("d_test_001")
        XCTAssertEqual(domain["id"] as? String, "d_test_001")
        XCTAssertEqual(domain["name"] as? String, "Test Domain")
    }

    // MARK: - Simulations

    /// 19. Create a simulation and verify the response fields.
    func test_simulation_create() async throws {
        let sim = try await client.simulations.create(
            name: "Test Simulation",
            domainId: "d_test_001"
        )
        XCTAssertEqual(sim.id, "sim_test_001")
        XCTAssertEqual(sim.status, .created)
    }

    /// 20. Start a simulation and verify the response fields.
    func test_simulation_start() async throws {
        let result = try await client.simulations.start("sim_test_001", ticks: 50)
        XCTAssertEqual(result["status"] as? String, "running")
        XCTAssertEqual(result["ticks_requested"] as? Int, 50)
    }

    // MARK: - Memory

    /// 21. Create a memory and verify the response fields.
    func test_memory_create() async throws {
        let mem = try await client.memory.create(
            personaId: "p_test_001",
            content: "Remembers meeting a friend at the park",
            memoryType: "episodic",
            importance: 0.7
        )
        XCTAssertEqual(mem["id"] as? String, "mem_test_001")
    }

    /// 22. Delete a memory — should not throw.
    func test_memory_delete() async throws {
        do {
            try await client.memory.delete(personaId: "p_test_001", memoryId: "mem_test_001")
        } catch {
            XCTFail("Expected delete to succeed without throwing, got: \(error)")
        }
    }

    // MARK: - Sessions

    /// 23. Create a session and verify the response fields.
    func test_session_create() async throws {
        let session = try await client.sessions.create(
            personaId: "p_test_001",
            tier: 0
        )
        XCTAssertEqual(session["id"] as? String, "sess_test_001")
        XCTAssertEqual(session["tier"] as? Int, 0)
        XCTAssertTrue(session["parent_session_id"] is NSNull || session["parent_session_id"] == nil)
    }

    // MARK: - Aggregate

    /// 24. Run an aggregate query and verify the response fields.
    func test_aggregate_query() async throws {
        let result = try await client.aggregate.query("average trait_a by region")
        XCTAssertEqual(result["sample_size"] as? Int, 500)
        XCTAssertEqual(result["confidence"] as? Double, 0.95)
    }

    // MARK: - Health

    /// 25. Check the health endpoint and verify the status field.
    func test_health_check() async throws {
        let result = try await client.health.check()
        XCTAssertEqual(result["status"] as? String, "ok")
    }

    // MARK: - Info

    /// 26. Get the info config and verify the response fields.
    func test_info_config() async throws {
        let result = try await client.info.config()
        XCTAssertEqual(result["api_version"] as? String, "1.0.0")
        XCTAssertEqual(result["max_batch_size"] as? Int, 100)
    }

    // MARK: - Auth Resources

    /// 27. Exchange credentials for a token via form POST.
    func test_auth_token_exchange() async throws {
        let tokenResp = try await client.auth.token(
            username: "testuser",
            password: "testpass"
        )
        XCTAssertFalse(tokenResp.accessToken.isEmpty)
        XCTAssertEqual(tokenResp.tokenType, "bearer")
    }

    /// 28. Get the current user info via GET /v1/auth/me.
    func test_auth_me() async throws {
        let user = try await client.auth.me()
        XCTAssertEqual(user.consumerId, "user_test_001")
    }

    // MARK: - Frameworks

    /// 29. Update a framework and verify the response fields.
    func test_framework_update() async throws {
        let fw = try await client.frameworks.update(
            "fw_test_001",
            body: [
                "name": "Big Five Updated",
                "description": "Updated five-factor personality model",
            ]
        )
        XCTAssertEqual(fw["id"] as? String, "fw_test_001")
        XCTAssertEqual(fw["name"] as? String, "Big Five Updated")
    }

    // MARK: - Errors

    /// 8. Trigger a rate-limit error (429) via X-Trigger-RateLimit header.
    func test_error_rate_limit() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let triggerClient = EnsoulClient(
            apiKey: "sk_test_123",
            baseURL: url,
            maxRetries: 0,
            customHeaders: ["X-Trigger-RateLimit": "true"]
        )
        do {
            _ = try await triggerClient.personas.list()
            XCTFail("Expected RateLimitError to be thrown")
        } catch let error as RateLimitError {
            XCTAssertEqual(error.retryAfter, 30)
        } catch {
            XCTFail("Expected RateLimitError, got \(type(of: error)): \(error)")
        }
    }

    /// 9. Empty POST body triggers validation error (422) with details.
    func test_error_validation() async throws {
        do {
            // Send an empty body to /v1/personas — mock returns 422 with details
            _ = try await client.personas.create(name: "", domain: "")
            XCTFail("Expected ValidationError to be thrown")
        } catch let error as ValidationError {
            XCTAssertEqual(error.statusCode, 422)
            XCTAssertGreaterThanOrEqual(error.details.count, 1)
        } catch {
            XCTFail("Expected ValidationError, got \(type(of: error)): \(error)")
        }
    }

    /// 10. No auth credentials result in AuthenticationError (401).
    func test_error_authentication() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let noAuthClient = EnsoulClient(
            apiKey: "",
            baseURL: url,
            maxRetries: 0
        )
        do {
            _ = try await noAuthClient.personas.list()
            XCTFail("Expected AuthenticationError to be thrown")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error.statusCode, 401)
        } catch {
            XCTFail("Expected AuthenticationError, got \(type(of: error)): \(error)")
        }
    }

    /// 11. Trigger a server error (500) via X-Trigger-ServerError header.
    func test_error_server() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let triggerClient = EnsoulClient(
            apiKey: "sk_test_123",
            baseURL: url,
            maxRetries: 0,
            customHeaders: ["X-Trigger-ServerError": "true"]
        )
        do {
            _ = try await triggerClient.personas.list()
            XCTFail("Expected ServerError to be thrown")
        } catch let error as ServerError {
            XCTAssertEqual(error.statusCode, 500)
        } catch {
            XCTFail("Expected ServerError, got \(type(of: error)): \(error)")
        }
    }

    /// 30. Trigger a 403 Forbidden via X-Trigger-Forbidden header.
    func test_error_authorization_forbidden() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let forbiddenClient = EnsoulClient(
            apiKey: "sk_test_123",
            baseURL: url,
            maxRetries: 0,
            customHeaders: ["X-Trigger-Forbidden": "true"]
        )
        do {
            _ = try await forbiddenClient.personas.list()
            XCTFail("Expected AuthorizationError to be thrown")
        } catch let error as AuthorizationError {
            XCTAssertEqual(error.statusCode, 403)
        } catch {
            XCTFail("Expected AuthorizationError, got \(type(of: error)): \(error)")
        }
    }

    /// 31. Retry on 503 — first request returns 503, retry succeeds.
    func test_error_retry_503() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let retryClient = EnsoulClient(
            apiKey: "sk_test_123",
            baseURL: url,
            maxRetries: 2,
            customHeaders: [
                "X-Trigger-503-Once": "true",
                "X-SDK-Language": "swift-retry",
            ]
        )
        // The first request triggers a 503; the retry should succeed
        let page = try await retryClient.personas.list()
        XCTAssertGreaterThanOrEqual(page.items.count, 1)
    }

    // MARK: - Auth

    /// 12. Verify the SDK sends X-Api-Key header that the mock server accepts.
    func test_auth_api_key_header() async throws {
        // If personas.list() succeeds, the mock server accepted our X-Api-Key header
        let page = try await client.personas.list()
        XCTAssertGreaterThanOrEqual(page.items.count, 1)
    }

    /// 13. No credentials produce AuthenticationError.
    func test_auth_no_credentials() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let noAuthClient = EnsoulClient(
            apiKey: "",
            baseURL: url,
            maxRetries: 0
        )
        do {
            _ = try await noAuthClient.personas.list()
            XCTFail("Expected AuthenticationError to be thrown")
        } catch is AuthenticationError {
            // Pass — the mock server rejected the empty API key as expected
        } catch {
            XCTFail("Expected AuthenticationError, got \(type(of: error)): \(error)")
        }
    }

    /// 32. Verify bearer token authentication works.
    func test_auth_bearer_token() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let bearerClient = EnsoulClient(
            baseURL: url,
            bearerToken: "test_token_123",
            maxRetries: 0,
            customHeaders: ["X-SDK-Language": "swift"]
        )
        let page = try await bearerClient.personas.list()
        XCTAssertGreaterThanOrEqual(page.items.count, 1)
    }

    // MARK: - Pagination

    /// 33. Auto-pagination collects all items across multiple pages.
    func test_pagination_auto_fetch() async throws {
        let page = try await client.frameworks.list(perPage: 2)
        // Page 1 has 2 items, page 2 has 1 item = 3 total
        // Frameworks.list returns RawPage which doesn't support auto-paging,
        // so we manually collect across pages.
        var allItems = page.items
        var currentPage = page
        while currentPage.hasNextPage {
            // Fetch next page by incrementing the page number
            let nextPageNum = currentPage.page + 1
            currentPage = try await client.frameworks.list(page: nextPageNum, perPage: 2)
            allItems.append(contentsOf: currentPage.items)
        }
        XCTAssertEqual(allItems.count, 3)
    }

    // MARK: - Client Configuration

    /// 14. Verify the client respects a custom base URL by connecting to the mock server.
    func test_client_custom_base_url() async throws {
        guard let url = Self.conformanceURL else {
            throw XCTSkip("ENSOUL_CONFORMANCE_URL not set")
        }
        let customClient = EnsoulClient(
            apiKey: "sk_test_123",
            baseURL: url,
            maxRetries: 0
        )
        let page = try await customClient.personas.list()
        XCTAssertGreaterThanOrEqual(page.items.count, 1)
    }
}
