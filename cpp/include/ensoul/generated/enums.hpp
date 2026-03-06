#pragma once

#include <nlohmann/json.hpp>

namespace ensoul {

enum class FieldType {
    FLOAT,
    INT,
    STR,
    ENUM,
    BOOL,
};

NLOHMANN_JSON_SERIALIZE_ENUM(FieldType, {
    {FieldType::FLOAT, "float"},
    {FieldType::INT, "int"},
    {FieldType::STR, "str"},
    {FieldType::ENUM, "enum"},
    {FieldType::BOOL, "bool"},
})

enum class FilterableFieldType {
    RANGE,
    SELECT,
    MULTISELECT,
};

NLOHMANN_JSON_SERIALIZE_ENUM(FilterableFieldType, {
    {FilterableFieldType::RANGE, "range"},
    {FilterableFieldType::SELECT, "select"},
    {FilterableFieldType::MULTISELECT, "multiselect"},
})

enum class GenderHandling {
    NEUTRAL,
    SEPARATE,
    NONE,
};

NLOHMANN_JSON_SERIALIZE_ENUM(GenderHandling, {
    {GenderHandling::NEUTRAL, "neutral"},
    {GenderHandling::SEPARATE, "separate"},
    {GenderHandling::NONE, "none"},
})

enum class InfluenceType {
    GOVERNANCE,
    MEDIA,
    INSTITUTION,
    INFLUENCE,
    ECONOMIC,
};

NLOHMANN_JSON_SERIALIZE_ENUM(InfluenceType, {
    {InfluenceType::GOVERNANCE, "governance"},
    {InfluenceType::MEDIA, "media"},
    {InfluenceType::INSTITUTION, "institution"},
    {InfluenceType::INFLUENCE, "influence"},
    {InfluenceType::ECONOMIC, "economic"},
})

enum class PersonaExportFormat {
    JSON,
    YAML,
};

NLOHMANN_JSON_SERIALIZE_ENUM(PersonaExportFormat, {
    {PersonaExportFormat::JSON, "json"},
    {PersonaExportFormat::YAML, "yaml"},
})

enum class SessionStatus {
    INITIALIZING,
    READY,
    RUNNING,
    WAITING_CHILDREN,
    COMPLETED,
    FAILED,
    CANCELLED,
};

NLOHMANN_JSON_SERIALIZE_ENUM(SessionStatus, {
    {SessionStatus::INITIALIZING, "initializing"},
    {SessionStatus::READY, "ready"},
    {SessionStatus::RUNNING, "running"},
    {SessionStatus::WAITING_CHILDREN, "waiting_children"},
    {SessionStatus::COMPLETED, "completed"},
    {SessionStatus::FAILED, "failed"},
    {SessionStatus::CANCELLED, "cancelled"},
})

enum class SimulationStatus {
    CREATED,
    RUNNING,
    PAUSED,
    COMPLETED,
    FAILED,
};

NLOHMANN_JSON_SERIALIZE_ENUM(SimulationStatus, {
    {SimulationStatus::CREATED, "created"},
    {SimulationStatus::RUNNING, "running"},
    {SimulationStatus::PAUSED, "paused"},
    {SimulationStatus::COMPLETED, "completed"},
    {SimulationStatus::FAILED, "failed"},
})

enum class ValidationStatus {
    PENDING,
    RUNNING,
    COMPLETED,
    FAILED,
    CANCELLED,
};

NLOHMANN_JSON_SERIALIZE_ENUM(ValidationStatus, {
    {ValidationStatus::PENDING, "pending"},
    {ValidationStatus::RUNNING, "running"},
    {ValidationStatus::COMPLETED, "completed"},
    {ValidationStatus::FAILED, "failed"},
    {ValidationStatus::CANCELLED, "cancelled"},
})

enum class AggregateAggregationMode {
    SUMMARY,
    VOTE,
    DISTRIBUTION,
    CONSENSUS,
};

NLOHMANN_JSON_SERIALIZE_ENUM(AggregateAggregationMode, {
    {AggregateAggregationMode::SUMMARY, "summary"},
    {AggregateAggregationMode::VOTE, "vote"},
    {AggregateAggregationMode::DISTRIBUTION, "distribution"},
    {AggregateAggregationMode::CONSENSUS, "consensus"},
})

enum class SessionsAggregationMode {
    NONE,
    SUMMARY,
    VOTE,
    DISTRIBUTION,
    CONSENSUS,
};

NLOHMANN_JSON_SERIALIZE_ENUM(SessionsAggregationMode, {
    {SessionsAggregationMode::NONE, "none"},
    {SessionsAggregationMode::SUMMARY, "summary"},
    {SessionsAggregationMode::VOTE, "vote"},
    {SessionsAggregationMode::DISTRIBUTION, "distribution"},
    {SessionsAggregationMode::CONSENSUS, "consensus"},
})

} // namespace ensoul
