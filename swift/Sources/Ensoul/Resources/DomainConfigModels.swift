/// Typed request/response models for the domains AI-wizard + create workflow.
///
/// These hand-written `Codable` structs mirror the `DomainConfigCreate` and
/// `GeneratedConfigResponse` Pydantic models (the API source of truth in
/// `src/api/models/domains.py`). They are kept here rather than in `Generated/`
/// because the OpenAPI codegen does not yet emit the full domain-config request
/// shape — matching the approach taken in the Python and TypeScript SDKs.
///
/// Naming follows the SDK convention: Swift `camelCase` properties map to the
/// API's `snake_case` JSON via explicit `CodingKeys`. Genuinely polymorphic leaf
/// values (a field's `default`, archetype `metadata`) use `AnyCodable`, the
/// SDK's typed JSON wrapper, since their type is project-defined.
import Foundation

// MARK: - Tier hierarchy

/// One tier in the domain hierarchy (level 0 is the root).
public struct TierDefinition: Codable, Sendable {
    public let level: Int
    public let name: String
    public let description: String?

    public init(level: Int, name: String, description: String? = nil) {
        self.level = level
        self.name = name
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case level
        case name
        case description
    }
}

// MARK: - Personality schema

/// A single personality-schema field definition.
public struct FieldDefinition: Codable, Sendable {
    public let path: String
    public let fieldType: FieldType
    public let rangeMin: Double?
    public let rangeMax: Double?
    /// Default value for the field — type is project-defined.
    public let `default`: AnyCodable?
    public let required: Bool?
    public let heritability: Double?
    public let description: String?
    public let enumValues: [String]?

    public init(
        path: String,
        fieldType: FieldType,
        rangeMin: Double? = nil,
        rangeMax: Double? = nil,
        default: AnyCodable? = nil,
        required: Bool? = nil,
        heritability: Double? = nil,
        description: String? = nil,
        enumValues: [String]? = nil
    ) {
        self.path = path
        self.fieldType = fieldType
        self.rangeMin = rangeMin
        self.rangeMax = rangeMax
        self.default = `default`
        self.required = required
        self.heritability = heritability
        self.description = description
        self.enumValues = enumValues
    }

    enum CodingKeys: String, CodingKey {
        case path
        case fieldType = "field_type"
        case rangeMin = "range_min"
        case rangeMax = "range_max"
        case `default`
        case required
        case heritability
        case description
        case enumValues = "enum_values"
    }
}

/// Correlation between two personality traits.
public struct TraitCorrelation: Codable, Sendable {
    public let traitA: String
    public let traitB: String
    public let correlation: Double
    public let description: String?

    public init(traitA: String, traitB: String, correlation: Double, description: String? = nil) {
        self.traitA = traitA
        self.traitB = traitB
        self.correlation = correlation
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case traitA = "trait_a"
        case traitB = "trait_b"
        case correlation
        case description
    }
}

/// Complete personality-schema configuration.
public struct PersonalitySchema: Codable, Sendable {
    public let fields: [FieldDefinition]
    public let version: String?
    public let traitCorrelations: [TraitCorrelation]?

    public init(
        fields: [FieldDefinition],
        version: String? = nil,
        traitCorrelations: [TraitCorrelation]? = nil
    ) {
        self.fields = fields
        self.version = version
        self.traitCorrelations = traitCorrelations
    }

    enum CodingKeys: String, CodingKey {
        case fields
        case version
        case traitCorrelations = "trait_correlations"
    }
}

// MARK: - Archetypes

/// An archetype in the hierarchy.
public struct Archetype: Codable, Sendable {
    public let id: String
    public let name: String
    public let tier: Int
    public let parentId: String?
    /// Per-trait personality deltas (range [-50, 50]).
    public let personalityModifiers: [String: Double]?
    public let description: String?
    /// Free-form archetype metadata — type is project-defined.
    public let metadata: [String: AnyCodable]?
    public let probability: Double?

    public init(
        id: String,
        name: String,
        tier: Int,
        parentId: String? = nil,
        personalityModifiers: [String: Double]? = nil,
        description: String? = nil,
        metadata: [String: AnyCodable]? = nil,
        probability: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.tier = tier
        self.parentId = parentId
        self.personalityModifiers = personalityModifiers
        self.description = description
        self.metadata = metadata
        self.probability = probability
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tier
        case parentId = "parent_id"
        case personalityModifiers = "personality_modifiers"
        case description
        case metadata
        case probability
    }
}

// MARK: - Name patterns

/// Name-generation pattern for a tier value.
public struct NamePattern: Codable, Sendable {
    public let tierId: String
    public let tierValue: String
    public let firstNames: [String]?
    public let lastNames: [String]?
    public let patterns: [String]?
    public let genderHandling: GenderHandling?
    public let prefixes: [String]?
    public let suffixes: [String]?

