package ai.ensoul.sdk

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe
import io.ktor.client.engine.mock.*
import io.ktor.http.*

class ClientTest : FunSpec({

    fun makeMockClient(handler: suspend MockRequestHandleScope.(io.ktor.client.request.HttpRequestData) -> io.ktor.client.request.HttpResponseData): EnsoulClient {
        val engine = MockEngine(handler)
        val config = ClientConfig(apiKey = "test-key")
        val httpClient = EnsoulHttpClient(config, engine)
        return EnsoulClient.withHttpClient(config, httpClient)
    }

    test("EnsoulClient initializes all resource namespaces") {
        val client = EnsoulClient(apiKey = "test-key")
        client.personas shouldNotBe null
        client.chat shouldNotBe null
        client.domains shouldNotBe null
        client.simulations shouldNotBe null
        client.aggregate shouldNotBe null
        client.memory shouldNotBe null
        client.sessions shouldNotBe null
        client.frameworks shouldNotBe null
        client.auth shouldNotBe null
        client.health shouldNotBe null
        client.info shouldNotBe null
        client.close()
    }

    test("EnsoulClient resolves apiKey from constructor") {
        val client = EnsoulClient(apiKey = "my-api-key")
        // The httpClient is internal — verify the client created without exception
        client shouldNotBe null
        client.close()
    }

    test("EnsoulClient.close() closes http client") {
        val client = makeMockClient { respondOk("{}") }
        // close should not throw
        client.close()
    }

    test("EnsoulClient VERSION is 0.1.0") {
        EnsoulClient.VERSION shouldBe "0.1.0"
    }
})
