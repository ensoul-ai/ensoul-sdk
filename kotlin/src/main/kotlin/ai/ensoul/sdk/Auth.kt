package ai.ensoul.sdk

/** Authentication strategies that produce HTTP request headers. */
interface AuthProvider {
    fun authHeaders(): Map<String, String>
}

/** API key authentication via X-API-Key header. */
class APIKeyAuth(private val apiKey: String) : AuthProvider {
    override fun authHeaders(): Map<String, String> = mapOf("X-API-Key" to apiKey)
}

/**
 * OAuth2 JWT authentication with token state tracking.
 *
 * The actual refresh HTTP call is performed by the HTTP client layer, not here.
 * This class tracks token state and expiry only.
 */
class BearerAuth(
    var accessToken: String,
    var refreshToken: String? = null,
    var expiresAt: Double? = null,  // Unix timestamp
) : AuthProvider {

    override fun authHeaders(): Map<String, String> =
        mapOf("Authorization" to "Bearer $accessToken")

    /** True if the access token has already expired. */
    fun isExpired(): Boolean {
        val exp = expiresAt ?: return false
        return currentTimeSeconds() >= exp
    }

    /** True if the token expires within 60 seconds (or is already expired). */
    fun needsRefresh(): Boolean {
        val exp = expiresAt ?: return false
        return currentTimeSeconds() >= (exp - REFRESH_BUFFER_SECONDS)
    }

    private fun currentTimeSeconds(): Double = System.currentTimeMillis() / 1000.0

    companion object {
        private const val REFRESH_BUFFER_SECONDS = 60.0
    }
}
