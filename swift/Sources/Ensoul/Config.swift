/// Client configuration for the Ensoul Swift SDK.
import Foundation

// MARK: - Constants

public let defaultBaseURL = "https://api.ensoul-ai.com"
// Inference endpoints (domain generation, chat) run real-time LLM calls that
// routinely take 30-120s+; 30s timed out the documented domains.generate "easy path".
public let defaultTimeout: TimeInterval = 300
public let defaultMaxRetries: Int = 2
public let apiVersion = "v1"

// MARK: - ClientConfig

/// Immutable-by-default configuration for an Ensoul API client.
///
/// All properties have sensible defaults; only supply what you need:
/// ```swift
/// let config = ClientConfig(apiKey: "ens_...")
/// let config = ClientConfig(bearerToken: jwt, baseURL: "https://staging.ensoul-ai.com")
/// ```
public struct ClientConfig {
    /// Base URL for the Ensoul API (no trailing slash).
    public var baseURL: String

    /// API key credential (sets `X-API-Key` header).
    public var apiKey: String?

    /// Bearer / JWT credential (sets `Authorization: Bearer` header).
    public var bearerToken: String?

    /// Per-request timeout in seconds.
    public var timeout: TimeInterval

    /// Maximum number of automatic retries on transient errors.
    public var maxRetries: Int

    /// Additional headers merged into every request.
    public var customHeaders: [String: String]

    // MARK: Derived

    /// Fully-qualified versioned API root, e.g. `https://api.ensoul-ai.com/v1`.
    public var apiURL: String {
        var base = baseURL
        while base.hasSuffix("/") { base = String(base.dropLast()) }
        return "\(base)/\(apiVersion)"
    }

    // MARK: Init

    public init(
        baseURL: String = defaultBaseURL,
        apiKey: String? = nil,
        bearerToken: String? = nil,
        timeout: TimeInterval = defaultTimeout,
        maxRetries: Int = defaultMaxRetries,
        customHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.bearerToken = bearerToken
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.customHeaders = customHeaders
    }
}
