package ai.ensoul.sdk

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe

class ConfigTest : FunSpec({

    test("default config values") {
        val config = ClientConfig()
        config.baseUrl shouldBe DEFAULT_BASE_URL
        config.apiKey shouldBe null
        config.bearerToken shouldBe null
        config.timeout shouldBe DEFAULT_TIMEOUT
        config.maxRetries shouldBe DEFAULT_MAX_RETRIES
        config.customHeaders shouldBe emptyMap()
    }

    test("apiUrl construction — baseUrl + /v1") {
        val config = ClientConfig(baseUrl = "https://api.ensoul-ai.com")
        config.apiUrl shouldBe "https://api.ensoul-ai.com/v1"
    }

    test("apiUrl strips trailing slash") {
        val config = ClientConfig(baseUrl = "https://api.ensoul-ai.com/")
        config.apiUrl shouldBe "https://api.ensoul-ai.com/v1"
    }

    test("custom config values") {
        val config = ClientConfig(
            baseUrl = "https://custom.host",
            apiKey = "test-key",
            bearerToken = "bearer-abc",
            timeout = 60_000L,
            maxRetries = 5,
            customHeaders = mapOf("X-Custom" to "value"),
        )
        config.baseUrl shouldBe "https://custom.host"
        config.apiKey shouldBe "test-key"
        config.bearerToken shouldBe "bearer-abc"
        config.timeout shouldBe 60_000L
        config.maxRetries shouldBe 5
        config.customHeaders shouldBe mapOf("X-Custom" to "value")
    }
})
