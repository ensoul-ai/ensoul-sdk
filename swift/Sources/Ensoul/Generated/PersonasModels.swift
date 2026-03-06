/// Generated models for the personas resource group.
/// DO NOT EDIT — regenerate with: make sdk-regen
import Foundation

// MARK: - Create / Update requests

/// Request to create a single persona.
///
/// Domain-agnostic: `domain` and `personalityData` are always required.
public struct PersonaCreate: Codable, Sendable {
    /// Persona display name.
    public let name: String
    /// Domain identifier (required — use `/domains` to list available values).
    public let domain: String
    /// Domain-specific personality data dictionary.
    public let personalityData: [String: AnyCodable]?
    /// Archetype template ID.
    public let archetype: String?
    /// Geographic region.
    public let region: String?
    /// Age in years.
    public let age: Int?
    /// Country.
    public let country: String?
    /// City.
    public let city: String?
    /// Background story.
    public let backstory: String?
    /// List of core values.
    public let coreValues: [String]?
    /// Communication style parameters.
    public let communicationStyle: [String: AnyCodable]?

    public init(
        name: String,
        domain: String,
        personalityData: [String: AnyCodable]? = nil,
        archetype: String? = nil,
        region: String? = nil,
        age: Int? = nil,
        country: String? = nil,
        city: String? = nil,
        backstory: String? = nil,
        coreValues: [String]? = nil,
        communicationStyle: [String: AnyCodable]? = nil
    ) {
        self.name = name
        self.domain = domain
        self.personalityData = personalityData
        self.archetype = archetype
        self.region = region
        self.age = age
        self.country = country
        self.city = city
        self.backstory = backstory
        self.coreValues = coreValues
        self.communicationStyle = communicationStyle
    }

    enum CodingKeys: String, CodingKey {
        case name
        case domain
        case personalityData = "personality_data"
        case archetype
        case region
        case age
        case country
        case city
        case backstory
        case coreValues = "core_values"
        case communicationStyle = "communication_style"
    }
}

/// Partial update for an existing persona (all fields optional).
public struct PersonaUpdate: Codable, Sendable {
    public let name: String?
    public let personalityData: [String: AnyCodable]?
    public let age: Int?
    public let country: String?
    public let region: String?
    public let city: String?
    public let backstory: String?
    public let coreValues: [String]?
    public let communicationStyle: [String: AnyCodable]?

    public init(
        name: String? = nil,
        personalityData: [String: AnyCodable]? = nil,
        age: Int? = nil,
        country: String? = nil,
        region: String? = nil,
        city: String? = nil,
        backstory: String? = nil,
        coreValues: [String]? = nil,
        communicationStyle: [String: AnyCodable]? = nil
    ) {
        self.name = name
        self.personalityData = personalityData
        self.age = age
        self.country = country
        self.region = region
        self.city = city
        self.backstory = backstory
        self.coreValues = coreValues
        self.communicationStyle = communicationStyle
    }

    enum CodingKeys: String, CodingKey {
        case name
        case personalityData = "personality_data"
        case age
        case country
        case region
        case city
        case backstory
        case coreValues = "core_values"
        case communicationStyle = "communication_style"
    }
}

/// Request to create multiple personas in a single call.
public struct PersonaBatchCreate: Codable, Sendable {
    public let personas: [PersonaCreate]
    /// Optional batch identifier for grouping.
    public let batchId: String?
    /// Default domain applied to all personas (each persona must still specify its own domain).
    public let domain: String?

    public init(personas: [PersonaCreate], batchId: String? = nil, domain: String? = nil) {
        self.personas = personas
        self.batchId = batchId
        self.domain = domain
    }

    enum CodingKeys: String, CodingKey {
        case personas
        case batchId = "batch_id"
        case domain
    }
}

// MARK: - Response types

/// Full persona resource returned by the API.
public struct PersonaResponse: Codable, Sendable {
    public let id: String
    public let name: String
    public let domain: String
    public let personalityData: [String: AnyCodable]?
    public let avatarUrl: String?
    public let archetype: String?
    public let age: Int?
    public let country: String?
    public let region: String?
    public let city: String?
    public let batchId: String?
    /// ISO-8601 creation timestamp.
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case domain
        case personalityData = "personality_data"
        case avatarUrl = "avatar_url"
        case archetype
        case age
        case country
        case region
        case city
        case batchId = "batch_id"
        case createdAt = "created_at"
    }
}

/// Paginated list of personas.
public struct PersonaListResponse: Codable, Sendable {
    public let total: Int
    public let items: [PersonaResponse]
    public let page: Int
    public let perPage: Int
    public let pages: Int

    enum CodingKeys: String, CodingKey {
        case total
        case items
        case page
        case perPage = "per_page"
        case pages
    }
}

/// Full personality vector for a persona.
public struct PersonalityVectorResponse: Codable, Sendable {
    public let personaId: String
    public let domain: String
    public let personalityData: [String: AnyCodable]?
    public let communicationStyle: [String: AnyCodable]?
    public let coreValues: [String]?

    enum CodingKeys: String, CodingKey {
        case personaId = "persona_id"
        case domain
        case personalityData = "personality_data"
        case communicationStyle = "communication_style"
        case coreValues = "core_values"
    }
}

/// Result of a batch create operation.
public struct PersonaBatchResponse: Codable, Sendable {
    public let created: Int
    public let personaIds: [String]
    public let batchId: String?
    public let domain: String?

    enum CodingKeys: String, CodingKey {
        case created
        case personaIds = "persona_ids"
        case batchId = "batch_id"
        case domain
    }
}

/// A single option in a filter picker.
public struct FilterOption: Codable, Sendable {
    public let id: String
    public let name: String
    public let count: Int
}

/// Available filter options for persona browsing UI.
public struct PersonaFiltersResponse: Codable, Sendable {
    public let domains: [FilterOption]?
    public let regions: [FilterOption]?
    public let archetypes: [FilterOption]?
    public let countries: [FilterOption]?
    public let ageRanges: [FilterOption]?
    public let totalPersonas: Int

    enum CodingKeys: String, CodingKey {
        case domains
        case regions
        case archetypes
        case countries
        case ageRanges = "age_ranges"
        case totalPersonas = "total_personas"
    }
}
