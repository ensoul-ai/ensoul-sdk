/// URLProtocol-based mock for intercepting HTTP requests in unit tests.
///
/// Usage:
/// ```swift
/// MockURLProtocol.requestHandler = { request in
///     let response = HTTPURLResponse(url: request.url!, statusCode: 200, ...)!
///     return (response, Data(jsonString.utf8))
/// }
/// let session = MockURLProtocol.makeSession()
/// let client  = EnsoulClient(apiKey: "test", session: session)
/// ```
import Foundation
import XCTest

// MARK: - MockURLProtocol

/// Intercepts all URL requests made through a custom URLSession so tests can
/// respond without a real network.
final class MockURLProtocol: URLProtocol {

    /// Set this before each test to control what the mock returns.
    ///
    /// The closure receives the outgoing `URLRequest` and must return an
    /// `(HTTPURLResponse, Data)` tuple, or throw an error.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    // MARK: URLProtocol overrides

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError(
                "MockURLProtocol.requestHandler is not set. "
                + "Assign it before each test that uses MockURLProtocol."
            )
        }

        // URLProtocol strips httpBody when using async URLSession.data(for:).
        // Reconstruct it from httpBodyStream so tests can inspect the body.
        var incoming = request
        if incoming.httpBody == nil, let stream = incoming.httpBodyStream {
            stream.open()
            var data = Data()
            let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
            defer { buf.deallocate() }
            while stream.hasBytesAvailable {
                let read = stream.read(buf, maxLength: 4096)
                if read > 0 { data.append(buf, count: read) }
                else { break }
            }
            stream.close()
            incoming.httpBody = data
        }

        do {
            let (response, data) = try handler(incoming)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Nothing to cancel for synchronous mock responses.
    }
}

// MARK: - Factory

extension MockURLProtocol {
    /// Build a `URLSession` that routes all requests through `MockURLProtocol`.
    ///
    /// Pass the returned session to `EnsoulClient(apiKey:session:)` so that
    /// every HTTP call the client makes is intercepted by the mock.
    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}

// MARK: - Response builder helpers

extension MockURLProtocol {
    /// Build an `HTTPURLResponse` with the given status code and optional headers.
    static func makeResponse(
        for url: URL,
        statusCode: Int,
        headers: [String: String] = [:]
    ) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }

    /// Encode a `Codable` value to JSON `Data` using snake_case keys.
    static func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(value)
    }

    /// Build a JSON body `Data` from a `[String: Any]` dictionary.
    static func jsonData(_ dict: [String: Any]) -> Data {
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }
}
