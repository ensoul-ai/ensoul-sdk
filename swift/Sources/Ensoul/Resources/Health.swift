/// Health resource for the Ensoul Swift SDK.
///
/// Wraps the `/health` family of endpoints. These live **outside** the
/// versioned `/v1/` API root and are used for infrastructure health probes
/// (load balancer readiness, Kubernetes liveness, etc.).
///
/// `getRaw` is used instead of `get` to skip the `/v1/` path-normalisation
/// step that the HTTPClient applies by default.
///
/// Example:
/// ```swift
/// let status = try await client.health.check()
/// print(status["status"] ?? "unknown")
///
/// let ready = try await client.health.ready()
/// print(ready["ready"] ?? false)
/// ```
import Foundation

// MARK: - Health

@available(iOS 15.0, macOS 12.0, *)
public class Health {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Check

    /// GET /health
    ///
    /// General health check. Returns the service status and any component
    /// health information as a raw JSON dictionary.
    public func check() async throws -> [String: Any] {
        let (data, _) = try await client.getRaw("/health")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Ready

    /// GET /health/ready
    ///
    /// Readiness probe — returns `200` when the service is ready to accept
    /// traffic (all dependencies are up). Returns a non-2xx status (and throws)
    /// when the service is not yet ready.
    public func ready() async throws -> [String: Any] {
        let (data, _) = try await client.getRaw("/health/ready")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Live

    /// GET /health/live
    ///
    /// Liveness probe — returns `200` when the process is alive. Use this as
    /// the Kubernetes liveness check; a non-2xx response indicates the pod
    /// should be restarted.
    public func live() async throws -> [String: Any] {
        let (data, _) = try await client.getRaw("/health/live")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Private helpers

    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected a JSON object in health response"
            )
        }
        return dict
    }
}