    public init(
        tierId: String,
        tierValue: String,
        firstNames: [String]? = nil,
        lastNames: [String]? = nil,
        patterns: [String]? = nil,
        genderHandling: GenderHandling? = nil,
        prefixes: [String]? = nil,
        suffixes: [String]? = nil
    ) {
        self.tierId = tierId
        self.tierValue = tierValue
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.patterns = patterns
        self.genderHandling = genderHandling
        self.prefixes = prefixes
        self.suffixes = suffixes
    }

    enum CodingKeys: String, CodingKey {
        case tierId = "tier_id"
        case tierValue = "tier_value"
        case firstNames = "first_names"
        case lastNames = "last_names"
        case patterns
        case genderHandling = "gender_handling"
        case prefixes
        case suffixes
    }
}

// MARK: - Memory templates

/// Whether a memory template applies to every persona or only in a context.
public enum MemoryTemplateType: String, Codable, Sendable, CaseIterable {
    case universal
    case contextual
}

/// Memory-template definition for backstory generation.
public struct MemoryTemplate: Codable, Sendable {
    public let templateId: String
    public let templateType: MemoryTemplateType
    public let templateString: String
    public let contextType: String?
    public let contextId: String?
    public let probability: Double?
    public let importance: Double?
    public let tags: [String]?

    public init(
        templateId: String,
        templateType: MemoryTemplateType,
        templateString: String,
        contextType: String? = nil,
        contextId: String? = nil,
        probability: Double? = nil,
        importance: Double? = nil,
        tags: [String]? = nil
    ) {
        self.templateId = templateId
        self.templateType = templateType
        self.templateString = templateString
        self.contextType = contextType
        self.contextId = contextId
        self.probability = probability
        self.importance = importance
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case templateId = "template_id"
        case templateType = "template_type"
        case templateString = "template_string"
        case contextType = "context_type"
        case contextId = "context_id"
        case probability
        case importance
        case tags
    }
}

// MARK: - Filterable fields

/// One option for a select/multiselect filterable field.
public struct FilterableFieldOption: Codable, Sendable {
    public let value: String
    public let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }

    enum CodingKeys: String, CodingKey {
        case value
        case label
    }
}

/// A field exposed for filtering in aggregate queries.
public struct FilterableFieldDefinition: Codable, Sendable {
    public let path: String
    public let type: FilterableFieldType
    public let label: String
    public let description: String?
    public let min: Double?
    public let max: Double?
    public let step: Double?
    public let optionsFrom: String?
    public let options: [FilterableFieldOption]?

    public init(
        path: String,
        type: FilterableFieldType,
        label: String,
        description: String? = nil,
        min: Double? = nil,
        max: Double? = nil,
        step: Double? = nil,
        optionsFrom: String? = nil,
        options: [FilterableFieldOption]? = nil
    ) {
        self.path = path
        self.type = type
        self.label = label
        self.description = description
        self.min = min
        self.max = max
        self.step = step
        self.optionsFrom = optionsFrom
        self.options = options
    }

    enum CodingKeys: String, CodingKey {
        case path
        case type
        case label
        case description
        case min
        case max
        case step
        case optionsFrom = "options_from"
        case options
    }
}

// MARK: - Tier values

/// One weighted option for a tier value.
public struct TierValueOption: Codable, Sendable {
    public let value: String
    public let label: String
    public let probability: Double?

    public init(value: String, label: String, probability: Double? = nil) {
        self.value = value
        self.label = label
        self.probability = probability
    }

    enum CodingKeys: String, CodingKey {
        case value
        case label
        case probability
    }
}

/// Value configuration for hierarchical tier selection.
public struct TierValuesConfig: Codable, Sendable {
    public let tierId: String
    public let options: [TierValueOption]
    public let parentTierId: String?
    public let parentValueMapping: [String: [String]]?

    public init(
        tierId: String,
        options: [TierValueOption],
        parentTierId: String? = nil,
        parentValueMapping: [String: [String]]? = nil
    ) {
        self.tierId = tierId
        self.options = options
        self.parentTierId = parentTierId
        self.parentValueMapping = parentValueMapping
    }

    enum CodingKeys: String, CodingKey {
        case tierId = "tier_id"
        case options
        case parentTierId = "parent_tier_id"
        case parentValueMapping = "parent_value_mapping"
    }
}

// MARK: - Image generation

/// Visual style template for avatar generation.
public struct StyleTemplate: Codable, Sendable {
    public let name: String
    public let stylePrompt: String
    public let description: String?
    public let negativePrompt: String?

    public init(
        name: String,
        stylePrompt: String,
        description: String? = nil,
        negativePrompt: String? = nil
    ) {
        self.name = name
        self.stylePrompt = stylePrompt
        self.description = description
        self.negativePrompt = negativePrompt
    }

    enum CodingKeys: String, CodingKey {
        case name
        case stylePrompt = "style_prompt"
        case description
        case negativePrompt = "negative_prompt"
    }
}

/// Domain-level avatar image-generation settings.
public struct ImageGenerationConfig: Codable, Sendable {
    public let defaultStyle: String?
    public let styles: [StyleTemplate]?
    public let promptPrefix: String?
    public let promptSuffix: String?

