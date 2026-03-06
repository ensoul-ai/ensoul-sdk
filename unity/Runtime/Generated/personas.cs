// Generated models for the personas resource group.
// DO NOT EDIT — regenerate with: make sdk-regen
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul
{
    /// <summary>Create persona request. Domain-agnostic: Requires domain and personality_data.</summary>
    public class PersonaCreate
    {
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("domain")] public string Domain { get; set; } = "";
        [JsonProperty("archetype")] public string? Archetype { get; set; }
        [JsonProperty("region")] public string? Region { get; set; }
        [JsonProperty("personality_data")] public JObject? PersonalityData { get; set; }
        [JsonProperty("age")] public int? Age { get; set; }
        [JsonProperty("country")] public string? Country { get; set; }
        [JsonProperty("city")] public string? City { get; set; }
        [JsonProperty("backstory")] public string? Backstory { get; set; }
        [JsonProperty("core_values")] public List<string>? CoreValues { get; set; }
        [JsonProperty("communication_style")] public JObject? CommunicationStyle { get; set; }
    }

    /// <summary>Update persona request (partial updates). Domain-agnostic: Updates flow through personality_data.</summary>
    public class PersonaUpdate
    {
        [JsonProperty("name")] public string? Name { get; set; }
        [JsonProperty("personality_data")] public JObject? PersonalityData { get; set; }
        [JsonProperty("age")] public int? Age { get; set; }
        [JsonProperty("country")] public string? Country { get; set; }
        [JsonProperty("region")] public string? Region { get; set; }
        [JsonProperty("city")] public string? City { get; set; }
        [JsonProperty("backstory")] public string? Backstory { get; set; }
        [JsonProperty("core_values")] public List<string>? CoreValues { get; set; }
        [JsonProperty("communication_style")] public JObject? CommunicationStyle { get; set; }
    }

    /// <summary>Batch create personas request.</summary>
    public class PersonaBatchCreate
    {
        [JsonProperty("personas")] public List<PersonaCreate> Personas { get; set; } = new List<PersonaCreate>();
        [JsonProperty("batch_id")] public string? BatchId { get; set; }
        [JsonProperty("domain")] public string? Domain { get; set; }
    }

    /// <summary>Persona response with core information. Domain-agnostic: All personality data in personality_data field.</summary>
    public class PersonaResponse
    {
        [JsonProperty("id")] public string Id { get; set; } = "";
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("domain")] public string Domain { get; set; } = "";
        [JsonProperty("personality_data")] public JObject? PersonalityData { get; set; }
        [JsonProperty("avatar_url")] public string? AvatarUrl { get; set; }
        [JsonProperty("archetype")] public string? Archetype { get; set; }
        [JsonProperty("age")] public int? Age { get; set; }
        [JsonProperty("country")] public string? Country { get; set; }
        [JsonProperty("region")] public string? Region { get; set; }
        [JsonProperty("city")] public string? City { get; set; }
        [JsonProperty("batch_id")] public string? BatchId { get; set; }
        [JsonProperty("created_at")] public string CreatedAt { get; set; } = "";
    }

    /// <summary>Paginated list of personas.</summary>
    public class PersonaListResponse
    {
        [JsonProperty("total")] public int Total { get; set; }
        [JsonProperty("items")] public List<PersonaResponse> Items { get; set; } = new List<PersonaResponse>();
        [JsonProperty("page")] public int Page { get; set; }
        [JsonProperty("per_page")] public int PerPage { get; set; }
        [JsonProperty("pages")] public int Pages { get; set; }
    }

    /// <summary>Full personality vector response. Domain-agnostic: Returns personality_data in domain-specific format.</summary>
    public class PersonalityVectorResponse
    {
        [JsonProperty("persona_id")] public string PersonaId { get; set; } = "";
        [JsonProperty("domain")] public string Domain { get; set; } = "";
        [JsonProperty("personality_data")] public JObject? PersonalityData { get; set; }
        [JsonProperty("communication_style")] public JObject? CommunicationStyle { get; set; }
        [JsonProperty("core_values")] public List<string>? CoreValues { get; set; }
    }

    /// <summary>Batch operation response.</summary>
    public class PersonaBatchResponse
    {
        [JsonProperty("created")] public int Created { get; set; }
        [JsonProperty("persona_ids")] public List<string> PersonaIds { get; set; } = new List<string>();
        [JsonProperty("batch_id")] public string? BatchId { get; set; }
        [JsonProperty("domain")] public string? Domain { get; set; }
    }

    /// <summary>A filter option with ID, name, and count.</summary>
    public class FilterOption
    {
        [JsonProperty("id")] public string Id { get; set; } = "";
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("count")] public int Count { get; set; }
    }

    /// <summary>Available filter options for persona browsing.</summary>
    public class PersonaFiltersResponse
    {
        [JsonProperty("domains")] public List<FilterOption>? Domains { get; set; }
        [JsonProperty("regions")] public List<FilterOption>? Regions { get; set; }
        [JsonProperty("archetypes")] public List<FilterOption>? Archetypes { get; set; }
        [JsonProperty("countries")] public List<FilterOption>? Countries { get; set; }
        [JsonProperty("age_ranges")] public List<FilterOption>? AgeRanges { get; set; }
        [JsonProperty("total_personas")] public int TotalPersonas { get; set; }
    }
}
