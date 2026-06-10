/// Tests for the Ensoul error hierarchy and raiseForStatus dispatcher.
import XCTest
@testable import Ensoul

@available(iOS 15.0, macOS 12.0, *)
final class ErrorTests: XCTestCase {

    // MARK: - EnsoulAPIError base class

    func test_ensoulAPIError_isEnsoulError() {
        let error = EnsoulAPIError(statusCode: 500, error: "Server Error", message: "boom")
        XCTAssertTrue(error is any EnsoulError)
    }

    func test_ensoulAPIError_storesAllFields() {
        let error = EnsoulAPIError(
            statusCode: 400,
            error: "Bad Request",
            message: "Invalid input",
            requestId: "req_abc"
        )
        XCTAssertEqual(error.statusCode, 400)
        XCTAssertEqual(error.error, "Bad Request")
        XCTAssertEqual(error.message, "Invalid input")
        XCTAssertEqual(error.requestId, "req_abc")
    }

    func test_ensoulAPIError_requestId_isNilWhenOmitted() {
        let error = EnsoulAPIError(statusCode: 500, error: "Err", message: "msg")
        XCTAssertNil(error.requestId)
    }

    func test_ensoulAPIError_errorDescription_containsStatusAndCode() {
        let error = EnsoulAPIError(statusCode: 404, error: "Not Found", message: "Gone")
        let desc = error.errorDescription ?? ""
        XCTAssertTrue(desc.contains("404"))
        XCTAssertTrue(desc.contains("Not Found"))
    }

    // MARK: - AuthenticationError (401)

    func test_authenticationError_inheritsFromEnsoulAPIError() {
        let error = AuthenticationError(statusCode: 401, error: "Unauthorized", message: "Token expired")
        XCTAssertTrue(error is EnsoulAPIError)
        XCTAssertTrue(error is any EnsoulError)
        XCTAssertEqual(error.statusCode, 401)
    }

    // MARK: - AuthorizationError (403)

    func test_authorizationError_storesTierFields() {
        let error = AuthorizationError(
            statusCode: 403,
            error: "Forbidden",
            message: "Pro tier required",
            requestId: nil,
            requiredTier: "PRO",
            currentTier: "FREE"
        )
        XCTAssertEqual(error.requiredTier, "PRO")
        XCTAssertEqual(error.currentTier, "FREE")
        XCTAssertEqual(error.statusCode, 403)
    }

    func test_authorizationError_tierFieldsNilByDefault() {
        let error = AuthorizationError(statusCode: 403, error: "Forbidden", message: "Denied")
        XCTAssertNil(error.requiredTier)
        XCTAssertNil(error.currentTier)
    }

    // MARK: - NotFoundError (404)

    func test_notFoundError_storesResourceFields() {
        let error = NotFoundError(
            statusCode: 404,
            error: "Not Found",
            message: "Persona not found",
            requestId: "req_x",
            resourceType: "persona",
            resourceId: "persona_001"
        )
        XCTAssertEqual(error.resourceType, "persona")
        XCTAssertEqual(error.resourceId, "persona_001")
    }

    // MARK: - RateLimitError (429)

    func test_rateLimitError_storesRetryAfter() {
        let error = RateLimitError(
            statusCode: 429,
            error: "Rate Limit Exceeded",
            message: "Slow down",
            retryAfter: 30.0
        )
        XCTAssertEqual(error.retryAfter, 30.0)
    }

    func test_rateLimitError_retryAfterDefaultsToZero() {
        let error = RateLimitError(statusCode: 429, error: "Rate Limit", message: "Too fast")
        XCTAssertEqual(error.retryAfter, 0)
    }

    // MARK: - ValidationError (422)

    func test_validationError_storesDetails() {
        let details = [
            ErrorDetail(field: "body.name", message: "field required", type: "missing"),
            ErrorDetail(field: "body.domain", message: "field required", type: "missing"),
        ]
        let error = ValidationError(
            statusCode: 422,
            error: "Validation Error",
            message: "Request validation failed",
            details: details
        )
        XCTAssertEqual(error.details.count, 2)
        XCTAssertEqual(error.details[0].field, "body.name")
        XCTAssertEqual(error.details[0].type, "missing")
    }

    // MARK: - ConflictError / ServerError

    func test_conflictError_isAPIError() {
        let error = ConflictError(statusCode: 409, error: "Conflict", message: "Already exists")
        XCTAssertTrue(error is EnsoulAPIError)
        XCTAssertEqual(error.statusCode, 409)
    }

    func test_serverError_isAPIError() {
        let error = ServerError(statusCode: 500, error: "Internal Server Error", message: "boom")
        XCTAssertTrue(error is EnsoulAPIError)
        XCTAssertEqual(error.statusCode, 500)
    }

    // MARK: - raiseForStatus: 2xx does NOT throw

    func test_raiseForStatus_200_doesNotThrow() throws {
        let response = makeHTTPResponse(statusCode: 200)
        XCTAssertNoThrow(try raiseForStatus(data: Data(), response: response))
    }

    func test_raiseForStatus_201_doesNotThrow() throws {
        let response = makeHTTPResponse(statusCode: 201)
        XCTAssertNoThrow(try raiseForStatus(data: Data(), response: response))
    }

    func test_raiseForStatus_204_doesNotThrow() throws {
        let response = makeHTTPResponse(statusCode: 204)
        XCTAssertNoThrow(try raiseForStatus(data: Data(), response: response))
    }

    // MARK: - raiseForStatus: fixture-driven error mapping

