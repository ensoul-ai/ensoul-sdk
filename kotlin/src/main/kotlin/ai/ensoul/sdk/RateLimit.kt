package ai.ensoul.sdk

/** Parsed rate limit state from API response headers. */
data class RateLimitInfo(
    val limit: Int,
    val remaining: Int,
    val reset: Double,       // Unix timestamp when the window resets
    val retryAfter: Double? = null,  // seconds to wait, only on 429
) {
    companion object {
        /**
         * Parse rate limit headers from response headers.
         * Returns null if the required headers are not present.
         */
        fun fromHeaders(headers: Map<String, List<String>>): RateLimitInfo? {
            fun header(name: String): String? =
                headers[name]?.firstOrNull() ?: headers[name.lowercase()]?.firstOrNull()

            val limitRaw = header("X-RateLimit-Limit") ?: return null
            val remainingRaw = header("X-RateLimit-Remaining") ?: return null
            val resetRaw = header("X-RateLimit-Reset") ?: return null

            val limit = limitRaw.toIntOrNull() ?: return null
            val remaining = remainingRaw.toIntOrNull() ?: return null
            val reset = resetRaw.toDoubleOrNull() ?: return null

            val retryAfter = header("Retry-After")?.toDoubleOrNull()

            return RateLimitInfo(limit = limit, remaining = remaining, reset = reset, retryAfter = retryAfter)
        }
    }
}

/** Tracks rate limit state across requests. */
class RateLimitTracker {
    var info: RateLimitInfo? = null
        private set

    /** Update tracked state from a response's rate limit headers. */
    fun update(headers: Map<String, List<String>>) {
        val parsed = RateLimitInfo.fromHeaders(headers)
        if (parsed != null) {
            info = parsed
        }
    }

    /**
     * Returns (shouldWait, secondsToWait).
     * Returns true if remaining == 0 and the reset timestamp is in the future.
     */
    fun shouldWait(): Pair<Boolean, Double> {
        val current = info ?: return Pair(false, 0.0)

        if (current.remaining > 0) return Pair(false, 0.0)

        val now = System.currentTimeMillis() / 1000.0
        val secondsUntilReset = current.reset - now
        if (secondsUntilReset <= 0.0) return Pair(false, 0.0)

        return Pair(true, secondsUntilReset)
    }
}
