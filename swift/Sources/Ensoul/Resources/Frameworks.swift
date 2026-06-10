/// Frameworks resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/frameworks` endpoints. Frameworks define the measurement
/// instruments (e.g. surveys, psychometric scales) used to sample personas.
///
/// Example:
/// ```swift
/// let page = try await client.frameworks.list()
/// let fw   = try await client.frameworks.get("fw_abc123")
/// let instruments = try await client.frameworks.getInstruments("fw_abc123")
/// ```
import Foundation

// MARK: - Frameworks

@available(iOS 15.0, macOS 12.0, *)
public class Frameworks {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - List

    /// GET /v1/frameworks
    ///
    /// Returns a paginated list of frameworks as raw JSON dictionaries.
    public func list(
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> RawPage {
        let params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        let (data, _) = try await client.get("/v1/frameworks", params: params)
        return try RawPage.from(data: data)
    }

    // MARK: - Get

    /// GET /v1/frameworks/{frameworkId}
    public func get(_ frameworkId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/frameworks/\(frameworkId)")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Create

    /// POST /v1/frameworks
    ///
    /// Creates a new framework. The body shape is project-defined; pass
    /// the full configuration as a `[String: Any]` dictionary.
    public func create(_ body: [String: Any]) async throws -> [String: Any] {
        let (data, _) = try await client.post("/v1/frameworks", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Update

    /// PUT /v1/frameworks/{frameworkId}
    ///
    /// Replaces the framework configuration. Provide the full updated body.
    public func update(_ frameworkId: String, body: [String: Any]) async throws -> [String: Any] {
        let (data, _) = try await client.put("/v1/frameworks/\(frameworkId)", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Delete

    /// DELETE /v1/frameworks/{frameworkId}
    public func delete(_ frameworkId: String) async throws {
        _ = try await client.delete("/v1/frameworks/\(frameworkId)")
    }

    // MARK: - Validations

    /// GET /v1/frameworks/{frameworkId}/validations
    ///
    /// Returns the framework's validation results
    /// (e.g. `{ "valid": true, "errors": [] }`).
    public func validations(_ frameworkId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get(
            "/v1/frameworks/\(frameworkId)/validations"
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Get Instruments

    /// GET /v1/frameworks/{frameworkId}/instruments
    ///
    /// Returns all measurement instruments belonging to this framework as raw
    /// JSON dictionaries (instrument schema is project-specific).
    public func getInstruments(_ frameworkId: String) async throws -> [[String: Any]] {
        let (data, _) = try await client.get("/v1/frameworks/\(frameworkId)/instruments")
        // The server may return a bare array or a wrapped object.
        if let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return array
        }
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let items = dict["items"] as? [[String: Any]] {
            return items
        }
        throw EnsoulAPIError(
            statusCode: 200,
            error: "ParseError",
            message: "Expected a JSON array or paginated object for framework instruments"
        )
    }

    // MARK: - Private helpers

    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected a JSON object in framework response"
            )
        }
        return dict
    }
}
