package ai.ensoul.sdk

const val DEFAULT_BASE_URL = "https://api.ensoul-ai.com"
const val DEFAULT_TIMEOUT = 30_000L  // milliseconds for Ktor
const val DEFAULT_MAX_RETRIES = 2
const val API_VERSION = "v1"

data class ClientConfig(
    val baseUrl: String = DEFAULT_BASE_URL,
    val apiKey: String? = null,
    val bearerToken: String? = null,
    val timeout: Long = DEFAULT_TIMEOUT,
    val maxRetries: Int = DEFAULT_MAX_RETRIES,
    val customHeaders: Map<String, String> = emptyMap(),
) {
    val apiUrl: String get() = "${baseUrl.trimEnd('/')}/$API_VERSION"
}
