/// Info resource for the Ensoul Swift SDK.
///
/// As of API 0.2.0 the four `/v1/info/*` routes were replaced by a single
/// `GET /v1/api/info` returning an `APIInfoResponse` blob. The convenience
/// methods below each fetch that blob and return their relevant sub-section, so
/// existing call sites keep working without four separate round-trips becoming
/// four copies of the same payload. See
/// `sdks/openapi/namespace-migration-contract.md`.
///
/// Example:
/// ```swift
/// let info     = try await client.info.get()
/// let limits   = try await client.info.rateLimits()
/// let tiers    = try await client.info.tiers()
/// let features = try await client.info.features()
/// ```
import Foundation

// MARK: - Info

@available(iOS 15.0, macOS 12.0, *)
public class Info {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    /// GET /v1/api/info — full server info (`APIInfoResponse`).
    public func get() async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/api/info")
        return try Self.jsonObject(from: data)
    }

    /// Full server configuration blob (alias for ``get()``).
    public func config() async throws -> [String: Any] {
        return try await get()
    }

    /// Rate-limiting configuration sub-section.
    public func rateLimits() async throws -> [String: Any] {
        return (try await get())["rate_limiting"] as? [String: Any] ?? [:]
    }

    /// Access-tier definitions sub-section.
    public func tiers() async throws -> [Any] {
        return (try await get())["access_tiers"] as? [Any] ?? []
    }

    /// Feature-flags sub-section.
    public func features() async throws -> [String: Any] {
        return (try await get())["features"] as? [String: Any] ?? [:]
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
