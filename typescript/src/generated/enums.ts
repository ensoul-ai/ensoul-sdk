/**
 * Generated enums from OpenAPI spec.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

/** Supported field types for personality schema fields. */
export enum FieldType {
  FLOAT = "float",
  INT = "int",
  STR = "str",
  ENUM = "enum",
  BOOL = "bool",
}

/** Supported filter types for persona queries. */
export enum FilterableFieldType {
  RANGE = "range",
  SELECT = "select",
  MULTISELECT = "multiselect",
}

/** How name generation handles gender. */
export enum GenderHandling {
  NEUTRAL = "neutral",
  SEPARATE = "separate",
  NONE = "none",
}

/** Types of cross-level influence. */
export enum InfluenceType {
  GOVERNANCE = "governance",
  MEDIA = "media",
  INSTITUTION = "institution",
  INFLUENCE = "influence",
  ECONOMIC = "economic",
}

/** Export format options. */
export enum PersonaExportFormat {
  JSON = "json",
  YAML = "yaml",
}

/** Session state enumeration. */
export enum SessionStatus {
  INITIALIZING = "initializing",
  READY = "ready",
  RUNNING = "running",
  WAITING_CHILDREN = "waiting_children",
  COMPLETED = "completed",
  FAILED = "failed",
  CANCELLED = "cancelled",
}

/** Simulation lifecycle status. */
export enum SimulationStatus {
  CREATED = "created",
  RUNNING = "running",
  PAUSED = "paused",
  COMPLETED = "completed",
  FAILED = "failed",
}

/** Status of a validation job. */
export enum ValidationStatus {
  PENDING = "pending",
  RUNNING = "running",
  COMPLETED = "completed",
  FAILED = "failed",
  CANCELLED = "cancelled",
}

/** How to aggregate responses. */
export enum AggregateAggregationMode {
  SUMMARY = "summary",
  VOTE = "vote",
  DISTRIBUTION = "distribution",
  CONSENSUS = "consensus",
}

/** How to aggregate child responses. */
export enum SessionsAggregationMode {
  NONE = "none",
  SUMMARY = "summary",
  VOTE = "vote",
  DISTRIBUTION = "distribution",
  CONSENSUS = "consensus",
}

