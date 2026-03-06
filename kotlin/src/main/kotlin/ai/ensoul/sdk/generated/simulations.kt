/**
 * Generated models for simulations resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */
package ai.ensoul.sdk.generated

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonObject

/** Full simulation detail. */
@Serializable
data class SimulationDetailResponse(
    val id: String,
    val name: String,
    @SerialName("domain_id") val domainId: String,
    val description: String? = null,
    val status: SimulationStatus,
    val config: JsonObject? = null,
    @SerialName("participant_count") val participantCount: Int? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("updated_at") val updatedAt: String? = null,
)

/** Weights for the interaction scheduler's pair selection algorithm (stub). */
@Serializable
data class SchedulerWeights(
    val recency: Double = 1.0,
    val affinity: Double = 1.0,
    val diversity: Double = 1.0,
)

/** A persona participant in a simulation (stub). */
@Serializable
data class ParticipantResponse(
    @SerialName("persona_id") val personaId: String,
    @SerialName("joined_at") val joinedAt: String? = null,
    val status: String? = null,
)

/** Summary simulation item for list responses (stub). */
@Serializable
data class SimulationSimulationResponse(
    val id: String,
    val name: String,
    @SerialName("domain_id") val domainId: String,
    val status: SimulationStatus,
    @SerialName("current_tick") val currentTick: Int = 0,
    @SerialName("created_at") val createdAt: String,
    @SerialName("updated_at") val updatedAt: String,
)
