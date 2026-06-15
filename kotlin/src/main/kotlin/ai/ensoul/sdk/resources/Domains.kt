package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.Page
import ai.ensoul.sdk.generated.FieldType
import ai.ensoul.sdk.generated.FilterableFieldType
import ai.ensoul.sdk.generated.GenderHandling
import io.ktor.client.statement.*
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.longOrNull

// ---------------------------------------------------------------------------
// Typed request shapes for `DomainConfigCreate` (POST /v1/domains).
//
// These mirror the `DomainConfigCreate` Pydantic model (the API source of
// truth in `src/api/models/domains.py`). The codegen layer leaves domain
// models as dynamic JsonObject (see generated/domains.kt), so — exactly like
// the Python and TypeScript reference SDKs — the typed shape is hand-written
// here in the resource layer. camelCase Kotlin properties map to the API's
// snake_case wire format via @SerialName. Required fields are non-nullable;
// every optional field is nullable with a `null` default so it is omitted from
// the request (encodeDefaults is off) and the server applies its own default.
// ---------------------------------------------------------------------------

/** One tier in the hierarchy (level 0 is the root). */
@Serializable
data class TierDefinition(
    val level: Int,
    val name: String,
    val description: String? = null,
)

/** A personality-schema field definition. */
@Serializable
data class FieldDefinition(
    val path: String,
    @SerialName("field_type") val fieldType: FieldType,
    @SerialName("range_min") val rangeMin: Double? = null,
    @SerialName("range_max") val rangeMax: Double? = null,
    val default: JsonObject? = null,
    val required: Boolean? = null,
    val heritability: Double? = null,
    val description: String? = null,
    @SerialName("enum_values") val enumValues: List<String>? = null,
)

/** Correlation between two personality traits. */
@Serializable
data class TraitCorrelation(
    @SerialName("trait_a") val traitA: String,
    @SerialName("trait_b") val traitB: String,
    val correlation: Double,
    val description: String? = null,
)

/** Complete personality-schema configuration. */
@Serializable
data class PersonalitySchema(
    val fields: List<FieldDefinition>,
    val version: String? = null,
    @SerialName("trait_correlations") val traitCorrelations: List<TraitCorrelation>? = null,
)

/** An archetype in the hierarchy. */
@Serializable
data class Archetype(
    val id: String,
    val name: String,
    val tier: Int,
    @SerialName("parent_id") val parentId: String? = null,
    @SerialName("personality_modifiers") val personalityModifiers: Map<String, Double>? = null,
    val description: String? = null,
    val metadata: JsonObject? = null,
    val probability: Double? = null,
)

/** Name-generation pattern for a tier value. */
@Serializable
data class NamePattern(
    @SerialName("tier_id") val tierId: String,
    @SerialName("tier_value") val tierValue: String,
    @SerialName("first_names") val firstNames: List<String>? = null,
    @SerialName("last_names") val lastNames: List<String>? = null,
    val patterns: List<String>? = null,
    @SerialName("gender_handling") val genderHandling: GenderHandling? = null,
    val prefixes: List<String>? = null,
    val suffixes: List<String>? = null,
)

/** Memory-template definition for backstory generation. */
@Serializable
data class MemoryTemplate(
    @SerialName("template_id") val templateId: String,
    @SerialName("template_type") val templateType: String,
    @SerialName("template_string") val templateString: String,
    @SerialName("context_type") val contextType: String? = null,
    @SerialName("context_id") val contextId: String? = null,
    val probability: Double? = null,
    val importance: Double? = null,
    val tags: List<String>? = null,
)

/** One option for a select/multiselect filterable field. */
@Serializable
data class FilterableFieldOption(
    val value: String,
    val label: String,
)

/** A field exposed for filtering in aggregate queries. */
@Serializable
data class FilterableField(
    val path: String,
    val type: FilterableFieldType,
    val label: String,
    val description: String? = null,
    val min: Double? = null,
    val max: Double? = null,
    val step: Double? = null,
    @SerialName("options_from") val optionsFrom: String? = null,
    val options: List<FilterableFieldOption>? = null,
)

/** One weighted option for a tier value. */
@Serializable
data class TierValueOption(
    val value: String,
    val label: String,
    val probability: Double? = null,
)

/** Value configuration for hierarchical tier selection. */
@Serializable
data class TierValuesConfig(
    @SerialName("tier_id") val tierId: String,
    val options: List<TierValueOption>,
    @SerialName("parent_tier_id") val parentTierId: String? = null,
    @SerialName("parent_value_mapping") val parentValueMapping: Map<String, List<String>>? = null,
)

/** Visual style template for avatar generation. */
@Serializable
data class StyleTemplate(
    val name: String,
    @SerialName("style_prompt") val stylePrompt: String,
    val description: String? = null,
    @SerialName("negative_prompt") val negativePrompt: String? = null,
)

/** Domain-level avatar image-generation settings. */
@Serializable
data class ImageGenerationConfig(
    @SerialName("default_style") val defaultStyle: String? = null,
    val styles: List<StyleTemplate>? = null,
    @SerialName("prompt_prefix") val promptPrefix: String? = null,
    @SerialName("prompt_suffix") val promptSuffix: String? = null,
)

