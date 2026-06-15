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

    /// POST /v1/domains — create a domain from a strongly-typed
    /// ``DomainConfigCreate``.
    ///
    /// This is step 1 of the dev workflow. To build the config with the AI wizard
    /// instead of by hand, call ``generate(description:context:targetSections:)``
    /// first and pass its ``GeneratedConfigResponse/config`` here.
    public func create(config: DomainConfigCreate) async throws -> [String: Any] {
        let (data, _) = try await client.post("/v1/domains", body: try Self.jsonBody(from: config))
        return try Self.jsonObject(from: data)
    }

    // MARK: - Generate (AI wizard)

    /// POST /v1/domains/generate
    ///
    /// Generate a domain configuration from a natural-language `description`
    /// using the Claude AI wizard (requires the PRO tier).
    ///
    /// The returned ``GeneratedConfigResponse/config`` is a ready-to-use
    /// ``DomainConfigCreate`` that can be passed straight to
    /// ``create(config:)``.
    ///
    /// - Parameters:
    ///   - description: Natural-language description of the domain (10-5000 chars).
    ///   - context: Additional context for the generator (example personas,
    ///     inspiration, etc.). Defaults to empty.
    ///   - targetSections: Which sections to generate. Defaults to `["all"]`.
    public func generate(
        description: String,
        context: [String: Any] = [:],
        targetSections: [String] = ["all"]
    ) async throws -> GeneratedConfigResponse {
        var body: [String: Any] = [
            "description": description,
            "target_sections": targetSections,
        ]
        if !context.isEmpty { body["context"] = context }

        let (data, _) = try await client.post("/v1/domains/generate", body: body)
        return try JSONDecoder().decode(GeneratedConfigResponse.self, from: data)
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

    /// Encode a `Codable` request model into a `[String: Any]` body for the
    /// transport layer. The model's `CodingKeys` produce the API's snake_case
    /// keys, and nil optionals are omitted (synthesized `encodeIfPresent`).
    private static func jsonBody<T: Encodable>(from value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 0,
                error: "EncodeError",
                message: "Expected a JSON object when encoding domain request body"
            )
        }
        return dict
    }

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
