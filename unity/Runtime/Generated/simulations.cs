// Generated models for the simulations resource group.
// DO NOT EDIT — regenerate with: make sdk-regen
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul
{
    /// <summary>Full simulation detail.</summary>
    public class SimulationDetailResponse
    {
        [JsonProperty("id")] public string Id { get; set; } = "";
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("domain_id")] public string DomainId { get; set; } = "";
        [JsonProperty("description")] public string? Description { get; set; }
        [JsonProperty("status")] public SimulationStatus Status { get; set; }
        [JsonProperty("config")] public JObject? Config { get; set; }
        [JsonProperty("participant_count")] public int? ParticipantCount { get; set; }
        [JsonProperty("created_at")] public string CreatedAt { get; set; } = "";
        [JsonProperty("updated_at")] public string? UpdatedAt { get; set; }
    }

    /// <summary>Weights for the interaction scheduler's pair selection algorithm.</summary>
    public class SchedulerWeights
    {
        [JsonProperty("recency")] public double Recency { get; set; } = 1.0;
        [JsonProperty("affinity")] public double Affinity { get; set; } = 1.0;
        [JsonProperty("diversity")] public double Diversity { get; set; } = 1.0;
    }

    /// <summary>A persona participant in a simulation.</summary>
    public class ParticipantResponse
    {
        [JsonProperty("persona_id")] public string PersonaId { get; set; } = "";
        [JsonProperty("joined_at")] public string? JoinedAt { get; set; }
        [JsonProperty("status")] public string? Status { get; set; }
    }

    /// <summary>Summary simulation item for list responses.</summary>
    public class SimulationSimulationResponse
    {
        [JsonProperty("id")] public string Id { get; set; } = "";
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("domain_id")] public string DomainId { get; set; } = "";
        [JsonProperty("status")] public SimulationStatus Status { get; set; }
        [JsonProperty("current_tick")] public int CurrentTick { get; set; }
        [JsonProperty("created_at")] public string CreatedAt { get; set; } = "";
        [JsonProperty("updated_at")] public string UpdatedAt { get; set; } = "";
    }
}
