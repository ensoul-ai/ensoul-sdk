/// Domains resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/domains` endpoints. Domain schemas are fully dynamic (defined
/// by each project), so responses are returned as raw `[String: Any]` dictionaries
/// rather than strongly-typed Codable structs.
///
/// Example:
/// ```swift
/// let domain = try await client.domains.create(["name": "acme", "type": "enterprise"])
/// let page   = try await client.domains.list()
/// print(page.items.first?["id"] ?? "—")
/// ```
import Foundation

// MARK: - Domains

@available(iOS 15.0, macOS 12.0, *)
public class Domains {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - List

    /// GET /v1/domains
    ///
    /// Returns a paginated list of domains as raw JSON dictionaries.
    /// The schema of each domain dict is project-defined and not validated here.
    public func list(
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> RawPage {
        let params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        let (data, _) = try await client.get("/v1/domains", params: params)
        return try RawPage.from(data: data)
    }

    // MARK: - Get

    /// GET /v1/domains/{domainId}
    public func get(_ domainId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/domains/\(domainId)")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Create

    /// POST /v1/domains
    ///
    /// Creates a new domain. Provide the full domain configuration as a
    /// `[String: Any]` body — the shape is determined by the project's domain spec.
    public func create(_ body: [String: Any]) async throws -> [String: Any] {
        let (data, _) = try await client.post("/v1/domains", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Update

    /// PUT /v1/domains/{domainId}
    ///
    /// Replaces the domain configuration. Provide the fields to update.
    public func update(_ domainId: String, body: [String: Any]) async throws -> [String: Any] {
        let (data, _) = try await client.put("/v1/domains/\(domainId)", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Delete

    /// DELETE /v1/domains/{domainId}
    public func delete(_ domainId: String) async throws {
        _ = try await client.delete("/v1/domains/\(domainId)")
    }

    // MARK: - Validate

    /// POST /v1/domains/validate
    ///
    /// Validates a domain configuration (`DomainConfigCreate`) and returns a
    /// validation result dict (e.g. `{ "valid": true, "errors": [] }`).
    public func validate(_ config: [String: Any]) async throws -> [String: Any] {
        let (data, _) = try await client.post(
            "/v1/domains/validate",
            body: config
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Private helpers

    /// Decode response `Data` as a top-level JSON object.
    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected a JSON object in domain response"
            )
        }
        return dict
    }
}
