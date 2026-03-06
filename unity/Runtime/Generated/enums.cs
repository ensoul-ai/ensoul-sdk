// Generated enum types from OpenAPI spec.
// DO NOT EDIT — regenerate with: make sdk-regen

using System.Runtime.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Ensoul
{
    /// <summary>Supported field types for personality schema fields.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum FieldType
    {
        [EnumMember(Value = "float")] Float,
        [EnumMember(Value = "int")] Int,
        [EnumMember(Value = "str")] Str,
        [EnumMember(Value = "enum")] Enum,
        [EnumMember(Value = "bool")] Bool,
    }

    /// <summary>Supported filter types for persona queries.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum FilterableFieldType
    {
        [EnumMember(Value = "range")] Range,
        [EnumMember(Value = "select")] Select,
        [EnumMember(Value = "multiselect")] Multiselect,
    }

    /// <summary>How name generation handles gender.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum GenderHandling
    {
        [EnumMember(Value = "neutral")] Neutral,
        [EnumMember(Value = "separate")] Separate,
        [EnumMember(Value = "none")] None,
    }

    /// <summary>Types of cross-level influence.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum InfluenceType
    {
        [EnumMember(Value = "governance")] Governance,
        [EnumMember(Value = "media")] Media,
        [EnumMember(Value = "institution")] Institution,
        [EnumMember(Value = "influence")] Influence,
        [EnumMember(Value = "economic")] Economic,
    }

    /// <summary>Export format options.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum PersonaExportFormat
    {
        [EnumMember(Value = "json")] Json,
        [EnumMember(Value = "yaml")] Yaml,
    }

    /// <summary>Session state enumeration.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum SessionStatus
    {
        [EnumMember(Value = "initializing")] Initializing,
        [EnumMember(Value = "ready")] Ready,
        [EnumMember(Value = "running")] Running,
        [EnumMember(Value = "waiting_children")] WaitingChildren,
        [EnumMember(Value = "completed")] Completed,
        [EnumMember(Value = "failed")] Failed,
        [EnumMember(Value = "cancelled")] Cancelled,
    }

    /// <summary>Simulation lifecycle status.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum SimulationStatus
    {
        [EnumMember(Value = "created")] Created,
        [EnumMember(Value = "running")] Running,
        [EnumMember(Value = "paused")] Paused,
        [EnumMember(Value = "completed")] Completed,
        [EnumMember(Value = "failed")] Failed,
    }

    /// <summary>Status of a validation job.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum ValidationStatus
    {
        [EnumMember(Value = "pending")] Pending,
        [EnumMember(Value = "running")] Running,
        [EnumMember(Value = "completed")] Completed,
        [EnumMember(Value = "failed")] Failed,
        [EnumMember(Value = "cancelled")] Cancelled,
    }

    /// <summary>How to aggregate responses.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum AggregateAggregationMode
    {
        [EnumMember(Value = "summary")] Summary,
        [EnumMember(Value = "vote")] Vote,
        [EnumMember(Value = "distribution")] Distribution,
        [EnumMember(Value = "consensus")] Consensus,
    }

    /// <summary>How to aggregate child responses.</summary>
    [JsonConverter(typeof(StringEnumConverter))]
    public enum SessionsAggregationMode
    {
        [EnumMember(Value = "none")] None,
        [EnumMember(Value = "summary")] Summary,
        [EnumMember(Value = "vote")] Vote,
        [EnumMember(Value = "distribution")] Distribution,
        [EnumMember(Value = "consensus")] Consensus,
    }
}
