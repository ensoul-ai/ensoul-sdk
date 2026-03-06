/**
 * Generated models for auth resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */
package ai.ensoul.sdk.generated

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/** JWT token response. */
@Serializable
data class TokenResponse(
    @SerialName("access_token") val accessToken: String,
    @SerialName("token_type") val tokenType: String = "bearer",
    @SerialName("expires_in") val expiresIn: Int,
    @SerialName("refresh_token") val refreshToken: String? = null,
    val scope: String? = null,
)

/** Refresh token request. */
@Serializable
data class RefreshTokenRequest(
    @SerialName("refresh_token") val refreshToken: String,
    @SerialName("grant_type") val grantType: String = "refresh_token",
)

/** Create API key request. */
@Serializable
data class APIKeyRequest(
    val name: String,
    @SerialName("expires_days") val expiresDays: Int? = 365,
    val scopes: List<String>? = null,
)

/** API key response (masked for security). */
@Serializable
data class APIKeyResponse(
    @SerialName("key_id") val keyId: String,
    val name: String,
    @SerialName("key_preview") val keyPreview: String,
    @SerialName("full_key") val fullKey: String? = null,
    val scopes: List<String>? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("expires_at") val expiresAt: String,
    @SerialName("last_used_at") val lastUsedAt: String? = null,
    @SerialName("is_active") val isActive: Boolean = true,
)

/** Current authenticated user information. */
@Serializable
data class UserResponse(
    @SerialName("consumer_id") val consumerId: String,
    val username: String,
    val email: String? = null,
    @SerialName("access_tier") val accessTier: String,
    val permissions: List<String>? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("is_active") val isActive: Boolean = true,
)
