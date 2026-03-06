/// URLSession-based HTTP transport layer for the Ensoul Swift SDK.
///
/// Handles authentication, retries with exponential back-off, rate-limit
/// throttling, and SSE streaming — all through the standard URLSession API
/// (no external dependencies).
///
/// Auth types (`AuthProvider`, `APIKeyAuth`, `BearerAuth`) are defined in
/// `Auth.swift`. Rate-limit types (`RateLimitTracker`, `RateLimitInfo`) are
/// defined in `RateLimit.swift`.
import Foundation

// MARK: - SDK constants

private let sdkUserAgent = "ensoul-swift/0.1.0"
private let retryableStatusCodes: Set<Int> = [429, 500, 502, 503]

// MARK: - Retry helpers

/// Compute seconds to wait before the next retry.
///
/// Uses `Retry-After` when provided; otherwise falls back to exponential
/// back-off with jitter: `min(0.5 * 2^attempt, 30) + random(0, 1)`.
private func retryWait(attempt: Int, retryAfter: TimeInterval?) -> TimeInterval {
    if let ra = retryAfter, ra > 0 { return ra }
    let base = min(0.5 * pow(2.0, Double(attempt)), 30.0)
    let jitter = Double.random(in: 0..<1)
    return base + jitter
}

// MARK: - HTTPClient

/// URLSession-based HTTP client for the Ensoul API.
///
/// Usage:
/// ```swift
/// let config = ClientConfig(apiKey: "ens_...")
/// let client = HTTPClient(config: config)
///
/// // Simple GET
/// let (data, _) = try await client.get("/personas")
///
/// // Streaming SSE
/// for try await event in client.streamSSE(method: "POST", path: "/chat/stream", json: body) {
///     print(event.event, event.data)
/// }
/// ```
@available(iOS 15.0, macOS 12.0, *)
public class HTTPClient {
    private let config: ClientConfig
    private let auth: AuthProvider
    private let rateLimiter: RateLimitTracker
    private let session: URLSession
    /// Shared `JSONDecoder` (models use explicit CodingKeys for snake_case mapping).
    public let decoder: JSONDecoder

    // MARK: Init

    public init(config: ClientConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
        self.rateLimiter = RateLimitTracker()

        // Build auth strategy from config
        if let apiKey = config.apiKey {
            self.auth = APIKeyAuth(apiKey: apiKey)
        } else if let bearer = config.bearerToken {
            self.auth = BearerAuth(accessToken: bearer)
        } else {
            self.auth = APIKeyAuth(apiKey: "")
        }

        // Explicit CodingKeys on each model handle snake_case → camelCase mapping,
        // so no keyDecodingStrategy is needed (they would conflict).
        self.decoder = JSONDecoder()
    }

    // MARK: Path normalisation

    /// Ensure the path starts with `/v1/`.
    func normalizePath(_ path: String) -> String {
        let prefix = "/\(apiVersion)/"
        // Already versioned
        if path.hasPrefix(prefix) || path.hasPrefix("\(apiVersion)/") {
            return path.hasPrefix("/") ? path : "/\(path)"
        }
        let stripped = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return "/\(apiVersion)/\(stripped)"
    }

    // MARK: URL building

    func buildURL(path: String, params: [String: String]?) throws -> URL {
        var base = config.baseURL
        while base.hasSuffix("/") { base = String(base.dropLast()) }
        let urlString = base + path

        guard var components = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }

