#pragma once

#include <string>
#include <vector>
#include <map>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"

namespace ensoul {

// ---------------------------------------------------------------------------
// Typed request shapes for ``DomainConfigCreate`` (POST /v1/domains).
//
// The codegen layer (generated/domains.hpp) emits no models for the domain
// config — it is too large/recursive for the current generator — so these are
// hand-written here in the resource layer, mirroring the reference Python
// (DomainConfigCreateParams) and TypeScript (DomainConfigCreateInput) shapes,
// which in turn mirror the ``DomainConfigCreate`` Pydantic model (the API
// source of truth in ``src/api/models/domains.py``).
//
// Required keys are plain members; optional keys are ``std::optional`` and are
// omitted from the JSON body when unset (server applies its default). The
// serialization style matches the generated headers exactly: explicit inline
// to_json/from_json, snake_case keys, optionals emitted only when present.
// ---------------------------------------------------------------------------

// One tier in the hierarchy (level 0 is the root).
struct TierDefinitionCreate {
    int level = 0;
    std::string name;
    std::optional<std::string> description;
};

inline void to_json(nlohmann::json& j, const TierDefinitionCreate& t) {
    j = nlohmann::json{{"level", t.level}, {"name", t.name}};
    if (t.description) j["description"] = *t.description;
}

inline void from_json(const nlohmann::json& j, TierDefinitionCreate& t) {
    t.level = j.value("level", 0);
    j.at("name").get_to(t.name);
    if (j.contains("description") && !j["description"].is_null())
        t.description = j["description"].get<std::string>();
}

// A personality-schema field definition.
struct FieldDefinitionCreate {
    std::string path;
    std::string field_type;  // "float" | "int" | "str" | "enum" | "bool"
    std::optional<double> range_min;
    std::optional<double> range_max;
    std::optional<nlohmann::json> default_value;  // free-form default (JSON "default")
    std::optional<bool> required;
    std::optional<double> heritability;
    std::optional<std::string> description;
    std::optional<std::vector<std::string>> enum_values;
};

inline void to_json(nlohmann::json& j, const FieldDefinitionCreate& f) {
    j = nlohmann::json{{"path", f.path}, {"field_type", f.field_type}};
    if (f.range_min) j["range_min"] = *f.range_min;
    if (f.range_max) j["range_max"] = *f.range_max;
    if (f.default_value) j["default"] = *f.default_value;
    if (f.required) j["required"] = *f.required;
    if (f.heritability) j["heritability"] = *f.heritability;
    if (f.description) j["description"] = *f.description;
    if (f.enum_values) j["enum_values"] = *f.enum_values;
}

inline void from_json(const nlohmann::json& j, FieldDefinitionCreate& f) {
    j.at("path").get_to(f.path);
    j.at("field_type").get_to(f.field_type);
    if (j.contains("range_min") && !j["range_min"].is_null())
        f.range_min = j["range_min"].get<double>();
    if (j.contains("range_max") && !j["range_max"].is_null())
        f.range_max = j["range_max"].get<double>();
    if (j.contains("default") && !j["default"].is_null())
        f.default_value = j["default"];
    if (j.contains("required") && !j["required"].is_null())
        f.required = j["required"].get<bool>();
    if (j.contains("heritability") && !j["heritability"].is_null())
        f.heritability = j["heritability"].get<double>();
    if (j.contains("description") && !j["description"].is_null())
        f.description = j["description"].get<std::string>();
    if (j.contains("enum_values") && !j["enum_values"].is_null())
        f.enum_values = j["enum_values"].get<std::vector<std::string>>();
}

// Correlation between two personality traits.
struct TraitCorrelationCreate {
    std::string trait_a;
    std::string trait_b;
    double correlation = 0.0;
    std::optional<std::string> description;
};

inline void to_json(nlohmann::json& j, const TraitCorrelationCreate& t) {
    j = nlohmann::json{{"trait_a", t.trait_a}, {"trait_b", t.trait_b}, {"correlation", t.correlation}};
    if (t.description) j["description"] = *t.description;
}

inline void from_json(const nlohmann::json& j, TraitCorrelationCreate& t) {
    j.at("trait_a").get_to(t.trait_a);
    j.at("trait_b").get_to(t.trait_b);
    t.correlation = j.value("correlation", 0.0);
    if (j.contains("description") && !j["description"].is_null())
        t.description = j["description"].get<std::string>();
}

// Complete personality-schema configuration.
struct PersonalitySchemaCreate {
    std::vector<FieldDefinitionCreate> fields;
    std::optional<std::string> version;
    std::optional<std::vector<TraitCorrelationCreate>> trait_correlations;
};

inline void to_json(nlohmann::json& j, const PersonalitySchemaCreate& p) {
    j = nlohmann::json{{"fields", p.fields}};
    if (p.version) j["version"] = *p.version;
    if (p.trait_correlations) j["trait_correlations"] = *p.trait_correlations;
}

inline void from_json(const nlohmann::json& j, PersonalitySchemaCreate& p) {
    p.fields = j.at("fields").get<std::vector<FieldDefinitionCreate>>();
    if (j.contains("version") && !j["version"].is_null())
        p.version = j["version"].get<std::string>();
    if (j.contains("trait_correlations") && !j["trait_correlations"].is_null())
        p.trait_correlations = j["trait_correlations"].get<std::vector<TraitCorrelationCreate>>();
}

// An archetype in the hierarchy.
struct ArchetypeCreate {
    std::string id;
    std::string name;
    int tier = 0;
    std::optional<std::string> parent_id;
    std::optional<std::map<std::string, double>> personality_modifiers;
    std::optional<std::string> description;
    std::optional<nlohmann::json> metadata;  // free-form metadata object
    std::optional<double> probability;
};

inline void to_json(nlohmann::json& j, const ArchetypeCreate& a) {
    j = nlohmann::json{{"id", a.id}, {"name", a.name}, {"tier", a.tier}};
    if (a.parent_id) j["parent_id"] = *a.parent_id;
    if (a.personality_modifiers) j["personality_modifiers"] = *a.personality_modifiers;
    if (a.description) j["description"] = *a.description;
    if (a.metadata) j["metadata"] = *a.metadata;
    if (a.probability) j["probability"] = *a.probability;
}

inline void from_json(const nlohmann::json& j, ArchetypeCreate& a) {
    j.at("id").get_to(a.id);
    j.at("name").get_to(a.name);
    a.tier = j.value("tier", 0);
    if (j.contains("parent_id") && !j["parent_id"].is_null())
        a.parent_id = j["parent_id"].get<std::string>();
    if (j.contains("personality_modifiers") && !j["personality_modifiers"].is_null())
        a.personality_modifiers = j["personality_modifiers"].get<std::map<std::string, double>>();
    if (j.contains("description") && !j["description"].is_null())
        a.description = j["description"].get<std::string>();
    if (j.contains("metadata") && !j["metadata"].is_null())
        a.metadata = j["metadata"];
    if (j.contains("probability") && !j["probability"].is_null())
        a.probability = j["probability"].get<double>();
}

// Name-generation pattern for a tier value.
struct NamePatternCreate {
    std::string tier_id;
    std::string tier_value;
    std::optional<std::vector<std::string>> first_names;
    std::optional<std::vector<std::string>> last_names;
    std::optional<std::vector<std::string>> patterns;
    std::optional<std::string> gender_handling;  // "neutral" | "separate" | "none"
    std::optional<std::vector<std::string>> prefixes;
    std::optional<std::vector<std::string>> suffixes;
};

inline void to_json(nlohmann::json& j, const NamePatternCreate& n) {
    j = nlohmann::json{{"tier_id", n.tier_id}, {"tier_value", n.tier_value}};
    if (n.first_names) j["first_names"] = *n.first_names;
    if (n.last_names) j["last_names"] = *n.last_names;
    if (n.patterns) j["patterns"] = *n.patterns;
    if (n.gender_handling) j["gender_handling"] = *n.gender_handling;
    if (n.prefixes) j["prefixes"] = *n.prefixes;
    if (n.suffixes) j["suffixes"] = *n.suffixes;
}

inline void from_json(const nlohmann::json& j, NamePatternCreate& n) {
    j.at("tier_id").get_to(n.tier_id);
    j.at("tier_value").get_to(n.tier_value);
    if (j.contains("first_names") && !j["first_names"].is_null())
        n.first_names = j["first_names"].get<std::vector<std::string>>();
    if (j.contains("last_names") && !j["last_names"].is_null())
        n.last_names = j["last_names"].get<std::vector<std::string>>();
    if (j.contains("patterns") && !j["patterns"].is_null())
        n.patterns = j["patterns"].get<std::vector<std::string>>();
    if (j.contains("gender_handling") && !j["gender_handling"].is_null())
        n.gender_handling = j["gender_handling"].get<std::string>();
    if (j.contains("prefixes") && !j["prefixes"].is_null())
        n.prefixes = j["prefixes"].get<std::vector<std::string>>();
    if (j.contains("suffixes") && !j["suffixes"].is_null())
        n.suffixes = j["suffixes"].get<std::vector<std::string>>();
}

// Memory-template definition for backstory generation.
struct MemoryTemplateCreate {
    std::string template_id;
    std::string template_type;  // "universal" | "contextual"
    std::string template_string;
    std::optional<std::string> context_type;
    std::optional<std::string> context_id;
    std::optional<double> probability;
    std::optional<double> importance;
    std::optional<std::vector<std::string>> tags;
};

inline void to_json(nlohmann::json& j, const MemoryTemplateCreate& m) {
    j = nlohmann::json{
        {"template_id", m.template_id},
        {"template_type", m.template_type},
        {"template_string", m.template_string},
    };
    if (m.context_type) j["context_type"] = *m.context_type;
    if (m.context_id) j["context_id"] = *m.context_id;
    if (m.probability) j["probability"] = *m.probability;
    if (m.importance) j["importance"] = *m.importance;
    if (m.tags) j["tags"] = *m.tags;
}

inline void from_json(const nlohmann::json& j, MemoryTemplateCreate& m) {
    j.at("template_id").get_to(m.template_id);
    j.at("template_type").get_to(m.template_type);
    j.at("template_string").get_to(m.template_string);
    if (j.contains("context_type") && !j["context_type"].is_null())
        m.context_type = j["context_type"].get<std::string>();
    if (j.contains("context_id") && !j["context_id"].is_null())
        m.context_id = j["context_id"].get<std::string>();
    if (j.contains("probability") && !j["probability"].is_null())
        m.probability = j["probability"].get<double>();
    if (j.contains("importance") && !j["importance"].is_null())
        m.importance = j["importance"].get<double>();
    if (j.contains("tags") && !j["tags"].is_null())
        m.tags = j["tags"].get<std::vector<std::string>>();
}

// One option for a select/multiselect filterable field.
struct FilterableFieldOption {
    std::string value;
    std::string label;
};

inline void to_json(nlohmann::json& j, const FilterableFieldOption& o) {
    j = nlohmann::json{{"value", o.value}, {"label", o.label}};
}

inline void from_json(const nlohmann::json& j, FilterableFieldOption& o) {
    j.at("value").get_to(o.value);
    j.at("label").get_to(o.label);
}

// A field exposed for filtering in aggregate queries.
struct FilterableField {
    std::string path;
    std::string type;  // "range" | "select" | "multiselect"
    std::string label;
    std::optional<std::string> description;
    std::optional<double> min;
    std::optional<double> max;
    std::optional<double> step;
    std::optional<std::string> options_from;
    std::optional<std::vector<FilterableFieldOption>> options;
};

inline void to_json(nlohmann::json& j, const FilterableField& f) {
    j = nlohmann::json{{"path", f.path}, {"type", f.type}, {"label", f.label}};
    if (f.description) j["description"] = *f.description;
    if (f.min) j["min"] = *f.min;
    if (f.max) j["max"] = *f.max;
    if (f.step) j["step"] = *f.step;
    if (f.options_from) j["options_from"] = *f.options_from;
    if (f.options) j["options"] = *f.options;
}

inline void from_json(const nlohmann::json& j, FilterableField& f) {
    j.at("path").get_to(f.path);
    j.at("type").get_to(f.type);
    j.at("label").get_to(f.label);
    if (j.contains("description") && !j["description"].is_null())
        f.description = j["description"].get<std::string>();
    if (j.contains("min") && !j["min"].is_null())
        f.min = j["min"].get<double>();
    if (j.contains("max") && !j["max"].is_null())
        f.max = j["max"].get<double>();
    if (j.contains("step") && !j["step"].is_null())
        f.step = j["step"].get<double>();
    if (j.contains("options_from") && !j["options_from"].is_null())
        f.options_from = j["options_from"].get<std::string>();
    if (j.contains("options") && !j["options"].is_null())
        f.options = j["options"].get<std::vector<FilterableFieldOption>>();
}

// One weighted option for a tier value.
struct TierValueOption {
    std::string value;
    std::string label;
    std::optional<double> probability;
};

inline void to_json(nlohmann::json& j, const TierValueOption& o) {
    j = nlohmann::json{{"value", o.value}, {"label", o.label}};
    if (o.probability) j["probability"] = *o.probability;
}

inline void from_json(const nlohmann::json& j, TierValueOption& o) {
    j.at("value").get_to(o.value);
    j.at("label").get_to(o.label);
    if (j.contains("probability") && !j["probability"].is_null())
        o.probability = j["probability"].get<double>();
}

// Value configuration for hierarchical tier selection.
struct TierValuesConfig {
    std::string tier_id;
    std::vector<TierValueOption> options;
    std::optional<std::string> parent_tier_id;
    std::optional<std::map<std::string, std::vector<std::string>>> parent_value_mapping;
};

inline void to_json(nlohmann::json& j, const TierValuesConfig& t) {
    j = nlohmann::json{{"tier_id", t.tier_id}, {"options", t.options}};
    if (t.parent_tier_id) j["parent_tier_id"] = *t.parent_tier_id;
    if (t.parent_value_mapping) j["parent_value_mapping"] = *t.parent_value_mapping;
}

inline void from_json(const nlohmann::json& j, TierValuesConfig& t) {
    j.at("tier_id").get_to(t.tier_id);
    t.options = j.at("options").get<std::vector<TierValueOption>>();
    if (j.contains("parent_tier_id") && !j["parent_tier_id"].is_null())
        t.parent_tier_id = j["parent_tier_id"].get<std::string>();
    if (j.contains("parent_value_mapping") && !j["parent_value_mapping"].is_null())
        t.parent_value_mapping =
            j["parent_value_mapping"].get<std::map<std::string, std::vector<std::string>>>();
}

// Visual style template for avatar generation.
struct StyleTemplate {
    std::string name;
    std::string style_prompt;
    std::optional<std::string> description;
    std::optional<std::string> negative_prompt;
};

inline void to_json(nlohmann::json& j, const StyleTemplate& s) {
    j = nlohmann::json{{"name", s.name}, {"style_prompt", s.style_prompt}};
    if (s.description) j["description"] = *s.description;
    if (s.negative_prompt) j["negative_prompt"] = *s.negative_prompt;
}

inline void from_json(const nlohmann::json& j, StyleTemplate& s) {
    j.at("name").get_to(s.name);
    j.at("style_prompt").get_to(s.style_prompt);
    if (j.contains("description") && !j["description"].is_null())
        s.description = j["description"].get<std::string>();
    if (j.contains("negative_prompt") && !j["negative_prompt"].is_null())
        s.negative_prompt = j["negative_prompt"].get<std::string>();
}

// Domain-level avatar image-generation settings.
struct ImageGenerationConfig {
    std::optional<std::string> default_style;
    std::optional<std::vector<StyleTemplate>> styles;
    std::optional<std::string> prompt_prefix;
    std::optional<std::string> prompt_suffix;
};

inline void to_json(nlohmann::json& j, const ImageGenerationConfig& i) {
    j = nlohmann::json::object();
    if (i.default_style) j["default_style"] = *i.default_style;
    if (i.styles) j["styles"] = *i.styles;
    if (i.prompt_prefix) j["prompt_prefix"] = *i.prompt_prefix;
    if (i.prompt_suffix) j["prompt_suffix"] = *i.prompt_suffix;
}

inline void from_json(const nlohmann::json& j, ImageGenerationConfig& i) {
    if (j.contains("default_style") && !j["default_style"].is_null())
        i.default_style = j["default_style"].get<std::string>();
    if (j.contains("styles") && !j["styles"].is_null())
        i.styles = j["styles"].get<std::vector<StyleTemplate>>();
    if (j.contains("prompt_prefix") && !j["prompt_prefix"].is_null())
        i.prompt_prefix = j["prompt_prefix"].get<std::string>();
    if (j.contains("prompt_suffix") && !j["prompt_suffix"].is_null())
        i.prompt_suffix = j["prompt_suffix"].get<std::string>();
}

// Request body for ``POST /v1/domains`` (shaped to ``DomainConfigCreate``).
struct DomainConfigCreate {
    std::string name;
    std::string display_name;
    std::vector<TierDefinitionCreate> tiers;
    PersonalitySchemaCreate personality_schema;
    std::optional<std::string> version;
    std::optional<std::string> description;
    std::optional<std::vector<ArchetypeCreate>> archetypes;
    std::optional<std::vector<NamePatternCreate>> name_patterns;
    std::optional<std::vector<MemoryTemplateCreate>> memory_templates;
    std::optional<std::vector<FilterableField>> filterable_fields;
    std::optional<std::vector<TierValuesConfig>> tier_values;
    std::optional<ImageGenerationConfig> image_generation;
    std::optional<std::vector<std::string>> behavioral_guidelines;
    std::optional<std::vector<std::string>> chat_guardrails;
    std::optional<double> chat_temperature;
    std::optional<std::string> entity_noun;
    std::optional<bool> is_draft;
    std::optional<std::vector<std::string>> tags;
    std::optional<std::vector<std::string>> frameworks;
};

inline void to_json(nlohmann::json& j, const DomainConfigCreate& d) {
    j = nlohmann::json{
        {"name", d.name},
        {"display_name", d.display_name},
        {"tiers", d.tiers},
        {"personality_schema", d.personality_schema},
    };
    if (d.version) j["version"] = *d.version;
    if (d.description) j["description"] = *d.description;
    if (d.archetypes) j["archetypes"] = *d.archetypes;
    if (d.name_patterns) j["name_patterns"] = *d.name_patterns;
    if (d.memory_templates) j["memory_templates"] = *d.memory_templates;
    if (d.filterable_fields) j["filterable_fields"] = *d.filterable_fields;
    if (d.tier_values) j["tier_values"] = *d.tier_values;
    if (d.image_generation) j["image_generation"] = *d.image_generation;
    if (d.behavioral_guidelines) j["behavioral_guidelines"] = *d.behavioral_guidelines;
    if (d.chat_guardrails) j["chat_guardrails"] = *d.chat_guardrails;
    if (d.chat_temperature) j["chat_temperature"] = *d.chat_temperature;
    if (d.entity_noun) j["entity_noun"] = *d.entity_noun;
    if (d.is_draft) j["is_draft"] = *d.is_draft;
    if (d.tags) j["tags"] = *d.tags;
    if (d.frameworks) j["frameworks"] = *d.frameworks;
}

inline void from_json(const nlohmann::json& j, DomainConfigCreate& d) {
    j.at("name").get_to(d.name);
    j.at("display_name").get_to(d.display_name);
    d.tiers = j.at("tiers").get<std::vector<TierDefinitionCreate>>();
    d.personality_schema = j.at("personality_schema").get<PersonalitySchemaCreate>();
    if (j.contains("version") && !j["version"].is_null())
        d.version = j["version"].get<std::string>();
    if (j.contains("description") && !j["description"].is_null())
        d.description = j["description"].get<std::string>();
    if (j.contains("archetypes") && !j["archetypes"].is_null())
        d.archetypes = j["archetypes"].get<std::vector<ArchetypeCreate>>();
    if (j.contains("name_patterns") && !j["name_patterns"].is_null())
        d.name_patterns = j["name_patterns"].get<std::vector<NamePatternCreate>>();
    if (j.contains("memory_templates") && !j["memory_templates"].is_null())
        d.memory_templates = j["memory_templates"].get<std::vector<MemoryTemplateCreate>>();
    if (j.contains("filterable_fields") && !j["filterable_fields"].is_null())
        d.filterable_fields = j["filterable_fields"].get<std::vector<FilterableField>>();
    if (j.contains("tier_values") && !j["tier_values"].is_null())
        d.tier_values = j["tier_values"].get<std::vector<TierValuesConfig>>();
    if (j.contains("image_generation") && !j["image_generation"].is_null())
        d.image_generation = j["image_generation"].get<ImageGenerationConfig>();
    if (j.contains("behavioral_guidelines") && !j["behavioral_guidelines"].is_null())
        d.behavioral_guidelines = j["behavioral_guidelines"].get<std::vector<std::string>>();
    if (j.contains("chat_guardrails") && !j["chat_guardrails"].is_null())
        d.chat_guardrails = j["chat_guardrails"].get<std::vector<std::string>>();
    if (j.contains("chat_temperature") && !j["chat_temperature"].is_null())
        d.chat_temperature = j["chat_temperature"].get<double>();
    if (j.contains("entity_noun") && !j["entity_noun"].is_null())
        d.entity_noun = j["entity_noun"].get<std::string>();
    if (j.contains("is_draft") && !j["is_draft"].is_null())
        d.is_draft = j["is_draft"].get<bool>();
    if (j.contains("tags") && !j["tags"].is_null())
        d.tags = j["tags"].get<std::vector<std::string>>();
    if (j.contains("frameworks") && !j["frameworks"].is_null())
        d.frameworks = j["frameworks"].get<std::vector<std::string>>();
}

// Response from ``POST /v1/domains/generate`` (the AI wizard).
struct GeneratedConfigResponse {
    DomainConfigCreate config;        // ready to pass straight to create()
    std::string explanation;
    std::vector<std::string> suggestions;
    double confidence = 0.0;
};

inline void from_json(const nlohmann::json& j, GeneratedConfigResponse& g) {
    g.config = j.at("config").get<DomainConfigCreate>();
    g.explanation = j.value("explanation", std::string(""));
    if (j.contains("suggestions") && !j["suggestions"].is_null())
        g.suggestions = j["suggestions"].get<std::vector<std::string>>();
    g.confidence = j.value("confidence", 0.0);
}

class DomainsResource {
public:
    explicit DomainsResource(IHttpTransport& transport) : transport_(transport) {}

