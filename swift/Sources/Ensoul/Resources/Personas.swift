/// Personas resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/personas` endpoints. Every method is `async throws` since Swift
/// concurrency is async-only at the SDK boundary.
///
/// Example:
/// ```swift
/// let persona = try await client.personas.create(name: "Alice", domain: "acme")
/// let page    = try await client.personas.list(page: 1, perPage: 20)
/// for item in page.items { print(item.id) }
/// ```
import Foundation

// MARK: - Personas

@available(iOS 15.0, macOS 12.0, *)
public class Personas {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Create

    /// POST /v1/personas
    ///
    /// Creates a new persona in the given domain.
    public func create(
        name: String,
        domain: String,
        personalityData: [String: Any]? = nil,
        archetype: String? = nil,
        region: String? = nil,
        age: Int? = nil,
        country: String? = nil,
        city: String? = nil,
        backstory: String? = nil,
        coreValues: [String]? = nil,
        communicationStyle: [String: Any]? = nil
    ) async throws -> PersonaResponse {
        var body: [String: Any] = [
            "name": name,
            "domain": domain,
        ]
        if let personalityData { body["personality_data"] = personalityData }
        if let archetype { body["archetype"] = archetype }
        if let region { body["region"] = region }
        if let age { body["age"] = age }
        if let country { body["country"] = country }
        if let city { body["city"] = city }
        if let backstory { body["backstory"] = backstory }
        if let coreValues { body["core_values"] = coreValues }
        if let communicationStyle { body["communication_style"] = communicationStyle }

        let (data, _) = try await client.post("/v1/personas", body: body)
        let decoder = JSONDecoder()
        return try decoder.decode(PersonaResponse.self, from: data)
    }

    // MARK: - Get

    /// GET /v1/personas/{personaId}
    public func get(_ personaId: String) async throws -> PersonaResponse {
        let (data, _) = try await client.get("/v1/personas/\(personaId)")
        let decoder = JSONDecoder()
        return try decoder.decode(PersonaResponse.self, from: data)
    }

    // MARK: - Update

    /// PUT /v1/personas/{personaId}
    ///
    /// Updates an existing persona. Only provide the fields you want to change.
    public func update(
        _ personaId: String,
        name: String? = nil,
        personalityData: [String: Any]? = nil,
        archetype: String? = nil,
        region: String? = nil,
        age: Int? = nil,
        country: String? = nil,
        city: String? = nil,
        backstory: String? = nil,
        coreValues: [String]? = nil,
        communicationStyle: [String: Any]? = nil
    ) async throws -> PersonaResponse {
        var body: [String: Any] = [:]
        if let name { body["name"] = name }
        if let personalityData { body["personality_data"] = personalityData }
        if let archetype { body["archetype"] = archetype }
        if let region { body["region"] = region }
        if let age { body["age"] = age }
        if let country { body["country"] = country }
        if let city { body["city"] = city }
        if let backstory { body["backstory"] = backstory }
        if let coreValues { body["core_values"] = coreValues }
        if let communicationStyle { body["communication_style"] = communicationStyle }

        let (data, _) = try await client.put("/v1/personas/\(personaId)", body: body)
        let decoder = JSONDecoder()
        return try decoder.decode(PersonaResponse.self, from: data)
    }

    // MARK: - Delete

    /// DELETE /v1/personas/{personaId}
    public func delete(_ personaId: String) async throws {
        _ = try await client.delete("/v1/personas/\(personaId)")
    }

    // MARK: - List

    /// GET /v1/personas
    ///
    /// Returns a paginated page of personas. Use `page.nextPage()` to advance,
    /// or `for try await item in page.autoPagingSequence()` to iterate all items.
    public func list(
        page: Int = 1,
        perPage: Int = 20,
        domain: String? = nil,
        region: String? = nil,
        archetype: String? = nil,
        country: String? = nil,
        city: String? = nil
    ) async throws -> Page<PersonaResponse> {
        var params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        if let domain { params["domain"] = domain }
        if let region { params["region"] = region }
        if let archetype { params["archetype"] = archetype }
        if let country { params["country"] = country }
        if let city { params["city"] = city }

        let (data, _) = try await client.get("/v1/personas", params: params)
        return try Page.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: params
        )
    }

    // MARK: - Batch Create

    /// POST /v1/personas/batch
    ///
    /// Creates multiple personas in a single request.
    public func batchCreate(
        personas: [[String: Any]],
        batchId: String? = nil,
        domain: String? = nil
    ) async throws -> PersonaBatchResponse {
        var body: [String: Any] = ["personas": personas]
        if let batchId { body["batch_id"] = batchId }
        if let domain { body["domain"] = domain }

        let (data, _) = try await client.post("/v1/personas/batch", body: body)
        let decoder = JSONDecoder()
        return try decoder.decode(PersonaBatchResponse.self, from: data)
    }

    // MARK: - Get Personality

    /// GET /v1/personas/{personaId}/personality
    ///
    /// Returns the raw personality vector for a persona.
    public func getPersonality(_ personaId: String) async throws -> PersonalityVectorResponse {
        let (data, _) = try await client.get("/v1/personas/\(personaId)/personality")
        let decoder = JSONDecoder()
        return try decoder.decode(PersonalityVectorResponse.self, from: data)
    }

    // MARK: - Get Filters

    /// GET /v1/personas/filters
    ///
    /// Returns the set of valid filter values for listing personas.
    public func getFilters() async throws -> PersonaFiltersResponse {
        let (data, _) = try await client.get("/v1/personas/filters")
        let decoder = JSONDecoder()
        return try decoder.decode(PersonaFiltersResponse.self, from: data)
    }

    // MARK: - Get Connections

    /// GET /v1/personas/{personaId}/connections
    ///
    /// Returns the social graph connections for a persona as raw JSON dictionaries.
    /// The connection schema is domain-specific so raw `[String: Any]` is returned.
    public func getConnections(_ personaId: String) async throws -> [[String: Any]] {
        let (data, _) = try await client.get("/v1/personas/\(personaId)/connections")
        guard let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected JSON array for persona connections"
            )
        }
        return array
    }
}
