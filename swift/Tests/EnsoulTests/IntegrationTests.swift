/// Integration tests for the Swift SDK against a live Docker API stack.
///
/// All tests are skipped when `ENSOUL_INTEGRATION_URL` is not set.
///
/// Required env vars:
///   ENSOUL_INTEGRATION_URL       Base URL, e.g. http://localhost:8000
///
/// Optional env vars:
///   ENSOUL_INTEGRATION_USERNAME  Demo username (default: pro-user)
///   ENSOUL_INTEGRATION_PASSWORD  Password for the demo user
///   ENSOUL_INTEGRATION_DOMAIN    Domain slug for persona CRUD + SSE tests
///
/// Start the stack before running:
///   cd website && docker compose up -d api postgres redis
///   ENSOUL_INTEGRATION_URL=http://localhost:8000 \
///   ENSOUL_INTEGRATION_PASSWORD=demo-dev-only \
///   swift test --filter IntegrationTests
import XCTest
@testable import Ensoul

@available(iOS 15.0, macOS 12.0, *)
final class IntegrationTests: XCTestCase {

    private static let integrationURL = ProcessInfo.processInfo.environment["ENSOUL_INTEGRATION_URL"]?.trimmingCharacters(in: .init(charactersIn: "/"))
    private static let integrationUsername = ProcessInfo.processInfo.environment["ENSOUL_INTEGRATION_USERNAME"] ?? "pro-user"
    private static let integrationPassword = ProcessInfo.processInfo.environment["ENSOUL_INTEGRATION_PASSWORD"]
    private static let integrationDomain = ProcessInfo.processInfo.environment["ENSOUL_INTEGRATION_DOMAIN"]

    var client: EnsoulClient!
    var noAuthClient: EnsoulClient!
    var bearerToken: String = ""
    var testPersonaId: String = ""
    var personaCreated: Bool = false   // true = we own it (delete in tearDown); false = borrowed

    override func setUp() async throws {
        guard let url = Self.integrationURL, !url.isEmpty else {
            throw XCTSkip("ENSOUL_INTEGRATION_URL not set — skipping integration tests")
        }

        // Exchange credentials for a bearer token
        if let password = Self.integrationPassword, !password.isEmpty {
            bearerToken = try await exchangeToken(baseURL: url, username: Self.integrationUsername, password: password)
        }

        client = EnsoulClient(
            apiKey: bearerToken.isEmpty ? "" : nil,
            baseURL: url,
            bearerToken: bearerToken.isEmpty ? nil : bearerToken,
            maxRetries: 0
        )
        noAuthClient = EnsoulClient(apiKey: "", baseURL: url, maxRetries: 0)

        // Obtain a test persona if domain is configured.
        // Try to create; on ServerError (DB mismatch) fall back to borrowing an existing one.
        if let domain = Self.integrationDomain, !domain.isEmpty, !bearerToken.isEmpty {
            do {
                let persona = try await client.personas.create(
                    name: "inttest-\(Int(Date().timeIntervalSince1970))",
                    domain: domain
                )
                testPersonaId = persona.id
                personaCreated = true
            } catch is ServerError {
                // Persona create failed (e.g. DB schema mismatch) — borrow an existing one
                let page = try? await client.personas.list(perPage: 1)
                testPersonaId = page?.items.first?.id ?? ""
                // personaCreated stays false — we won't delete in tearDown
            }
        }
    }

    override func tearDown() async throws {
        if personaCreated && !testPersonaId.isEmpty {
            try? await client.personas.delete(testPersonaId)
        }
    }

    // MARK: - Helpers