    func test_raiseForStatus_401_invalidToken_throwsAuthenticationError() throws {
        let response = makeHTTPResponse(statusCode: 401)
        let data = ErrorFixtures.data(ErrorFixtures.invalidToken)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            let authErr = try? XCTUnwrap(error as? AuthenticationError)
            XCTAssertEqual(authErr?.statusCode, 401)
            XCTAssertEqual(authErr?.error, "Unauthorized")
            XCTAssertEqual(authErr?.message, "Invalid or expired access token")
            XCTAssertEqual(authErr?.requestId, "req_test_401_a")
        }
    }

    func test_raiseForStatus_401_missingAuth_throwsAuthenticationError() throws {
        let response = makeHTTPResponse(statusCode: 401)
        let data = ErrorFixtures.data(ErrorFixtures.missingAuth)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            XCTAssertTrue(error is AuthenticationError)
        }
    }

    func test_raiseForStatus_403_throwsAuthorizationError() throws {
        let response = makeHTTPResponse(statusCode: 403)
        let data = ErrorFixtures.data(ErrorFixtures.insufficientTier)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            let authzErr = try? XCTUnwrap(error as? AuthorizationError)
            XCTAssertEqual(authzErr?.statusCode, 403)
            XCTAssertEqual(authzErr?.error, "Forbidden")
        }
    }

    func test_raiseForStatus_404_persona_throwsNotFoundError() throws {
        let response = makeHTTPResponse(statusCode: 404)
        let data = ErrorFixtures.data(ErrorFixtures.personaNotFound)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            let notFound = try? XCTUnwrap(error as? NotFoundError)
            XCTAssertEqual(notFound?.statusCode, 404)
            XCTAssertEqual(notFound?.message, "Persona not found")
            XCTAssertEqual(notFound?.requestId, "req_test_404_a")
        }
    }

    func test_raiseForStatus_404_domain_throwsNotFoundError() throws {
        let response = makeHTTPResponse(statusCode: 404)
        let data = ErrorFixtures.data(ErrorFixtures.domainNotFound)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            XCTAssertTrue(error is NotFoundError)
        }
    }

    func test_raiseForStatus_409_throwsConflictError() throws {
        let response = makeHTTPResponse(statusCode: 409)
        let data = ErrorFixtures.data(ErrorFixtures.conflict)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            XCTAssertTrue(error is ConflictError)
        }
    }

    func test_raiseForStatus_422_throwsValidationError_withDetails() throws {
        let response = makeHTTPResponse(statusCode: 422)
        let data = ErrorFixtures.data(ErrorFixtures.validationError)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            let valErr = try? XCTUnwrap(error as? ValidationError)
            XCTAssertEqual(valErr?.details.count, 2)
            XCTAssertEqual(valErr?.details[0].field, "body.name")
            XCTAssertEqual(valErr?.details[1].field, "body.domain")
        }
    }

    func test_raiseForStatus_429_throwsRateLimitError_withRetryAfter() throws {
        let response = makeHTTPResponse(
            statusCode: 429,
            headers: ErrorFixtures.rateLimitHeaders
        )
        let data = ErrorFixtures.data(ErrorFixtures.rateLimitBody)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            let rl = try? XCTUnwrap(error as? RateLimitError)
            XCTAssertEqual(rl?.retryAfter, 30.0)
            XCTAssertEqual(rl?.message, "Too many requests. Please wait before retrying.")
        }
    }

    func test_raiseForStatus_500_throwsServerError() throws {
        let response = makeHTTPResponse(statusCode: 500)
        let data = ErrorFixtures.data(ErrorFixtures.internalError)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            XCTAssertTrue(error is ServerError)
            let se = error as? ServerError
            XCTAssertEqual(se?.statusCode, 500)
        }
    }

    func test_raiseForStatus_503_throwsServerError() throws {
        let response = makeHTTPResponse(
            statusCode: 503,
            headers: ErrorFixtures.serviceUnavailableHeaders
        )
        let data = ErrorFixtures.data(ErrorFixtures.serviceUnavailable)
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            XCTAssertTrue(error is ServerError)
        }
    }

    // MARK: - raiseForStatus: unknown 4xx falls back to EnsoulAPIError

    func test_raiseForStatus_418_throwsBaseEnsoulAPIError() throws {
        let response = makeHTTPResponse(statusCode: 418)
        let data = ErrorFixtures.data(["error": "I'm a teapot", "message": "Brew coffee instead"])
        XCTAssertThrowsError(try raiseForStatus(data: data, response: response)) { error in
            // Should be EnsoulAPIError (base), NOT a known subclass
            XCTAssertTrue(error is EnsoulAPIError)
            XCTAssertFalse(error is AuthenticationError)
            XCTAssertFalse(error is NotFoundError)
        }
    }

    // MARK: - raiseForStatus: invalid JSON body falls back gracefully

    func test_raiseForStatus_401_invalidJSONBody_stillThrowsAuthenticationError() throws {
        let response = makeHTTPResponse(statusCode: 401)
        let badData = Data("this is not json".utf8)
        XCTAssertThrowsError(try raiseForStatus(data: badData, response: response)) { error in
            XCTAssertTrue(error is AuthenticationError)
            // Falls back to the HTTP status description, not a crash
        }
    }

    func test_raiseForStatus_500_emptyBody_stillThrowsServerError() throws {
        let response = makeHTTPResponse(statusCode: 500)
        XCTAssertThrowsError(try raiseForStatus(data: Data(), response: response)) { error in
            XCTAssertTrue(error is ServerError)
        }
    }

    // MARK: - Private helpers

    private func makeHTTPResponse(
        statusCode: Int,
        headers: [String: String] = [:]
    ) -> HTTPURLResponse {
        let url = URL(string: "https://api.ensoul-ai.com/v1/test")!
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }
}
