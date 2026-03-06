# Ensoul Kotlin SDK

Official Kotlin SDK for the Ensoul personality simulation API.

## Installation

Add the dependency to your `build.gradle.kts`:

```kotlin
dependencies {
    implementation("ai.ensoul:ensoul-sdk:0.1.0")
}
```

## Quick Start

```kotlin
import ai.ensoul.sdk.*

suspend fun main() {
    // API key from constructor or ENSOUL_API_KEY environment variable
    EnsoulClient("your-api-key").use { client ->
        val persona = client.personas.get("persona-id")
        println("Name: ${persona.name}")

        val response = client.chat.send(persona.id, "Hello, who are you?")
        println("Reply: ${response.response}")
    }
}
```

Use the companion object factory for idiomatic construction:

```kotlin
val client = EnsoulClient(apiKey = "your-api-key")
// or with a bearer token
val client = EnsoulClient(bearerToken = "your-token")
```

`EnsoulClient` implements `Closeable`. Prefer `.use { }` to ensure the underlying
Ktor CIO engine is shut down when the block exits.

## Streaming

Chat responses and aggregate queries support server-sent event streaming via
`kotlinx-coroutines` `Flow`.

```kotlin
EnsoulClient().use { client ->
    val stream = client.chat.stream(personaId = "persona-id", message = "Tell me a story.")
    stream.events.collect { event ->
        print(event.chunk)
    }
}
```

Aggregate streaming works the same way:

```kotlin
val stream = client.aggregate.stream("What do people value most?")
stream.events.collect { event -> println(event.data) }
```

## Pagination

List endpoints return `Page<T>`, which exposes `.autoPagingFlow()` to iterate all
pages lazily as a `Flow`:

```kotlin
EnsoulClient().use { client ->
    client.personas.list()
        .autoPagingFlow()
        .collect { persona ->
            println("${persona.id}: ${persona.name}")
        }
}
```

Fetch a single page manually when you only need a slice:

```kotlin
val page = client.personas.list(perPage = 25)
println("Total: ${page.total}, items: ${page.items.size}")
```

## Error Handling

All errors descend from `EnsoulError`. Catch the specific subtype you care about or
handle `ApiError` for all server-returned errors.

```kotlin
import ai.ensoul.sdk.errors.*

try {
    val persona = client.personas.get("missing-id")
} catch (e: NotFoundError) {
    println("Persona not found: ${e.message}")
} catch (e: RateLimitError) {
    println("Rate limited — retry after ${e.retryAfter}s")
} catch (e: AuthenticationError) {
    println("Invalid or missing API key")
} catch (e: ApiError) {
    println("API error ${e.statusCode}: ${e.message}")
}
```

Error hierarchy:

```
EnsoulError
└── ApiError
    ├── AuthenticationError   (401)
    ├── AuthorizationError    (403)
    ├── NotFoundError         (404)
    ├── ConflictError         (409)
    ├── ValidationError       (422)
    ├── RateLimitError        (429)
    └── ServerError           (5xx)
```

## Configuration

The client reads two environment variables as defaults:

| Variable | Purpose |
|----------|---------|
| `ENSOUL_API_KEY` | API key (avoids passing `apiKey` in code) |
| `ENSOUL_BASE_URL` | API base URL (default: `https://api.ensoul.ai`) |

**Demo API** — the current hosted demo is available at:

```bash
export ENSOUL_BASE_URL="https://demo.ensoul-ai.com/api"
export ENSOUL_API_KEY="your-api-key"
```

With these set, `EnsoulClient()` connects to the demo with no constructor arguments.

You can also pass the base URL explicitly:

```kotlin
val client = EnsoulClient(apiKey = "ens_...", baseUrl = "https://demo.ensoul-ai.com/api")
```

## Authentication

**API key**:

```kotlin
val client = EnsoulClient(apiKey = "ek_live_...")
// or set ENSOUL_API_KEY in the environment
val client = EnsoulClient()
```

**Bearer token**:

```kotlin
val client = EnsoulClient(bearerToken = "eyJ...")
```

**OAuth2 token exchange**:

```kotlin
val token = client.auth.token(
    grantType = "client_credentials",
    clientId = "your-client-id",
    clientSecret = "your-client-secret"
)
val authedClient = EnsoulClient(bearerToken = token.accessToken)
```

## Resources

All resource namespaces are exposed as `val` properties on `EnsoulClient`:

| Property | Description |
|---|---|
| `personas` | CRUD, list (paginated), batch create, personality vectors |
| `chat` | Send messages, SSE streaming, conversation history |
| `domains` | Domain configuration management |
| `simulations` | Time-based evolution simulations |
| `aggregate` | Aggregate queries with streaming and differential privacy |
| `memory` | Memory management per persona |
| `sessions` | Hierarchical session orchestration |
| `frameworks` | Framework management |
| `auth` | OAuth2 token exchange (form-encoded), API key management |
| `health` | Health checks |
| `info` | Server configuration and version info |

## Requirements

- Kotlin 1.9+
- JVM 17+
- `ktor-client-cio` — HTTP transport (CIO engine)
- `kotlinx-serialization-json` — JSON serialization
- `kotlinx-coroutines-core` — suspend functions and `Flow`