    Page<nlohmann::json> list(int page = 1, int per_page = 20) {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        auto resp = transport_.request("GET", "/v1/domains", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);

        auto fetcher = [this, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET", "/v1/domains", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
        return Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    }

    nlohmann::json get(const std::string& domain_id) {
        auto resp = transport_.request("GET", "/v1/domains/" + domain_id);
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/domains — create a domain from a full DomainConfigCreate.
    //
    // Step 1 of the dev workflow. To build the config with the AI wizard instead
    // of by hand, call generate() first and pass its `.config` here.
    nlohmann::json create(const DomainConfigCreate& config) {
        auto resp = transport_.request("POST", "/v1/domains", nlohmann::json(config));
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/domains/generate — AI wizard (requires PRO tier).
    //
    // Generate a domain configuration from a natural-language `description` using
    // Claude. The returned `.config` is a ready-to-use DomainConfigCreate that can
    // be passed straight to create(). `context` is optional extra grounding;
    // `target_sections` defaults to {"all"}.
    GeneratedConfigResponse generate(const std::string& description,
                                     const nlohmann::json& context = nlohmann::json::object(),
                                     const std::vector<std::string>& target_sections = {"all"}) {
        nlohmann::json body{{"description", description}};
        if (!context.is_null() && !context.empty()) body["context"] = context;
        body["target_sections"] = target_sections;
        auto resp = transport_.request("POST", "/v1/domains/generate", body);
        return nlohmann::json::parse(resp.body).get<GeneratedConfigResponse>();
    }

    nlohmann::json update(const std::string& domain_id, const nlohmann::json& body) {
        auto resp = transport_.request("PUT", "/v1/domains/" + domain_id, body);
        return nlohmann::json::parse(resp.body);
    }

    void delete_(const std::string& domain_id) {
        transport_.request("DELETE", "/v1/domains/" + domain_id);
    }

    // POST /v1/domains/validate — validate a domain config (DomainConfigCreate).
    nlohmann::json validate(const nlohmann::json& config) {
        auto resp = transport_.request("POST", "/v1/domains/validate", config);
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
