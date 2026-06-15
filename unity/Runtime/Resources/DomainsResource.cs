using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    // -----------------------------------------------------------------------
    // Typed request shapes for DomainConfigCreate (POST /v1/domains).
    //
    // The generated model layer (Runtime/Generated/domains.cs) returns domain
    // responses as JObject and ships no typed request models — a codegen gap.
    // These hand-written classes mirror the DomainConfigCreate Pydantic model
    // (the API source of truth in src/api/models/domains.py), reusing the
    // generated FieldType / FilterableFieldType / GenderHandling enums from
    // Runtime/Generated/enums.cs. Required properties are non-nullable; every
    // optional property is nullable so NullValueHandling.Ignore drops it and the
    // server applies its default. Snake_case wire names via [JsonProperty].
    // -----------------------------------------------------------------------

    /// <summary>One tier in the hierarchy (level 0 is the root).</summary>
    [System.Serializable]
    public class TierDefinitionCreate
    {
        [JsonProperty("level")] public int Level { get; set; }
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("description")] public string? Description { get; set; }
    }

    /// <summary>A personality-schema field definition.</summary>
    [System.Serializable]
    public class FieldDefinition
    {
        [JsonProperty("path")] public string Path { get; set; } = "";
        [JsonProperty("field_type")] public FieldType FieldType { get; set; }
        [JsonProperty("range_min")] public double? RangeMin { get; set; }
        [JsonProperty("range_max")] public double? RangeMax { get; set; }
        /// <summary>Free-form default value (e.g. <c>{ "value": 50 }</c>).</summary>
        [JsonProperty("default")] public JObject? Default { get; set; }
        [JsonProperty("required")] public bool? Required { get; set; }
        [JsonProperty("heritability")] public double? Heritability { get; set; }
        [JsonProperty("description")] public string? Description { get; set; }
        [JsonProperty("enum_values")] public List<string>? EnumValues { get; set; }
    }

    /// <summary>Correlation between two personality traits.</summary>
    [System.Serializable]
    public class TraitCorrelation
    {
        [JsonProperty("trait_a")] public string TraitA { get; set; } = "";
        [JsonProperty("trait_b")] public string TraitB { get; set; } = "";
        [JsonProperty("correlation")] public double Correlation { get; set; }
        [JsonProperty("description")] public string? Description { get; set; }
    }

    /// <summary>Complete personality-schema configuration.</summary>
    [System.Serializable]
    public class PersonalitySchema
    {
        [JsonProperty("fields")] public List<FieldDefinition> Fields { get; set; } = new List<FieldDefinition>();
        [JsonProperty("version")] public string? Version { get; set; }
        [JsonProperty("trait_correlations")] public List<TraitCorrelation>? TraitCorrelations { get; set; }
    }

    /// <summary>An archetype in the hierarchy.</summary>
    [System.Serializable]
    public class Archetype
    {
        [JsonProperty("id")] public string Id { get; set; } = "";
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("tier")] public int Tier { get; set; }
        [JsonProperty("parent_id")] public string? ParentId { get; set; }
        [JsonProperty("personality_modifiers")] public Dictionary<string, double>? PersonalityModifiers { get; set; }
        [JsonProperty("description")] public string? Description { get; set; }
        /// <summary>Free-form archetype metadata.</summary>
        [JsonProperty("metadata")] public JObject? Metadata { get; set; }
        [JsonProperty("probability")] public double? Probability { get; set; }
    }

    /// <summary>Name-generation pattern for a tier value.</summary>
    [System.Serializable]
    public class NamePattern
    {
        [JsonProperty("tier_id")] public string TierId { get; set; } = "";
        [JsonProperty("tier_value")] public string TierValue { get; set; } = "";
        [JsonProperty("first_names")] public List<string>? FirstNames { get; set; }
        [JsonProperty("last_names")] public List<string>? LastNames { get; set; }
        [JsonProperty("patterns")] public List<string>? Patterns { get; set; }
        [JsonProperty("gender_handling")] public GenderHandling? GenderHandling { get; set; }
        [JsonProperty("prefixes")] public List<string>? Prefixes { get; set; }
        [JsonProperty("suffixes")] public List<string>? Suffixes { get; set; }
    }

    /// <summary>Memory-template definition for backstory generation.</summary>
    [System.Serializable]
    public class MemoryTemplate
    {
        [JsonProperty("template_id")] public string TemplateId { get; set; } = "";
        /// <summary>Template kind: <c>"universal"</c> or <c>"contextual"</c>.</summary>
        [JsonProperty("template_type")] public string TemplateType { get; set; } = "";
        [JsonProperty("template_string")] public string TemplateString { get; set; } = "";
        [JsonProperty("context_type")] public string? ContextType { get; set; }
        [JsonProperty("context_id")] public string? ContextId { get; set; }
        [JsonProperty("probability")] public double? Probability { get; set; }
        [JsonProperty("importance")] public double? Importance { get; set; }
        [JsonProperty("tags")] public List<string>? Tags { get; set; }
    }

    /// <summary>One option for a select/multiselect filterable field.</summary>
    [System.Serializable]
    public class FilterableFieldOption
    {
        [JsonProperty("value")] public string Value { get; set; } = "";
        [JsonProperty("label")] public string Label { get; set; } = "";
    }

    /// <summary>A field exposed for filtering in aggregate queries.</summary>
    [System.Serializable]
    public class FilterableField
    {
        [JsonProperty("path")] public string Path { get; set; } = "";
        [JsonProperty("type")] public FilterableFieldType Type { get; set; }
        [JsonProperty("label")] public string Label { get; set; } = "";
        [JsonProperty("description")] public string? Description { get; set; }
        [JsonProperty("min")] public double? Min { get; set; }
        [JsonProperty("max")] public double? Max { get; set; }
        [JsonProperty("step")] public double? Step { get; set; }
        [JsonProperty("options_from")] public string? OptionsFrom { get; set; }
        [JsonProperty("options")] public List<FilterableFieldOption>? Options { get; set; }
    }

    /// <summary>One weighted option for a tier value.</summary>
    [System.Serializable]
    public class TierValueOption
    {
        [JsonProperty("value")] public string Value { get; set; } = "";
        [JsonProperty("label")] public string Label { get; set; } = "";
        [JsonProperty("probability")] public double? Probability { get; set; }
    }

    /// <summary>Value configuration for hierarchical tier selection.</summary>
    [System.Serializable]
    public class TierValuesConfig
    {
        [JsonProperty("tier_id")] public string TierId { get; set; } = "";
        [JsonProperty("options")] public List<TierValueOption> Options { get; set; } = new List<TierValueOption>();
        [JsonProperty("parent_tier_id")] public string? ParentTierId { get; set; }
        [JsonProperty("parent_value_mapping")] public Dictionary<string, List<string>>? ParentValueMapping { get; set; }
    }

    /// <summary>Visual style template for avatar generation.</summary>
    [System.Serializable]
    public class StyleTemplate
    {
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("style_prompt")] public string StylePrompt { get; set; } = "";
        [JsonProperty("description")] public string? Description { get; set; }
        [JsonProperty("negative_prompt")] public string? NegativePrompt { get; set; }
    }

    /// <summary>Domain-level avatar image-generation settings.</summary>
    [System.Serializable]
    public class ImageGenerationConfig
    {
        [JsonProperty("default_style")] public string? DefaultStyle { get; set; }
        [JsonProperty("styles")] public List<StyleTemplate>? Styles { get; set; }
        [JsonProperty("prompt_prefix")] public string? PromptPrefix { get; set; }
        [JsonProperty("prompt_suffix")] public string? PromptSuffix { get; set; }
    }

    /// <summary>
    /// Request body for <c>POST /v1/domains</c>, shaped to the DomainConfigCreate
    /// Pydantic model (the API source of truth). Compose it from the building-block
    /// types and pass it straight to <see cref="DomainsResource.CreateAsync"/>.
    /// </summary>
    [System.Serializable]
    public class DomainConfigCreate
    {
        /// <summary>Domain identifier (lowercase, alphanumeric, underscores).</summary>
        [JsonProperty("name")] public string Name { get; set; } = "";
        /// <summary>Human-readable domain name.</summary>
        [JsonProperty("display_name")] public string DisplayName { get; set; } = "";
        /// <summary>Semantic version, e.g. <c>"1.0.0"</c>. Defaults to <c>"1.0.0"</c>.</summary>
        [JsonProperty("version")] public string? Version { get; set; }
        [JsonProperty("description")] public string? Description { get; set; }
        /// <summary>Tier definitions; must include a root tier at level 0.</summary>
        [JsonProperty("tiers")] public List<TierDefinitionCreate> Tiers { get; set; } = new List<TierDefinitionCreate>();
        [JsonProperty("personality_schema")] public PersonalitySchema PersonalitySchema { get; set; } = new PersonalitySchema();
        [JsonProperty("archetypes")] public List<Archetype>? Archetypes { get; set; }
        [JsonProperty("name_patterns")] public List<NamePattern>? NamePatterns { get; set; }
        [JsonProperty("memory_templates")] public List<MemoryTemplate>? MemoryTemplates { get; set; }
        [JsonProperty("filterable_fields")] public List<FilterableField>? FilterableFields { get; set; }
        [JsonProperty("tier_values")] public List<TierValuesConfig>? TierValues { get; set; }
        [JsonProperty("image_generation")] public ImageGenerationConfig? ImageGeneration { get; set; }
        /// <summary>Domain-wide behavioral rules added to every persona's system prompt.</summary>
        [JsonProperty("behavioral_guidelines")] public List<string>? BehavioralGuidelines { get; set; }
        /// <summary>Short directives re-injected into every chat turn (re-anchor capsule).</summary>
        [JsonProperty("chat_guardrails")] public List<string>? ChatGuardrails { get; set; }
        /// <summary>Per-domain chat sampling temperature (0.0-2.0).</summary>
        [JsonProperty("chat_temperature")] public double? ChatTemperature { get; set; }
        /// <summary>Identity framing: what each persona IS (e.g. <c>"person"</c>, <c>"pet"</c>, <c>"character"</c>).</summary>
        [JsonProperty("entity_noun")] public string? EntityNoun { get; set; }
        [JsonProperty("is_draft")] public bool? IsDraft { get; set; }
        [JsonProperty("tags")] public List<string>? Tags { get; set; }
        [JsonProperty("frameworks")] public List<string>? Frameworks { get; set; }
    }

    /// <summary>Response from <c>POST /v1/domains/generate</c> (the AI wizard).</summary>
    [System.Serializable]
    public class GeneratedConfigResponse
    {
        /// <summary>Generated configuration — ready to pass to <see cref="DomainsResource.CreateAsync"/>.</summary>
        [JsonProperty("config")] public DomainConfigCreate Config { get; set; } = new DomainConfigCreate();
        /// <summary>Explanation of the generated config.</summary>
        [JsonProperty("explanation")] public string Explanation { get; set; } = "";
        /// <summary>Suggestions for improvement.</summary>
        [JsonProperty("suggestions")] public List<string> Suggestions { get; set; } = new List<string>();
        /// <summary>Confidence score (0.0-1.0).</summary>
        [JsonProperty("confidence")] public double Confidence { get; set; }
    }

    public class DomainsResource
    {
        private readonly EnsoulHttpClient _client;

        public DomainsResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<Page<JObject>> ListAsync(
            int page = 1,
            int perPage = 20,
            Dictionary<string, object?> extras = null)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    queryParams[kv.Key] = kv.Value;

            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/domains", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get, "/v1/domains", queryParams,
                obj => obj);
        }

        public async Task<JObject> GetAsync(string domainId)
        {
            var response = await _client.RequestAsync(HttpMethod.Get, $"/v1/domains/{domainId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>
        /// POST /v1/domains — create a domain from a full <see cref="DomainConfigCreate"/>.
        /// <para>
        /// This is step 1 of the dev workflow. To build the config with the AI wizard
        /// instead of by hand, call <see cref="GenerateAsync"/> first and pass its
        /// <see cref="GeneratedConfigResponse.Config"/> here.
        /// </para>
        /// </summary>
        public async Task<JObject> CreateAsync(DomainConfigCreate config)
        {
            // Serialize the typed config to a JObject honoring [JsonProperty] snake_case
            // names and NullValueHandling.Ignore, then hand it to the dictionary-based
            // transport (the same serializer the resource layer uses for decoding).
            var serializer = JsonSerializer.Create(EnsoulHttpClient.JsonSettings);
            var body = JObject.FromObject(config, serializer).ToObject<Dictionary<string, object?>>();
            var response = await _client.RequestAsync(HttpMethod.Post, "/v1/domains", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>
        /// POST /v1/domains/generate — generate a domain configuration from a
        /// natural-language <paramref name="description"/> using the Claude AI wizard
        /// (requires PRO tier).
        /// <para>
        /// The returned <see cref="GeneratedConfigResponse.Config"/> is a ready-to-use
        /// <see cref="DomainConfigCreate"/> that can be passed straight to
        /// <see cref="CreateAsync"/>.
        /// </para>
        /// </summary>
        /// <param name="description">Natural-language description of the domain (10-5000 chars).</param>
        /// <param name="context">Additional context for the generator (example personas, inspiration, etc.).</param>
        /// <param name="targetSections">Which sections to generate. Defaults to <c>["all"]</c> server-side.</param>
        public async Task<GeneratedConfigResponse> GenerateAsync(
            string description,
            IDictionary<string, object>? context = null,
            IList<string>? targetSections = null)
        {
            var body = new Dictionary<string, object?> { ["description"] = description };
            if (context != null) body["context"] = context;
            if (targetSections != null) body["target_sections"] = targetSections;
            return await _client.PostAsync<GeneratedConfigResponse>("/v1/domains/generate", body);
        }

        public async Task<JObject> UpdateAsync(string domainId, Dictionary<string, object?> body)
        {
            var response = await _client.RequestAsync(HttpMethod.Put, $"/v1/domains/{domainId}", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task DeleteAsync(string domainId)
            => await _client.DeleteAsync($"/v1/domains/{domainId}");

        /// <summary>POST /v1/domains/validate — validate a domain config (<c>DomainConfigCreate</c>).</summary>
        public async Task<JObject> ValidateAsync(Dictionary<string, object?> config)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Post, "/v1/domains/validate", json: config);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
