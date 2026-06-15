# Ensoul Python SDK

Python client library for the Ensoul personality simulation API.

## Installation

**Requires Python 3.11 or newer.** On Python 3.9 or 3.10, `pip install ensoul` fails with no compatible version. Check your version with `python --version` and upgrade if needed.

```
pip install ensoul
```

## Quick Start

```python
from ensoul import Ensoul

client = Ensoul(api_key="your-api-key")

# Create a persona
persona = client.personas.create(name="Alex", domain="my_domain")

# Send a chat message
response = client.chat.send(persona.id, "Hello, who are you?")
print(response.response)
```

The API key can also be set via the `ENSOUL_API_KEY` environment variable, in which case no `api_key` argument is needed.

The client supports context managers for automatic cleanup:

```python
with Ensoul(api_key="your-api-key") as client:
    persona = client.personas.get("persona-id")
```

## Async Usage

```python
import asyncio
from ensoul import AsyncEnsoul

async def main():
    async with AsyncEnsoul(api_key="your-api-key") as client:
        persona = await client.personas.create(name="Jordan", domain="my_domain")
        response = await client.chat.send(persona.id, "Tell me about yourself.")
        print(response.response)

asyncio.run(main())
```

## Streaming

Chat supports server-sent events (SSE) for streaming responses. Each event's
`data` is a JSON object. The delta text lives in the **`chunk`** field:

| Field | Type | Notes |
|-------|------|-------|
| `chunk` | `str` | The text delta. Append these to build the full reply. |
| `conversation_id` | `str` | Stable across the stream. Pass it back to continue the conversation. |
| `chunk_index` | `int` | 0-based position of this chunk in the stream. |
| `is_final` | `bool` | `True` on the last event. Its `chunk` is empty (`""`). |
| `token_usage` | `dict \| None` | Present only on the final event. |

Use `parse_chat_event` to turn each raw `SSEEvent` into a typed `ChatStreamEvent`,
then print `chunk` as it arrives:

```python
from ensoul import Ensoul
from ensoul.streaming import parse_chat_event

client = Ensoul(api_key="your-api-key")

stream = client.chat.stream("persona-id", "What do you think about music?")
try:
    for event in stream.events():
        parsed = parse_chat_event(event)
        print(parsed.chunk, end="", flush=True)  # print text as it streams
        if parsed.is_final:
            print()  # newline after the stream completes
            if parsed.token_usage:
                print(f"tokens: {parsed.token_usage}")
finally:
    stream.close()
```

The async client returns an `AsyncSSEStream` that works the same way with `async for`:

```python
import asyncio
from ensoul import AsyncEnsoul
from ensoul.streaming import parse_chat_event

async def main() -> None:
    client = AsyncEnsoul(api_key="your-api-key")
    stream = await client.chat.stream("persona-id", "What do you think about music?")
    async for event in stream:
        parsed = parse_chat_event(event)
        print(parsed.chunk, end="", flush=True)
        if parsed.is_final:
            print()

asyncio.run(main())
```

## Pagination

List endpoints return a `SyncPage` (or `AsyncPage`) object. Use `.auto_paging_iter()` to iterate through all pages automatically:

```python
# Manual page access
page = client.personas.list(per_page=50)
print(page.items)    # current page items
print(page.total)    # total count across all pages

# Automatic pagination — fetches subsequent pages as needed
for persona in client.personas.list().auto_paging_iter():
    print(persona.name)
```

Async pagination works the same way with `async for`.

## Error Handling

All SDK errors inherit from `EnsoulError`. HTTP errors are subclasses of `APIError`:

```python
from ensoul.errors import (
    EnsoulError,
    APIError,
    AuthenticationError,
    AuthorizationError,
    NotFoundError,
    RateLimitError,
    ValidationError,
    ConflictError,
    ServerError,
)

try:
    persona = client.personas.get("nonexistent-id")
except NotFoundError:
    print("Persona not found")
except AuthenticationError:
    print("Invalid or missing API key")
except RateLimitError:
    print("Rate limit exceeded — back off and retry")
except APIError as e:
    print(f"API error {e.status_code}: {e.message}")
```

## Configuration

The client reads two environment variables as defaults:

| Variable | Purpose |
|----------|---------|
| `ENSOUL_API_KEY` | API key (avoids passing `api_key=` in code) |
| `ENSOUL_BASE_URL` | API base URL (default: `https://api.ensoul-ai.com`) |

**Demo API** — the current hosted demo is available at:

```bash
export ENSOUL_BASE_URL="https://api.demo.ensoul-ai.com"
export ENSOUL_API_KEY="your-api-key"
```

With these set, `Ensoul()` connects to the demo with no constructor arguments.

You can also pass the base URL explicitly:

```python
client = Ensoul(api_key="ens_...", base_url="https://api.demo.ensoul-ai.com")
```

## Authentication

**API key** (recommended):

```python
client = Ensoul(api_key="ens_...")
# or set ENSOUL_API_KEY in the environment
client = Ensoul()
```

**Bearer token**:

```python
client = Ensoul(bearer_token="eyJ...")
```

**OAuth2 token exchange** (password flow, form-encoded):

```python
token_response = client.auth.token(
    username="you@example.com",
    password="your-password",
)
authed_client = Ensoul(bearer_token=token_response.access_token)
```

## Resources

| Namespace | Description |
|-----------|-------------|
| `client.personas` | CRUD, list (paginated), batch create, personality vectors, filters, connections |
| `client.chat` | Send messages, streaming SSE, conversation history |
| `client.domains` | Domain configuration management |
| `client.simulations` | Time-based evolution simulations |
| `client.aggregate` | Aggregate queries with streaming results |
| `client.memory` | Persona memory management |
| `client.sessions` | Hierarchical session orchestration |
| `client.frameworks` | Framework management |
| `client.auth` | OAuth2 token exchange and API key management |
| `client.health` | Service health checks |
| `client.info` | Server info and configuration |

## Requirements

- Python 3.11+
- [`httpx`](https://www.python-httpx.org/) — HTTP transport
- [`pydantic`](https://docs.pydantic.dev/) 2.x — request and response models