    public init(
        defaultStyle: String? = nil,
        styles: [StyleTemplate]? = nil,
        promptPrefix: String? = nil,
        promptSuffix: String? = nil
    ) {
        self.defaultStyle = defaultStyle
        self.styles = styles
        self.promptPrefix = promptPrefix
        self.promptSuffix = promptSuffix
    }

    enum CodingKeys: String, CodingKey {
        case defaultStyle = "default_style"
        case styles
        case promptPrefix = "prompt_prefix"
        case promptSuffix = "prompt_suffix"
    }
}

// MARK: - Domain config (request body for POST /v1/domains)

/// Request body for `POST /v1/domains`, shaped to the `DomainConfigCreate`
/// Pydantic model. Required fields are non-optional; every optional field falls
/// back to the server default when omitted (nil optionals are not serialized).
public struct DomainConfigCreate: Codable, Sendable {
    /// Domain identifier (lowercase, alphanumeric, underscores).
    public let name: String
    /// Human-readable domain name.
    public let displayName: String
    /// Tier definitions; must include a root tier at level 0.
    public let tiers: [TierDefinition]
    public let personalitySchema: PersonalitySchema
    /// Semantic version, e.g. `"1.0.0"`. Defaults server-side to `"1.0.0"`.
    public let version: String?
    public let description: String?
    public let archetypes: [Archetype]?
    public let namePatterns: [NamePattern]?
    public let memoryTemplates: [MemoryTemplate]?
    public let filterableFields: [FilterableFieldDefinition]?
    public let tierValues: [TierValuesConfig]?
    public let imageGeneration: ImageGenerationConfig?
    /// Domain-wide behavioral rules added to every persona's system prompt.
    public let behavioralGuidelines: [String]?
    /// Short directives re-injected into every chat turn (re-anchor capsule).
    public let chatGuardrails: [String]?
    /// Per-domain chat sampling temperature (0.0-2.0).
    public let chatTemperature: Double?
    /// Identity framing: what each persona IS (e.g. `"person"`, `"pet"`, `"character"`).
    public let entityNoun: String?
    public let isDraft: Bool?
    public let tags: [String]?
    public let frameworks: [String]?

    public init(
        name: String,
        displayName: String,
        tiers: [TierDefinition],
        personalitySchema: PersonalitySchema,
        version: String? = nil,
        description: String? = nil,
        archetypes: [Archetype]? = nil,
        namePatterns: [NamePattern]? = nil,
        memoryTemplates: [MemoryTemplate]? = nil,
        filterableFields: [FilterableFieldDefinition]? = nil,
        tierValues: [TierValuesConfig]? = nil,
        imageGeneration: ImageGenerationConfig? = nil,
        behavioralGuidelines: [String]? = nil,
        chatGuardrails: [String]? = nil,
        chatTemperature: Double? = nil,
        entityNoun: String? = nil,
        isDraft: Bool? = nil,
        tags: [String]? = nil,
        frameworks: [String]? = nil
    ) {
        self.name = name
        self.displayName = displayName
        self.tiers = tiers
        self.personalitySchema = personalitySchema
        self.version = version
        self.description = description
        self.archetypes = archetypes
        self.namePatterns = namePatterns
        self.memoryTemplates = memoryTemplates
        self.filterableFields = filterableFields
        self.tierValues = tierValues
        self.imageGeneration = imageGeneration
        self.behavioralGuidelines = behavioralGuidelines
        self.chatGuardrails = chatGuardrails
        self.chatTemperature = chatTemperature
        self.entityNoun = entityNoun
        self.isDraft = isDraft
        self.tags = tags
        self.frameworks = frameworks
    }

    enum CodingKeys: String, CodingKey {
        case name
        case displayName = "display_name"
        case tiers
        case personalitySchema = "personality_schema"
        case version
        case description
        case archetypes
        case namePatterns = "name_patterns"
        case memoryTemplates = "memory_templates"
        case filterableFields = "filterable_fields"
        case tierValues = "tier_values"
        case imageGeneration = "image_generation"
        case behavioralGuidelines = "behavioral_guidelines"
        case chatGuardrails = "chat_guardrails"
        case chatTemperature = "chat_temperature"
        case entityNoun = "entity_noun"
        case isDraft = "is_draft"
        case tags
        case frameworks
    }
}

// MARK: - Generate response (POST /v1/domains/generate)

/// Response from `POST /v1/domains/generate` (the AI domain wizard).
public struct GeneratedConfigResponse: Codable, Sendable {
    /// Generated configuration — ready to pass straight to `Domains.create`.
    public let config: DomainConfigCreate
    /// Explanation of the generated config.
    public let explanation: String
    /// Suggestions for improvement.
    public let suggestions: [String]
    /// Confidence score (0.0-1.0).
    public let confidence: Double

    public init(
        config: DomainConfigCreate,
        explanation: String,
        suggestions: [String],
        confidence: Double
    ) {
        self.config = config
        self.explanation = explanation
        self.suggestions = suggestions
        self.confidence = confidence
    }

    enum CodingKeys: String, CodingKey {
        case config
        case explanation
        case suggestions
        case confidence
    }
}
