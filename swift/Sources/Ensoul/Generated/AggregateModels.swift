/// Generated models for the aggregate resource group.
/// DO NOT EDIT — regenerate with: make sdk-regen
///
/// Aggregate payloads (filters, target_cohort, parameters) are
/// domain-dependent and therefore represented as `[String: AnyCodable]`.
import Foundation

// MARK: - Simulation scenario

/// Request to run a scenario simulation across a persona cohort.
public struct SimulationRequest: Codable, Sendable {
    public let scenario: String
    /// Target cohort filters (region, archetype, demographics).
    public let targetCohort: [String: AnyCodable]?
    public let durationDays: Int
    public let parameters: [String: AnyCodable]?

    public init(
        scenario: String,
        targetCohort: [String: AnyCodable]? = nil,
        durationDays: Int = 30,
        parameters: [String: AnyCodable]? = nil
    ) {
        self.scenario = scenario
        self.targetCohort = targetCohort
        self.durationDays = durationDays
        self.parameters = parameters
    }

    enum CodingKeys: String, CodingKey {
        case scenario
        case targetCohort = "target_cohort"
        case durationDays = "duration_days"
        case parameters
    }
}

// MARK: - Streaming aggregate query

/// Request for a streaming aggregate query with progressive results.
///
/// Sprint 21: Streaming Aggregation (5s time-to-first-result)
/// Sprint 42: Added aggregation_mode for synthesis support
public struct StreamingQueryRequest: Codable, Sendable {
    public let query: String
    /// Persona selection filters (region, archetype, demographics).
    public let filters: [String: AnyCodable]?
    public let aggregationMode: AggregateAggregationMode?
    /// Target confidence level for early termination (0.80–0.99).
    public let targetConfidence: Double
    /// Minimum samples before allowing early termination.
    public let minSamples: Int
    public let maxSamples: Int?
    /// Maximum confidence interval width for early termination.
    public let ciWidthThreshold: Double
    /// Epsilon for differential privacy.
    public let privacyBudget: Double

    public init(
        query: String,
        filters: [String: AnyCodable]? = nil,
        aggregationMode: AggregateAggregationMode? = nil,
        targetConfidence: Double = 0.95,
        minSamples: Int = 100,
        maxSamples: Int? = nil,
        ciWidthThreshold: Double = 0.05,
        privacyBudget: Double = 1.0
    ) {
        self.query = query
        self.filters = filters
        self.aggregationMode = aggregationMode
        self.targetConfidence = targetConfidence
        self.minSamples = minSamples
        self.maxSamples = maxSamples
        self.ciWidthThreshold = ciWidthThreshold
        self.privacyBudget = privacyBudget
    }

    enum CodingKeys: String, CodingKey {
        case query
        case filters
        case aggregationMode = "aggregation_mode"
        case targetConfidence = "target_confidence"
        case minSamples = "min_samples"
        case maxSamples = "max_samples"
        case ciWidthThreshold = "ci_width_threshold"
        case privacyBudget = "privacy_budget"
    }
}

// MARK: - Influence query response

/// Response from influence-tracing through the persona graph.
public struct InfluenceQueryResponse: Codable, Sendable {
    public let personaId: String
    public let influenceType: String?
    public let direction: String
    public let maxDepth: Int
    /// Found influence paths (raw — shape is domain-dependent).
    public let paths: [AnyCodable]?
    public let influencedPersonas: [String]?
    public let totalPaths: Int
    /// Path with the highest total weight.
    public let strongestPath: AnyCodable?
    public let networkMetrics: [String: AnyCodable]?
    /// ISO-8601 query timestamp.
    public let timestamp: String?

    enum CodingKeys: String, CodingKey {
        case personaId = "persona_id"
        case influenceType = "influence_type"
        case direction
        case maxDepth = "max_depth"
        case paths
        case influencedPersonas = "influenced_personas"
        case totalPaths = "total_paths"
        case strongestPath = "strongest_path"
        case networkMetrics = "network_metrics"
        case timestamp
    }
}
