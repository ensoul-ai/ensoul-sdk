/// Tests for ClientConfig — defaults, custom values, and derived apiURL.
import XCTest
@testable import Ensoul

final class ConfigTests: XCTestCase {

    // MARK: - Default values

    func test_config_defaultBaseURL() {
        let config = ClientConfig()
        XCTAssertEqual(config.baseURL, "https://api.ensoul-ai.com")
    }

    func test_config_defaultTimeout() {
        let config = ClientConfig()
        XCTAssertEqual(config.timeout, 30)
    }

    func test_config_defaultMaxRetries() {
        let config = ClientConfig()
        XCTAssertEqual(config.maxRetries, 2)
    }

    func test_config_defaultAPIKeyIsNil() {
        let config = ClientConfig()
        XCTAssertNil(config.apiKey)
    }

    func test_config_defaultBearerTokenIsNil() {
        let config = ClientConfig()
        XCTAssertNil(config.bearerToken)
    }

    func test_config_defaultCustomHeadersIsEmpty() {
        let config = ClientConfig()
        XCTAssertTrue(config.customHeaders.isEmpty)
    }

    // MARK: - Custom values

    func test_config_customAPIKey() {
        let config = ClientConfig(apiKey: "ens_test_key")
        XCTAssertEqual(config.apiKey, "ens_test_key")
    }

    func test_config_customBearerToken() {
        let config = ClientConfig(bearerToken: "eyJhbGci.payload.sig")
        XCTAssertEqual(config.bearerToken, "eyJhbGci.payload.sig")
    }

    func test_config_customBaseURL() {
        let config = ClientConfig(baseURL: "https://staging.ensoul.ai")
        XCTAssertEqual(config.baseURL, "https://staging.ensoul.ai")
    }

    func test_config_customTimeout() {
        let config = ClientConfig(timeout: 60)
        XCTAssertEqual(config.timeout, 60)
    }

    func test_config_customMaxRetries() {
        let config = ClientConfig(maxRetries: 5)
        XCTAssertEqual(config.maxRetries, 5)
    }

    func test_config_customHeaders() {
        let config = ClientConfig(customHeaders: ["X-Tenant": "acme"])
        XCTAssertEqual(config.customHeaders["X-Tenant"], "acme")
    }

    // MARK: - apiURL derived property

    func test_config_apiURL_appendsVersionToBaseURL() {
        let config = ClientConfig(baseURL: "https://api.ensoul-ai.com")
        XCTAssertEqual(config.apiURL, "https://api.ensoul-ai.com/v1")
    }

    func test_config_apiURL_stripsTrailingSlash() {
        let config = ClientConfig(baseURL: "https://api.ensoul-ai.com/")
        XCTAssertEqual(config.apiURL, "https://api.ensoul-ai.com/v1")
    }

    func test_config_apiURL_stripsMultipleTrailingSlashes() {
        let config = ClientConfig(baseURL: "https://api.ensoul-ai.com///")
        XCTAssertEqual(config.apiURL, "https://api.ensoul-ai.com/v1")
    }

    func test_config_apiURL_customBaseURL() {
        let config = ClientConfig(baseURL: "https://staging.ensoul.ai")
        XCTAssertEqual(config.apiURL, "https://staging.ensoul.ai/v1")
    }

    func test_config_apiURL_localhostBaseURL() {
        let config = ClientConfig(baseURL: "http://localhost:8000")
        XCTAssertEqual(config.apiURL, "http://localhost:8000/v1")
    }
}
