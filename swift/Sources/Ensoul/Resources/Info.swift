/// Info resource for the Ensoul Swift SDK.
///
/// Wraps the `/v1/info` family of endpoints that expose API configuration,
/// rate-limit details, access-tier definitions, and feature flags.
///
/// These endpoints are read-only and do not require write permissions beyond
/// standard authentication.
///
/// Example:
/// ```swift
/// let config     = try await client.info.config()
/// let limits     = try await client.info.rateLimits()
/// let tiers      = try await client.info.tiers()
/// let features   = try await client.info.features()
/// ```
import Foundation

// MARK: - Info

@available(iOS 15.0, macOS 12.0, *)
public class Info {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Config

    /// GET /v1/info/config
    ///
    /// Returns the current API configuration as a raw JSON dictionary.
    /// Useful for inspecting server-side defaults and capabilities.
    public func config() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/info/config")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Rate Limits

    /// GET /v1/info/rate-limits
    ///
    /// Returns the rate-limit details for the current access tier, including
    /// per-endpoint limits and reset windows.
    public func rateLimits() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/info/rate-limits")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Tiers

    /// GET /v1/info/tiers
    ///
    /// Returns definitions for all available access tiers (FREE, STARTER, PRO,
    /// ENTERPRISE), including their feature entitlements and rate limits.
    public func tiers() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/info/tiers")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Features

    /// GET /v1/info/features
    ///
    /// Returns the feature flag state for the current authenticated account.
    /// Use this to check which optional capabilities are enabled before calling
    /// the corresponding endpoints.
    public func features() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/info/features")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Private helpers

    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected a JSON object in info response"
            )
        }
        return dict
    }
}