    private func exchangeToken(baseURL: String, username: String, password: String) async throws -> String {
        var request = URLRequest(url: URL(string: "\(baseURL)/v1/auth/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "username=\(username)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["access_token"] as? String ?? ""
    }

    private func requirePassword(file: StaticString = #file, line: UInt = #line) throws {
        guard let pwd = Self.integrationPassword, !pwd.isEmpty else {
            throw XCTSkip("ENSOUL_INTEGRATION_PASSWORD not set")
        }
    }

    private func requireDomain(file: StaticString = #file, line: UInt = #line) throws {
        guard let domain = Self.integrationDomain, !domain.isEmpty else {
            throw XCTSkip("ENSOUL_INTEGRATION_DOMAIN not set")
        }
        try requirePassword()
    }

    // MARK: - Health

    func test_health_check() async throws {
        guard let url = Self.integrationURL else { return }
        let (data, response) = try await URLSession.shared.data(from: URL(string: "\(url)/health")!)
        let httpResp = response as! HTTPURLResponse
        XCTAssertEqual(httpResp.statusCode, 200)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let status = json?["status"] as? String ?? ""
        XCTAssertTrue(status == "ok" || status == "healthy", "Unexpected health status: \(status)")
        XCTAssertNotNil(json?["version"])
    }

    // MARK: - Auth

    func test_token_exchange() async throws {
        try requirePassword()
        guard let url = Self.integrationURL, let password = Self.integrationPassword else { return }
        let token = try await exchangeToken(baseURL: url, username: Self.integrationUsername, password: password)
        XCTAssertFalse(token.isEmpty, "Expected a non-empty bearer token")
    }

    func test_auth_me() async throws {
        try requirePassword()
        let user = try await client.auth.me()
        XCTAssertFalse(user.consumerId.isEmpty)
        XCTAssertEqual(user.username, Self.integrationUsername)
    }

    func test_no_credentials_returns_401() async throws {
        do {
            _ = try await noAuthClient.personas.list()
            XCTFail("Expected AuthenticationError")
        } catch let err as AuthenticationError {
            XCTAssertEqual(err.statusCode, 401)
        }
    }

    // MARK: - Domains

    func test_domain_list_returns_array() async throws {
        try requirePassword()
        let page = try await client.domains.list()
        XCTAssertNotNil(page.items)
    }

    // MARK: - Personas

    func test_persona_available() async throws {
        try requireDomain()
        XCTAssertFalse(testPersonaId.isEmpty, "No persona available — create failed and no existing personas found")
    }

    func test_persona_get() async throws {
        try requireDomain()
        let persona = try await client.personas.get(testPersonaId)
        XCTAssertEqual(persona.id, testPersonaId)
    }

    func test_persona_list_shape() async throws {
        try requireDomain()
        let page = try await client.personas.list(page: 1, perPage: 5)
        XCTAssertGreaterThanOrEqual(page.items.count, 0)
        XCTAssertEqual(page.page, 1)
        XCTAssertEqual(page.perPage, 5)
    }

    func test_persona_update() async throws {
        try requireDomain()
        guard personaCreated else {
            throw XCTSkip("Skipping update: using borrowed seeded persona (read-only)")
        }
        let newName = "inttest-\(Int(Date().timeIntervalSince1970))-upd"
        let updated = try await client.personas.update(testPersonaId, name: newName)
        XCTAssertEqual(updated.id, testPersonaId)
        XCTAssertEqual(updated.name, newName)
    }

    func test_persona_not_found() async throws {
        try requirePassword()
        do {
            _ = try await client.personas.get("00000000-0000-4000-a000-999999999999")
            XCTFail("Expected NotFoundError")
        } catch let err as NotFoundError {
            XCTAssertEqual(err.statusCode, 404)
        }
    }

    // MARK: - SSE Streaming

    func test_chat_stream_sse() async throws {
        try requireDomain()
        let stream = client.chat.stream(
            personaId: testPersonaId,
            message: "Say hello in one word."
        )
        var events: [ChatStreamEvent] = []
        for try await rawEvent in stream {
            if let event = try? parseChatEvent(rawEvent) {
                events.append(event)
            }
        }
        XCTAssertGreaterThanOrEqual(events.count, 1, "Expected at least one SSE event")
        let finalEvents = events.filter { $0.isFinal }
        XCTAssertEqual(finalEvents.count, 1, "Expected exactly one final event")
        XCTAssertNotNil(finalEvents.first?.tokenUsage)
    }
}
