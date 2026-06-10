# Ensoul Swift SDK

Official Swift SDK for the Ensoul personality simulation API. Zero external dependencies — built on URLSession.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ensoul-ai/ensoul-sdk.git", from: "0.1.0"),
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "Ensoul", package: "Ensoul"),
    ]),
]
```

## Quick Start

```swift
import Ensoul

// Initialize with an API key
let client = EnsoulClient(apiKey: "ens_...")

// Create a persona
let persona = try await client.personas.create(
    name: "Aria",
    domain: "my_domain"
)

// Send a chat message
let response = try await client.chat.send(
    personaId: persona.id,
    message: "Tell me about yourself."
)
print(response.response)
```

## Streaming

Chat and aggregate endpoints return an `SSEStream` that conforms to `AsyncSequence`:

```swift
let stream = try await client.chat.stream(
    personaId: persona.id,
    message: "Describe your earliest memory."
)

for try await event in stream {
    print(event.data, terminator: "")
}
```

Aggregate queries also stream results:

```swift
let stream = client.aggregate.stream("What does this population value?")

for try await event in stream {
    print(event.data)
}
```

## Pagination

List endpoints return `Page<T>`, which provides an `allItems()` async sequence that automatically fetches subsequent pages:

```swift
// Iterate all personas without manual cursor management
for try await persona in try await client.personas.list().allItems() {
    print(persona.name)
}

// Manual page control
var page = try await client.personas.list(perPage: 50)
while page.hasNextPage {
    page = try await page.nextPage()
    process(page.items)
}
```

## Error Handling

All methods are `async throws`. Errors are typed under `EnsoulError`:

```swift
do {
    let persona = try await client.personas.get(id: "uuid")
} catch EnsoulError.notFoundError(let detail) {
    print("Persona not found: \(detail.message)")
} catch EnsoulError.rateLimitError(let detail) {
    print("Rate limited — retry after \(detail.retryAfter ?? 60)s")
} catch EnsoulError.validationError(let detail) {
    print("Validation failed: \(detail.message)")
} catch EnsoulError.authenticationError {
    print("Invalid or missing API key")
} catch EnsoulError.serverError(let detail) {
    print("Server error: \(detail.message)")
}
```

Error cases: `.apiError`, `.authenticationError`, `.authorizationError`, `.notFoundError`, `.rateLimitError`, `.validationError`, `.conflictError`, `.serverError`.

## Configuration

The client reads two environment variables as defaults:

| Variable | Purpose |
|----------|---------|
| `ENSOUL_API_KEY` | API key (avoids passing `apiKey:` in code) |
| `ENSOUL_BASE_URL` | API base URL (default: `https://api.ensoul-ai.com`) |

**Demo API** — the current hosted demo is available at:

```bash
export ENSOUL_BASE_URL="https://api.demo.ensoul-ai.com"
export ENSOUL_API_KEY="your-api-key"
```

With these set, `EnsoulClient()` connects to the demo with no constructor arguments.

You can also pass the base URL explicitly:

```swift
let client = EnsoulClient(apiKey: "ens_...", baseURL: "https://api.demo.ensoul-ai.com")
```

## Authentication

**API key**:

```swift
let client = EnsoulClient(apiKey: "ens_...")
// or: EnsoulClient() reads ENSOUL_API_KEY automatically
```

**Bearer token**:

```swift
let client = EnsoulClient(bearerToken: "eyJ...")
```

**OAuth2 token exchange** (password flow, form-encoded):

```swift
let token = try await client.auth.token(
    username: "you@example.com",
    password: "your-password"
)
let authedClient = EnsoulClient(bearerToken: token.accessToken)
```

## Resources

All resources are accessed as `let` properties on `EnsoulClient`:

| Property | Description |
|----------|-------------|
| `client.personas` | CRUD, list (paginated), batch create, personality vectors |
| `client.chat` | Send messages, streaming responses, conversation history |
| `client.domains` | Domain configuration management |
| `client.simulations` | Time-based evolution simulations |
| `client.aggregate` | Aggregate queries with differential privacy, streaming |
| `client.memory` | Persona memory read and write operations |
| `client.sessions` | Hierarchical session orchestration |
| `client.frameworks` | Framework management |
| `client.auth` | OAuth2 token exchange (form-encoded) |
| `client.health` | API health checks |
| `client.info` | Server configuration and capability info |

## Platforms and Requirements

| Requirement | Version |
|-------------|---------|
| Swift | 5.9+ |
| iOS | 15+ |
| macOS | 12+ |
| Dependencies | None (URLSession only) |