/** Request body for `POST /v1/domains` (shaped to `DomainConfigCreate`). */
@Serializable
data class DomainConfigCreate(
    val name: String,
    @SerialName("display_name") val displayName: String,
    val tiers: List<TierDefinition>,
    @SerialName("personality_schema") val personalitySchema: PersonalitySchema,
    val version: String? = null,
    val description: String? = null,
    val archetypes: List<Archetype>? = null,
    @SerialName("name_patterns") val namePatterns: List<NamePattern>? = null,
    @SerialName("memory_templates") val memoryTemplates: List<MemoryTemplate>? = null,
    @SerialName("filterable_fields") val filterableFields: List<FilterableField>? = null,
    @SerialName("tier_values") val tierValues: List<TierValuesConfig>? = null,
    @SerialName("image_generation") val imageGeneration: ImageGenerationConfig? = null,
    @SerialName("behavioral_guidelines") val behavioralGuidelines: List<String>? = null,
    @SerialName("chat_guardrails") val chatGuardrails: List<String>? = null,
    @SerialName("chat_temperature") val chatTemperature: Double? = null,
    @SerialName("entity_noun") val entityNoun: String? = null,
    @SerialName("is_draft") val isDraft: Boolean? = null,
    val tags: List<String>? = null,
    val frameworks: List<String>? = null,
)

/** Response from `POST /v1/domains/generate` (the AI wizard). */
@Serializable
data class GeneratedConfigResponse(
    /** Generated configuration — ready to pass straight to [Domains.create]. */
    val config: DomainConfigCreate,
    /** Explanation of the generated config. */
    val explanation: String,
    /** Suggestions for improvement. */
    val suggestions: List<String>,
    /** Confidence score (0.0–1.0). */
    val confidence: Double,
)

class Domains(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun list(
        page: Int = 1,
        perPage: Int = 20,
        extras: Map<String, Any?> = emptyMap(),
    ): Page<JsonObject> {
        val params = mutableMapOf<String, Any?>("page" to page, "per_page" to perPage)
        params.putAll(extras.filterValues { it != null })
        val response = client.get("/v1/domains", params = params)
        val text = response.bodyAsText()
        val data = json.parseToJsonElement(text).jsonObject
        val items = data["items"]!!.jsonArray.map { it.jsonObject }
        return Page(
            items = items,
            total = data["total"]!!.jsonPrimitive.int,
            page = data["page"]!!.jsonPrimitive.int,
            perPage = data["per_page"]!!.jsonPrimitive.int,
            pages = data["pages"]!!.jsonPrimitive.int,
            client = client,
            method = "GET",
            path = "/v1/domains",
            params = params,
            deserializer = { it.jsonObject },
        )
    }

    suspend fun get(domainId: String): JsonObject {
        val response = client.get("/v1/domains/$domainId")
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /**
     * POST /v1/domains — create a domain from a full [DomainConfigCreate].
     *
     * Step 1 of the dev workflow. To build the config with the AI wizard instead
     * of by hand, call [generate] first and pass its `.config` here.
     */
    suspend fun create(config: DomainConfigCreate): JsonObject {
        val element = json.encodeToJsonElement(DomainConfigCreate.serializer(), config).jsonObject
        val body = element.mapValues { jsonElementToAny(it.value) }
        val response = client.post("/v1/domains", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /**
     * POST /v1/domains/generate — AI wizard (requires PRO tier).
     *
     * Generate a domain configuration from a natural-language [description] using
     * Claude. The returned [GeneratedConfigResponse.config] is a ready-to-use
     * [DomainConfigCreate] that can be passed straight to [create].
     *
     * @param context optional extra context for the generator (example personas,
     *   inspiration, etc.), keyed by name to a JSON value.
     * @param targetSections which sections to generate; defaults to `["all"]`.
     */
    suspend fun generate(
        description: String,
        context: Map<String, JsonElement> = emptyMap(),
        targetSections: List<String> = listOf("all"),
    ): GeneratedConfigResponse {
        val body = mutableMapOf<String, Any?>("description" to description)
        if (context.isNotEmpty()) {
            body["context"] = context.mapValues { jsonElementToAny(it.value) }
        }
        body["target_sections"] = targetSections
        val response = client.post("/v1/domains/generate", json = body)
        return json.decodeFromString(GeneratedConfigResponse.serializer(), response.bodyAsText())
    }

    suspend fun update(domainId: String, body: Map<String, Any?>): JsonObject {
        val response = client.put("/v1/domains/$domainId", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    suspend fun delete(domainId: String) {
        client.delete("/v1/domains/$domainId")
    }

    /** POST /v1/domains/validate — validate a domain config (`DomainConfigCreate`). */
    suspend fun validate(config: Map<String, Any?>): JsonObject {
        val response = client.post("/v1/domains/validate", json = config)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }
}

/**
 * Recursively unwrap a [JsonElement] (produced by serializing a typed config)
 * into native Kotlin values so the transport's `Map<String, Any?>` body
 * serializer re-encodes it faithfully. Without this, leaf [JsonPrimitive]s
 * would be re-stringified by the transport.
 */
private fun jsonElementToAny(element: JsonElement): Any? = when (element) {
    is JsonNull -> null
    is JsonObject -> element.mapValues { jsonElementToAny(it.value) }
    is JsonArray -> element.map { jsonElementToAny(it) }
    is JsonPrimitive -> when {
        element.isString -> element.content
        element.booleanOrNull != null -> element.booleanOrNull
        element.longOrNull != null -> element.longOrNull
        element.doubleOrNull != null -> element.doubleOrNull
        else -> element.content
    }
}
