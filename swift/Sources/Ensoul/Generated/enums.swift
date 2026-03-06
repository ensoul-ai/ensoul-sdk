/// Generated enums from OpenAPI spec.
/// DO NOT EDIT — regenerate with: make sdk-regen
import Foundation

// MARK: - Field & schema types

/// Supported field types for personality schema fields.
public enum FieldType: String, Codable, Sendable, CaseIterable {
    case float
    case int
    case str
    case `enum`
    case bool
}

/// Supported filter types for persona queries.
public enum FilterableFieldType: String, Codable, Sendable, CaseIterable {
    case range
    case select
    case multiselect
}

// MARK: - Domain config enums

/// How name generation handles gender.
public enum GenderHandling: String, Codable, Sendable, CaseIterable {
    case neutral
    case separate
    case none
}

/// Types of cross-level influence relationships.
public enum InfluenceType: String, Codable, Sendable, CaseIterable {
    case governance
    case media
    case institution
    case influence
    case economic
}

// MARK: - Export format

/// Persona export format options.
public enum PersonaExportFormat: String, Codable, Sendable, CaseIterable {
    case json
    case yaml
}

// MARK: - Lifecycle statuses

/// Session state enumeration.
public enum SessionStatus: String, Codable, Sendable, CaseIterable {
    case initializing
    case ready
    case running
    case waitingChildren = "waiting_children"
    case completed
    case failed
    case cancelled
}

/// Simulation lifecycle status.
public enum SimulationStatus: String, Codable, Sendable, CaseIterable {
    case created
    case running
    case paused
    case completed
    case failed
}

/// Status of a validation job.
public enum ValidationStatus: String, Codable, Sendable, CaseIterable {
    case pending
    case running
    case completed
    case failed
    case cancelled
}

// MARK: - Aggregation modes

/// How to aggregate responses for top-level aggregate queries.
public enum AggregateAggregationMode: String, Codable, Sendable, CaseIterable {
    case summary
    case vote
    case distribution
    case consensus
}

/// How to aggregate responses from child sessions.
public enum SessionsAggregationMode: String, Codable, Sendable, CaseIterable {
    case none
    case summary
    case vote
    case distribution
    case consensus
}
