package ai.ensoul.sdk

import ai.ensoul.sdk.resources.*
import java.io.Closeable

class EnsoulClient private constructor(
    private val config: ClientConfig,
    internal val httpClient: EnsoulHttpClient,
) : Closeable {

    val personas: Personas = Personas(httpClient)
    val chat: Chat = Chat(httpClient)
    val domains: Domains = Domains(httpClient)
    val simulations: Simulations = Simulations(httpClient)
    val aggregate: Aggregate = Aggregate(httpClient)
    val memory: Memory = Memory(httpClient)
    val sessions: Sessions = Sessions(httpClient)
    val frameworks: Frameworks = Frameworks(httpClient)
    val auth: AuthResource = AuthResource(httpClient)
    val health: Health = Health(httpClient)
    val info: Info = Info(httpClient)

    override fun close() {
        httpClient.close()
    }

    companion object {
        const val VERSION = "0.1.0"

        operator fun invoke(
            apiKey: String? = null,
            baseUrl: String? = null,
            bearerToken: String? = null,
            timeout: Long = DEFAULT_TIMEOUT,
            maxRetries: Int = DEFAULT_MAX_RETRIES,
            customHeaders: Map<String, String> = emptyMap(),
        ): EnsoulClient {
            val resolvedApiKey = apiKey ?: System.getenv("ENSOUL_API_KEY")
            val resolvedBaseUrl = baseUrl ?: System.getenv("ENSOUL_BASE_URL") ?: DEFAULT_BASE_URL
            val config = ClientConfig(
                baseUrl = resolvedBaseUrl,
                apiKey = resolvedApiKey,
                bearerToken = bearerToken,
                timeout = timeout,
                maxRetries = maxRetries,
                customHeaders = customHeaders,
            )
            return EnsoulClient(config, EnsoulHttpClient(config))
        }

        internal fun withHttpClient(
            config: ClientConfig,
            httpClient: EnsoulHttpClient,
        ): EnsoulClient = EnsoulClient(config, httpClient)
    }
}