        if let params, !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }

    // MARK: Default headers

    private func defaultHeaders(extra: [String: String]? = nil) -> [String: String] {
        var headers: [String: String] = [
            "User-Agent": sdkUserAgent,
            "Accept": "application/json",
        ]
        for (k, v) in config.customHeaders { headers[k] = v }
        for (k, v) in auth.authHeaders()   { headers[k] = v }
        if let extra { for (k, v) in extra { headers[k] = v } }
        return headers
    }

    // MARK: Core request method

    /// Make an authenticated HTTP request with retries and rate-limit handling.
    ///
    /// - Parameters:
    ///   - method:  HTTP method string (e.g. `"GET"`, `"POST"`).
    ///   - path:    API path — will be normalised to include `/v1/`.
    ///   - json:    Optional JSON body (encoded as UTF-8 JSON).
    ///   - params:  Optional URL query parameters.
    ///   - headers: Optional per-request headers merged on top of defaults.
    /// - Returns: Raw response `Data` and the `HTTPURLResponse`.
    public func request(
        method: String,
        path: String,
        json: [String: Any]? = nil,
        params: [String: String]? = nil,
        headers: [String: String]? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        let normalizedPath = normalizePath(path)
        return try await _executeRequest(
            method: method,
            path: normalizedPath,
            json: json,
            params: params,
            headers: headers
        )
    }

    // MARK: Convenience methods

    public func get(
        _ path: String,
        params: [String: String]? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        return try await request(method: "GET", path: path, params: params)
    }

    /// GET that skips `/v1/` prefix normalisation — for `/health` and similar
    /// endpoints that live outside the versioned API root.
    public func getRaw(
        _ path: String,
        params: [String: String]? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        let url = try buildURL(path: path, params: params)
        var req = URLRequest(url: url, timeoutInterval: config.timeout)
        req.httpMethod = "GET"
        for (k, v) in defaultHeaders() { req.setValue(v, forHTTPHeaderField: k) }

        let (data, urlResponse) = try await session.data(for: req)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        try raiseForStatus(data: data, response: httpResponse)
        return (data, httpResponse)
    }

    public func post(
        _ path: String,
        json: [String: Any]? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        return try await request(method: "POST", path: path, json: json)
    }

    public func put(
        _ path: String,
        json: [String: Any]? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        return try await request(method: "PUT", path: path, json: json)
    }

    public func patch(
        _ path: String,
        json: [String: Any]? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        return try await request(method: "PATCH", path: path, json: json)
    }

    public func delete(_ path: String) async throws -> (Data, HTTPURLResponse) {
        return try await request(method: "DELETE", path: path)
    }

    /// POST with `application/x-www-form-urlencoded` body (used for OAuth
    /// token exchange endpoints).
    public func postForm(
        _ path: String,
        formData: [String: String]
    ) async throws -> (Data, HTTPURLResponse) {
        let normalizedPath = normalizePath(path)
        let url = try buildURL(path: normalizedPath, params: nil)

        var req = URLRequest(url: url, timeoutInterval: config.timeout)
        req.httpMethod = "POST"

        // Merge default headers, then override Content-Type
        for (k, v) in defaultHeaders() { req.setValue(v, forHTTPHeaderField: k) }
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Percent-encode each key=value pair and join with &
        let encoded = formData
            .map { k, v -> String in
                let ek = k.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? k
                let ev = v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? v
                return "\(ek)=\(ev)"
            }
            .joined(separator: "&")
        req.httpBody = encoded.data(using: .utf8)

        let (data, urlResponse) = try await session.data(for: req)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        rateLimiter.update(response: httpResponse)
        try raiseForStatus(data: data, response: httpResponse)
        return (data, httpResponse)
    }

    // MARK: SSE streaming

    /// Construct an SSE request and return an `SSEStream` that lazily initiates
    /// the connection when iterated.
    ///
    /// - Parameters:
    ///   - method: HTTP method (typically `"POST"` or `"GET"`).
    ///   - path:   API path — normalised to `/v1/` automatically.
    ///   - json:   Optional JSON request body.
    /// - Returns: An `SSEStream` `AsyncSequence` of `SSEEvent` values.
    public func streamSSE(
        method: String,
        path: String,
        json: [String: Any]? = nil
    ) -> SSEStream {
        let normalizedPath = normalizePath(path)

        // Build the URL (fall back to a placeholder on failure; iteration will
        // surface the error as a thrown value from next()).
        let url: URL
        if let u = try? buildURL(path: normalizedPath, params: nil) {
            url = u
        } else {
            // Force-unwrap safe: this literal always forms a valid URL.
            url = URL(string: "about:blank")!
        }

        var req = URLRequest(url: url, timeoutInterval: config.timeout)
        req.httpMethod = method

        var hdrs = defaultHeaders()
        hdrs["Accept"] = "text/event-stream"
        hdrs["Content-Type"] = "application/json"
        for (k, v) in hdrs { req.setValue(v, forHTTPHeaderField: k) }

        if let json {
            req.httpBody = try? JSONSerialization.data(withJSONObject: json)
        }

        return SSEStream(request: req, session: session)
    }

    // MARK: Private core request implementation

    private func _executeRequest(
        method: String,
        path: String,
        json: [String: Any]?,
        params: [String: String]?,
        headers: [String: String]?
    ) async throws -> (Data, HTTPURLResponse) {
        let url = try buildURL(path: path, params: params)

        var lastError: Error? = nil

        for attempt in 0...(config.maxRetries) {
            // Check rate-limiter before sending
            let result = rateLimiter.shouldWait()
            if result.wait {
                let nanos = UInt64(max(0, result.seconds) * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanos)
            }

            // Build request
            var req = URLRequest(url: url, timeoutInterval: config.timeout)
            req.httpMethod = method

            for (k, v) in defaultHeaders(extra: headers) {
                req.setValue(v, forHTTPHeaderField: k)
            }

            if let json {
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpBody = try JSONSerialization.data(withJSONObject: json)
            }

            do {
                let (data, urlResponse) = try await session.data(for: req)
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                // Update rate-limit state for future requests
                rateLimiter.update(response: httpResponse)

                let status = httpResponse.statusCode

                // Retryable responses — sleep and retry if we have attempts left
                if retryableStatusCodes.contains(status) && attempt < config.maxRetries {
                    var ra: TimeInterval? = nil
                    if status == 429,
                       let raw = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                       let secs = TimeInterval(raw) {
                        ra = secs
                    }
                    let delay = retryWait(attempt: attempt, retryAfter: ra)
                    let nanos = UInt64(delay * 1_000_000_000)
                    try await Task.sleep(nanoseconds: nanos)
                    continue
                }

                // Non-retryable 4xx / 5xx — surface as SDK error
                try raiseForStatus(data: data, response: httpResponse)
                return (data, httpResponse)

            } catch let error as EnsoulAPIError {
                // Application-level errors (auth, validation, etc.) are never retried
                throw error
            } catch let error as URLError {
                lastError = error
                // Timeout or network errors — retry if we can
                if attempt < config.maxRetries {
                    let delay = retryWait(attempt: attempt, retryAfter: nil)
                    let nanos = UInt64(delay * 1_000_000_000)
                    try await Task.sleep(nanoseconds: nanos)
                    continue
                }
                throw error
            }
        }

        if let lastError { throw lastError }
        throw URLError(.unknown)
    }
}
