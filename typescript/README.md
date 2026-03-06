# Ensoul TypeScript SDK

Official TypeScript client for the Ensoul personality simulation API.

## Installation

```bash
npm install @ensoul/sdk
```

## Quick Start

```typescript
import { Ensoul } from "@ensoul/sdk";

const client = new Ensoul({ apiKey: process.env.ENSOUL_API_KEY });

// Fetch a single persona
const persona = await client.personas.get("persona_abc123");
console.log(persona.name, persona.personality);

// Send a chat message
const reply = await client.chat.send("persona_abc123", "What do you think about this?");
console.log(reply.response);
```

## Streaming

Chat and aggregate endpoints support server-sent events. The stream is an async iterable.

```typescript
const stream = await client.chat.stream("persona_abc123", "Tell me a story.");

for await (const event of stream.events()) {
  const data = JSON.parse(event.data);
  if (!data.is_final) {
    process.stdout.write(data.chunk);
  }
}
```

## Pagination

List endpoints return a `Page<T>` object that implements `Symbol.asyncIterator`, so you can
iterate over all records without manual cursor management.

```typescript
// Fetch a page
const page = await client.personas.list({ perPage: 50 });
console.log(page.items, page.total);

// Auto-paginate through all results
for await (const persona of page.autoPagingIter()) {
  console.log(persona.id, persona.name);
}
```

## Error Handling

All errors extend `EnsoulError`. Import the specific subclasses you need.

```typescript
import { Ensoul, AuthenticationError, RateLimitError, NotFoundError } from "@ensoul/sdk";

try {
  const persona = await client.personas.get("missing_id");
} catch (err) {
  if (err instanceof NotFoundError) {
    console.error("Persona not found:", err.message);
  } else if (err instanceof RateLimitError) {
    console.error("Rate limited. Retry after:", err.retryAfter);
  } else if (err instanceof AuthenticationError) {
    console.error("Invalid or missing API key.");
  } else {
    throw err;
  }
}
```

Error hierarchy:

```
EnsoulError
  APIError
    AuthenticationError   (401)
    AuthorizationError    (403)
    NotFoundError         (404)
    ValidationError       (422)
    ConflictError         (409)
    RateLimitError        (429)
    ServerError           (5xx)
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

With these set, `new Ensoul()` connects to the demo with no constructor options.

You can also pass the base URL explicitly:

```typescript
const client = new Ensoul({ apiKey: "ens_...", baseUrl: "https://demo.ensoul-ai.com/api" });
```

## Authentication

**API key**:

```typescript
const client = new Ensoul({ apiKey: "ens_live_..." });
// or rely on process.env.ENSOUL_API_KEY
const client = new Ensoul();
```

**Bearer token**:

```typescript
const client = new Ensoul({ bearerToken: "eyJ..." });
```

**OAuth2 client credentials**:

```typescript
const token = await client.auth.token({
  grantType: "client_credentials",
  clientId: "my_client",
  clientSecret: process.env.CLIENT_SECRET,
});
```

## Resources

| Namespace | Description |
|-----------|-------------|
| `client.personas` | CRUD, list (paginated), batch create, personality vectors |
| `client.chat` | Send messages, streaming SSE, conversation history |
| `client.domains` | Domain configuration management |
| `client.simulations` | Time-based evolution simulations |
| `client.aggregate` | Aggregate queries with streaming |
| `client.memory` | Memory management per persona |
| `client.sessions` | Hierarchical session orchestration |
| `client.frameworks` | Framework management |
| `client.auth` | OAuth2 token exchange, API key management |
| `client.health` | Health checks |
| `client.info` | Server configuration and metadata |

## Requirements

- Node.js 18+ (native `fetch`, no runtime dependencies)
- TypeScript 5.7+ (for full type inference)
