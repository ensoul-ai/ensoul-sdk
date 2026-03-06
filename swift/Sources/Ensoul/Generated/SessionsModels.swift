/// Generated models for the sessions resource group.
/// DO NOT EDIT — regenerate with: make sdk-regen
///
/// Sessions use `[String: AnyCodable]` for trait_modifiers, metadata, and
/// aggregated_content because their shapes are domain-dependent.
import Foundation

// MARK: - Create request

/// Request to create a new hierarchical session.
public struct SessionCreate: Codable, Sendable {
    /// Session tier level (0–4).
    public let tier: Int
    /// Parent session ID for hierarchical sessions.
    public let parentSessionId: String?
    /// Custom system instructions for this session context.
    public let systemInstructions: String?
    /// OCEAN trait modifiers from baseline.
    public let traitModifiers: [String: AnyCodable]?
    /// Core values for the session context.
    public let coreValues: [String]?
    /// Communication style parameters.
    public let communicationStyle: [String: AnyCodable]?
    /// Additional metadata.
    public let metadata: [String: AnyCodable]?

    public init(
        tier: Int,
        parentSessionId: String? = nil,
        systemInstructions: String? = nil,
        traitModifiers: [String: AnyCodable]? = nil,
        coreValues: [String]? = nil,
        communicationStyle: [String: AnyCodable]? = nil,
        metadata: [String: AnyCodable]? = nil
    ) {
        self.tier = tier
        self.parentSessionId = parentSessionId
        self.systemInstructions = systemInstructions
        self.traitModifiers = traitModifiers
        self.coreValues = coreValues
        self.communicationStyle = communicationStyle
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case tier
        case parentSessionId = "parent_session_id"
        case systemInstructions = "system_instructions"
        case traitModifiers = "trait_modifiers"
        case coreValues = "core_values"
        case communicationStyle = "communication_style"
        case metadata
    }
}

// MARK: - Aggregate children

/// Request to aggregate responses from child sessions.
public struct AggregateChildrenRequest: Codable, Sendable {
    public let aggregationMode: SessionsAggregationMode?
    public let filters: [String: AnyCodable]?
    public let timeoutMs: Int?

    public init(
        aggregationMode: SessionsAggregationMode? = nil,
        filters: [String: AnyCodable]? = nil,
        timeoutMs: Int? = nil
    ) {
        self.aggregationMode = aggregationMode
        self.filters = filters
        self.timeoutMs = timeoutMs
    }

    enum CodingKeys: String, CodingKey {
        case aggregationMode = "aggregation_mode"
        case filters
        case timeoutMs = "timeout_ms"
    }
}

/// Response from aggregating child sessions.
public struct AggregateChildrenResponse: Codable, Sendable {
    public let sessionId: String
    public let aggregationMode: SessionsAggregationMode
    public let childCount: Int
    public let isComplete: Bool
    public let isPartial: Bool
    public let aggregatedContent: [String: AnyCodable]?
    public let childResponses: [[String: AnyCodable]]?
    public let totalTokens: Int
    public let totalTimeMs: Int
    public let missingCount: Int
    /// ISO-8601 aggregation timestamp.
    public let timestamp: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case aggregationMode = "aggregation_mode"
        case childCount = "child_count"
        case isComplete = "is_complete"
        case isPartial = "is_partial"
        case aggregatedContent = "aggregated_content"
        case childResponses = "child_responses"
        case totalTokens = "total_tokens"
        case totalTimeMs = "total_time_ms"
        case missingCount = "missing_count"
        case timestamp
    }
}
