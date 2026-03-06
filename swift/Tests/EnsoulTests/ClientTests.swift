/// Tests for EnsoulClient — initialization, resource namespaces, and version.
import XCTest
@testable import Ensoul

@available(iOS 15.0, macOS 12.0, *)
final class ClientTests: XCTestCase {

    // MARK: - Version

    func test_client_version_is_0_1_0() {
        XCTAssertEqual(EnsoulClient.version, "0.1.0")
    }

    // MARK: - Init with API key

    func test_client_init_withAPIKey_doesNotCrash() {
        let client = EnsoulClient(apiKey: "ens_test_key")
        XCTAssertNotNil(client)
    }

    func test_client_init_withAPIKey_exposesAllNamespaces() {
        let client = EnsoulClient(apiKey: "ens_test")
        assertAllNamespacesPresent(client)
    }

    // MARK: - Init from environment variable

    func test_client_init_noAPIKey_usesEnvVar() {
        // We cannot safely mutate ProcessInfo.environment in-process on Apple platforms,
        // but we can verify the client initialises without crashing when no key is provided.
        // The env var ENSOUL_API_KEY is likely not set in CI, so apiKey will be nil — fine.
        let client = EnsoulClient()
        XCTAssertNotNil(client)
    }

    // MARK: - Init with bearer token

    func test_client_init_withBearerToken_doesNotCrash() {
        let client = EnsoulClient(bearerToken: "eyJhbGci.tok.sig")
        XCTAssertNotNil(client)
    }

    // MARK: - Init with custom base URL

    func test_client_init_withCustomBaseURL_doesNotCrash() {
        let client = EnsoulClient(
            apiKey: "ens_test",
            baseURL: "https://staging.ensoul.ai"
        )
        XCTAssertNotNil(client)
    }

    // MARK: - Init with custom URLSession (mock)

    func test_client_init_withMockSession_doesNotCrash() {
        let session = MockURLProtocol.makeSession()
        let client = EnsoulClient(apiKey: "ens_test", session: session)
        XCTAssertNotNil(client)
    }

    // MARK: - All 11 resource namespaces are present

    func test_client_exposes_personas_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.personas)
    }

    func test_client_exposes_chat_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.chat)
    }

    func test_client_exposes_domains_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.domains)
    }

    func test_client_exposes_simulations_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.simulations)
    }

    func test_client_exposes_aggregate_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.aggregate)
    }

    func test_client_exposes_memory_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.memory)
    }

    func test_client_exposes_sessions_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.sessions)
    }

    func test_client_exposes_frameworks_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.frameworks)
    }

    func test_client_exposes_auth_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.auth)
    }

    func test_client_exposes_health_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.health)
    }

    func test_client_exposes_info_namespace() {
        let client = EnsoulClient(apiKey: "ens_test")
        XCTAssertNotNil(client.info)
    }

    // MARK: - Private helpers

    private func assertAllNamespacesPresent(_ client: EnsoulClient) {
        XCTAssertNotNil(client.personas)
        XCTAssertNotNil(client.chat)
        XCTAssertNotNil(client.domains)
        XCTAssertNotNil(client.simulations)
        XCTAssertNotNil(client.aggregate)
        XCTAssertNotNil(client.memory)
        XCTAssertNotNil(client.sessions)
        XCTAssertNotNil(client.frameworks)
        XCTAssertNotNil(client.auth)
        XCTAssertNotNil(client.health)
        XCTAssertNotNil(client.info)
    }
}
