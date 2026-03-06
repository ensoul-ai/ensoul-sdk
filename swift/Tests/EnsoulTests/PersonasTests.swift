/// Tests for the Personas resource using MockURLProtocol.
import XCTest
@testable import Ensoul

@available(iOS 15.0, macOS 12.0, *)
final class PersonasTests: XCTestCase {

    private var session: URLSession!

    override func setUp() {
        super.setUp()
        session = MockURLProtocol.makeSession()
        MockURLProtocol.requestHandler = nil
    }

    // MARK: - Helper

    private func makeClient() -> EnsoulClient {
        EnsoulClient(apiKey: "ens_test_key", session: session)
    }

    private func makePersonaURL(id: String? = nil) -> URL {
        if let id {
            return URL(string: "https://api.ensoul.ai/v1/personas/\(id)")!
        }
        return URL(string: "https://api.ensoul.ai/v1/personas")!
    }

    // MARK: - Create persona

    func test_personas_create_sendsPostToCorrectEndpoint() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 201)
            let data = PersonaFixtures.data(PersonaFixtures.alexRivera)
            return (response, data)
        }

        let client = makeClient()
        _ = try await client.personas.create(name: "Alex Rivera", domain: "test_domain_a")

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        let urlString = capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.hasSuffix("/v1/personas"), "Expected POST to /v1/personas, got \(urlString)")
    }

    func test_personas_create_decodesPersonaResponse() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 201)
            return (response, PersonaFixtures.data(PersonaFixtures.alexRivera))
        }

        let client = makeClient()
        let persona = try await client.personas.create(name: "Alex Rivera", domain: "test_domain_a")

        XCTAssertEqual(persona.id, "persona_test_001")
        XCTAssertEqual(persona.name, "Alex Rivera")
        XCTAssertEqual(persona.domain, "test_domain_a")
        XCTAssertEqual(persona.archetype, "creative_professional")
        XCTAssertEqual(persona.age, 32)
    }

    func test_personas_create_requestContainsAPIKeyHeader() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 201)
            return (response, PersonaFixtures.data(PersonaFixtures.alexRivera))
        }

        let client = makeClient()
        _ = try await client.personas.create(name: "Alex Rivera", domain: "test_domain_a")

        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "X-API-Key"), "ens_test_key")
    }

    // MARK: - Get persona

    func test_personas_get_sendsGetToCorrectEndpoint() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.alexRivera))
        }

        let client = makeClient()
        _ = try await client.personas.get("persona_test_001")

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        let urlString = capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(
            urlString.hasSuffix("/v1/personas/persona_test_001"),
            "Expected GET /v1/personas/persona_test_001, got \(urlString)"
        )
    }

    func test_personas_get_decodesPersonaResponse() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.alexRivera))
        }

        let client = makeClient()
        let persona = try await client.personas.get("persona_test_001")

        XCTAssertEqual(persona.id, "persona_test_001")
        XCTAssertEqual(persona.name, "Alex Rivera")
        XCTAssertEqual(persona.createdAt, "2025-01-15T10:30:00Z")
    }

    // MARK: - Get 404

    func test_personas_get_404_throwsNotFoundError() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas/bad_id")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 404)
            return (response, ErrorFixtures.data(ErrorFixtures.personaNotFound))
        }

        let client = makeClient()
        do {
            _ = try await client.personas.get("bad_id")
            XCTFail("Expected NotFoundError to be thrown")
        } catch let error as NotFoundError {
            XCTAssertEqual(error.statusCode, 404)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - List personas

    func test_personas_list_sendsGetRequest() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.listEnvelope()))
        }

        let client = makeClient()
        _ = try await client.personas.list()

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
    }

    func test_personas_list_decodesPageWithItems() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.listEnvelope()))
        }

        let client = makeClient()
        let page = try await client.personas.list()

        XCTAssertEqual(page.items.count, 2)
        XCTAssertEqual(page.total, 2)
        XCTAssertEqual(page.page, 1)
        XCTAssertEqual(page.perPage, 20)
        XCTAssertEqual(page.pages, 1)
    }

    func test_personas_list_firstItemMatchesFixture() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.listEnvelope()))
        }

        let client = makeClient()
        let page = try await client.personas.list()

        XCTAssertEqual(page.items[0].id, "persona_test_001")
        XCTAssertEqual(page.items[1].id, "persona_test_002")
    }

    func test_personas_list_hasNextPage_returnsFalseOnSinglePage() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.listEnvelope(page: 1, pages: 1)))
        }

        let client = makeClient()
        let page = try await client.personas.list()

        XCTAssertFalse(page.hasNextPage())
    }

    func test_personas_list_hasNextPage_returnsTrueWhenMorePages() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.listEnvelope(page: 1, pages: 3)))
        }

        let client = makeClient()
        let page = try await client.personas.list()

        XCTAssertTrue(page.hasNextPage())
    }

    // MARK: - Delete persona

    func test_personas_delete_sendsDeleteRequest() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 204)
            return (response, Data())
        }

        let client = makeClient()
        try await client.personas.delete("persona_test_001")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        let urlString = capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.hasSuffix("/v1/personas/persona_test_001"))
    }

    func test_personas_delete_doesNotThrow_on204() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 204)
            return (response, Data())
        }

        let client = makeClient()
        // If this throws the test fails automatically (async throws test function)
        try await client.personas.delete("persona_test_001")
    }
}
