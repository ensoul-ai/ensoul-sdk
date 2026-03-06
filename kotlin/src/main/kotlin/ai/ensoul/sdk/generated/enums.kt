/**
 * Generated enums from OpenAPI spec.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */
package ai.ensoul.sdk.generated

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/** Supported field types for personality schema fields. */
@Serializable
enum class FieldType {
    @SerialName("float") FLOAT,
    @SerialName("int") INT,
    @SerialName("str") STR,
    @SerialName("enum") ENUM,
    @SerialName("bool") BOOL,
}

/** Supported filter types for persona queries. */
@Serializable
enum class FilterableFieldType {
    @SerialName("range") RANGE,
    @SerialName("select") SELECT,
    @SerialName("multiselect") MULTISELECT,
}

/** How name generation handles gender. */
@Serializable
enum class GenderHandling {
    @SerialName("neutral") NEUTRAL,
    @SerialName("separate") SEPARATE,
    @SerialName("none") NONE,
}

/** Types of cross-level influence. */
@Serializable
enum class InfluenceType {
    @SerialName("governance") GOVERNANCE,
    @SerialName("media") MEDIA,
    @SerialName("institution") INSTITUTION,
    @SerialName("influence") INFLUENCE,
    @SerialName("economic") ECONOMIC,
}

/** Export format options. */
@Serializable
enum class PersonaExportFormat {
    @SerialName("json") JSON,
    @SerialName("yaml") YAML,
}

/** Session state enumeration. */
@Serializable
enum class SessionStatus {
    @SerialName("initializing") INITIALIZING,
    @SerialName("ready") READY,
    @SerialName("running") RUNNING,
    @SerialName("waiting_children") WAITING_CHILDREN,
    @SerialName("completed") COMPLETED,
    @SerialName("failed") FAILED,
    @SerialName("cancelled") CANCELLED,
}

/** Simulation lifecycle status. */
@Serializable
enum class SimulationStatus {
    @SerialName("created") CREATED,
    @SerialName("running") RUNNING,
    @SerialName("paused") PAUSED,
    @SerialName("completed") COMPLETED,
    @SerialName("failed") FAILED,
}

/** Status of a validation job. */
@Serializable
enum class ValidationStatus {
    @SerialName("pending") PENDING,
    @SerialName("running") RUNNING,
    @SerialName("completed") COMPLETED,
    @SerialName("failed") FAILED,
    @SerialName("cancelled") CANCELLED,
}

/** How to aggregate responses. */
@Serializable
enum class AggregateAggregationMode {
    @SerialName("summary") SUMMARY,
    @SerialName("vote") VOTE,
    @SerialName("distribution") DISTRIBUTION,
    @SerialName("consensus") CONSENSUS,
}

/** How to aggregate child responses. */
@Serializable
enum class SessionsAggregationMode {
    @SerialName("none") NONE,
    @SerialName("summary") SUMMARY,
    @SerialName("vote") VOTE,
    @SerialName("distribution") DISTRIBUTION,
    @SerialName("consensus") CONSENSUS,
}
