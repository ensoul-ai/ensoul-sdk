# Ensoul Unity SDK

Official Unity SDK for the Ensoul API — domain-agnostic personality simulation at scale.

## Installation

Add to your project's `Packages/manifest.json`. Newtonsoft.Json is required and must also be present.

```json
{
  "dependencies": {
    "com.ensoul.sdk": "https://github.com/ensoul-ai/ensoul-sdk.git?path=unity",
    "com.unity.nuget.newtonsoft-json": "3.2.1"
  }
}
```

## Quick Start

```csharp
using Ensoul;
using Ensoul.Resources;

// Construct with an API key directly
using var client = new EnsoulClient("your-api-key");

// Or use EnsoulConfig for full options
using var client = new EnsoulClient(new EnsoulConfig(apiKey: "your-api-key"));

// Create a persona
var persona = await client.Personas.CreateAsync("Aria", "my_domain");

// Send a chat message
var reply = await client.Chat.SendAsync(persona.Id, "Hello, how are you?");
Debug.Log(reply.Response);
```

If `ENSOUL_API_KEY` is set as an environment variable, the client picks it up automatically when no key is passed to the constructor.

## Streaming

Chat and aggregate endpoints support server-sent events (SSE). Iterate the stream with `await foreach`:

```csharp
var stream = await client.Chat.StreamAsync(persona.Id, "Tell me a story.");

await foreach (var evt in stream)
{
    Debug.Log(evt.Data);
}
```

## Pagination

List endpoints return a `Page<T>` with cursor-based pagination. Iterate all pages lazily:

```csharp
var firstPage = await client.Personas.ListAsync();

// Pull all pages as an async sequence
await foreach (var persona in firstPage.GetAllPagesAsync())
{
    Debug.Log(persona.Name);
}
```

## Error Handling

All errors derive from `EnsoulException`. Catch specific subtypes for fine-grained handling:

```csharp
try
{
    var persona = await client.Personas.GetAsync("nonexistent-id");
}
catch (NotFoundException ex)
{
    Debug.LogWarning($"Not found: {ex.Message}");
}
catch (RateLimitException ex)
{
    Debug.LogWarning($"Rate limited. Retry after: {ex.RetryAfter}");
}
catch (AuthenticationException ex)
{
    Debug.LogError($"Auth failed: {ex.Message}");
}
catch (ApiException ex)
{
    Debug.LogError($"API error {ex.StatusCode}: {ex.Message}");
}
```

Exception hierarchy:

- `EnsoulException` (base)
  - `ApiException`
    - `AuthenticationException` — 401
    - `AuthorizationException` — 403
    - `NotFoundException` — 404
    - `ValidationException` — 422
    - `ConflictException` — 409
    - `RateLimitException` — 429
    - `ServerException` — 5xx

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

With these set, `new EnsoulClient(new EnsoulConfig())` connects to the demo with no explicit arguments.

You can also pass the base URL explicitly:

```csharp
using var client = new EnsoulClient(new EnsoulConfig(
    apiKey: "ens_...",
    baseUrl: "https://api.demo.ensoul-ai.com"
));
```

## Authentication

**API key**:

```csharp
using var client = new EnsoulClient("your-api-key");
// or set ENSOUL_API_KEY in the environment
using var client = new EnsoulClient(new EnsoulConfig());
```

**Bearer token**:

```csharp
using var client = new EnsoulClient(new EnsoulConfig(bearerToken: "eyJ..."));
```

**OAuth2 token exchange** (password flow, form-encoded):

```csharp
var token = await client.Auth.TokenAsync(
    username: "you@example.com",
    password: "your-password"
);
using var authedClient = new EnsoulClient(new EnsoulConfig(bearerToken: token.AccessToken));
```

## Resources

All resources are exposed as properties on `EnsoulClient` (namespace `Ensoul.Resources`).

| Property | Description |
|---|---|
| `client.Personas` | CRUD, list (paginated), batch create |
| `client.Chat` | Send messages, streaming, conversation history |
| `client.Domains` | Domain configuration management |
| `client.Simulations` | Time-based evolution simulations |
| `client.Aggregate` | Aggregate queries with streaming |
| `client.Memory` | Memory management per persona |
| `client.Sessions` | Hierarchical session orchestration |
| `client.Frameworks` | Framework management |
| `client.Auth` | OAuth2 token exchange (form-encoded) |
| `client.Health` | Health checks |
| `client.Info` | Server configuration and version |

## Requirements

- Unity 2021.3 or later
- .NET Standard 2.1 scripting backend
- `Newtonsoft.Json` via UPM (`com.unity.nuget.newtonsoft-json` 3.2.1+)
- `System.Net.Http` (included with .NET Standard 2.1)
