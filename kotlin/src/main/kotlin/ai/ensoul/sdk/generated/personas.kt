/**
 * Generated models for personas resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */
package ai.ensoul.sdk.generated

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

/** Create persona request. Domain-agnostic: Requires domain and personality_data. */
@Serializable
data class PersonaCreate(
    val name: String,
    val domain: String,
    val archetype: String? = null,
    val region: String? = null,
    @SerialName("personality_data") val personalityData: JsonObject? = null,
    val age: Int? = null,
    val country: String? = null,
    val city: String? = null,
    val backstory: String? = null,
    @SerialName("core_values") val coreValues: List<String>? = null,
    @SerialName("communication_style") val communicationStyle: JsonObject? = null,
)

/** Update persona request (partial updates). Domain-agnostic: Updates flow through personality_data. */
@Serializable
data class PersonaUpdate(
    val name: String? = null,
    @SerialName("personality_data") val personalityData: JsonObject? = null,
    val age: Int? = null,
    val country: String? = null,
    val region: String? = null,
    val city: String? = null,
    val backstory: String? = null,
    @SerialName("core_values") val coreValues: List<String>? = null,
    @SerialName("communication_style") val communicationStyle: JsonObject? = null,
)

/** Batch create personas request. */
@Serializable
data class PersonaBatchCreate(
    val personas: List<PersonaCreate>,
    @SerialName("batch_id") val batchId: String? = null,
    val domain: String? = null,
)

/** Persona response with core information. Domain-agnostic: All personality data in personality_data field. */
@Serializable
data class PersonaResponse(
    val id: String,
    val name: String,
    val domain: String,
    @SerialName("personality_data") val personalityData: JsonObject? = null,
    @SerialName("avatar_url") val avatarUrl: String? = null,
    val archetype: String? = null,
    val age: Int? = null,
    val country: String? = null,
    val region: String? = null,
    val city: String? = null,
    @SerialName("batch_id") val batchId: String? = null,
    @SerialName("created_at") val createdAt: String,
)

/** Paginated list of personas. */
@Serializable
data class PersonaListResponse(
    val total: Int,
    val items: List<PersonaResponse>,
    val page: Int,
    @SerialName("per_page") val perPage: Int,
    val pages: Int,
)

/** Full personality vector response. Domain-agnostic: Returns personality_data in domain-specific format. */
@Serializable
data class PersonalityVectorResponse(
    @SerialName("persona_id") val personaId: String,
    val domain: String,
    @SerialName("personality_data") val personalityData: JsonObject? = null,
    @SerialName("communication_style") val communicationStyle: JsonObject? = null,
    @SerialName("core_values") val coreValues: List<String>? = null,
)

/** Batch operation response. */
@Serializable
data class PersonaBatchResponse(
    val created: Int,
    @SerialName("persona_ids") val personaIds: List<String>,
    @SerialName("batch_id") val batchId: String? = null,
    val domain: String? = null,
)

/** A filter option with ID, name, and count. */
@Serializable
data class FilterOption(
    val id: String,
    val name: String,
    val count: Int,
)

/** Available filter options for persona browsing. */
@Serializable
data class PersonaFiltersResponse(
    val domains: List<FilterOption>? = null,
    val regions: List<FilterOption>? = null,
    val archetypes: List<FilterOption>? = null,
    val countries: List<FilterOption>? = null,
    @SerialName("age_ranges") val ageRanges: List<FilterOption>? = null,
    @SerialName("total_personas") val totalPersonas: Int,
)
