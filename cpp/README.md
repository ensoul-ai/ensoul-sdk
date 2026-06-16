# Ensoul C++ SDK

Official C++ SDK for the [Ensoul](https://ensoul-ai.com) API. Build AI NPCs and personas with memory and personality that evolve through real conversation. Scale to thousands of personas, and run simulations where they grow and change over time.

## Build

```bash
mkdir build && cd build
cmake ..
cmake --build .
```

To build and run tests:

```bash
cmake -DBUILD_TESTING=ON ..
cmake --build .
ctest --output-on-failure
```

All dependencies (cpp-httplib v0.15.3, nlohmann/json v3.11.3, Catch2 v3.5.2) are fetched automatically via CMake FetchContent. No manual installation required.

For HTTPS support, install OpenSSL and configure CMake:

```bash
cmake -DCPPHTTPLIB_OPENSSL_SUPPORT=ON ..
```

## Quick Start

```cpp
#include <ensoul/ensoul.hpp>
#include <iostream>

int main() {
    ensoul::EnsoulClient client("your-api-key");

    // Create a persona (returns a typed PersonaResponse)
    auto persona = client.personas().create("Aria", "my_domain");

    std::cout << "Created: " << persona.id << "\n";

    // Send a chat message (returns a typed ChatResponse)
    auto reply = client.chat().send(persona.id, "Hello, how are you?");
    std::cout << reply.response << "\n";

    return 0;
}
```

The API key can also be set via the `ENSOUL_API_KEY` environment variable, in which case the constructor can be called with no arguments: `ensoul::EnsoulClient client;`.

## Streaming (SSE)

Chat and aggregate endpoints support server-sent events via a pull-iterator interface:

```cpp
auto stream = client.chat().stream(persona_id, "Tell me a story.");

ensoul::SseEvent event;
while (stream.next_event(event)) {
    std::cout << event.data;
}
std::cout << "\n";
```

`next_event()` fills the passed `SseEvent` and returns `true` for each event, or `false` once the stream is exhausted. Use `ensoul::parse_chat_event(event)` to turn a raw `SseEvent` into a typed `ChatStreamEvent`.

## Pagination

List endpoints return a `Page<T>` that supports automatic pagination via a callback:

```cpp
client.personas().list().for_each_item([](const ensoul::PersonaResponse& persona) {
    std::cout << persona.id << " - " << persona.name << "\n";
});
```

To iterate manually or limit pages (`list` takes `page` and `per_page`):

```cpp
auto page = client.personas().list(1, 20);
while (true) {
    for (const auto& persona : page.items) {
        std::cout << persona.id << "\n";
    }
    if (!page.has_next_page()) break;
    page = page.next_page();
}
```

## Error Handling

All errors derive from `ensoul::EnsoulError`. HTTP error codes map to typed subclasses:

```cpp
#include <ensoul/ensoul.hpp>

try {
    auto persona = client.personas().get("nonexistent-id");
} catch (const ensoul::NotFoundError& e) {
    std::cerr << "Not found: " << e.what() << "\n";
} catch (const ensoul::RateLimitError& e) {
    std::cerr << "Rate limited, retry after: " << e.retry_after << "s\n";
} catch (const ensoul::AuthenticationError& e) {
    std::cerr << "Invalid credentials\n";
} catch (const ensoul::ApiError& e) {
    std::cerr << "API error " << e.status_code << ": " << e.what() << "\n";
} catch (const ensoul::EnsoulError& e) {
    std::cerr << "SDK error: " << e.what() << "\n";
}
```

Error hierarchy:

```
EnsoulError
  ApiError
    AuthenticationError   (401)
    AuthorizationError    (403)
    NotFoundError         (404)
    ConflictError         (409)
    ValidationError       (422)
    RateLimitError        (429)
    ServerError           (5xx)
```

## Configuration

The client reads two environment variables as defaults:

| Variable | Purpose |
|----------|---------|
| `ENSOUL_API_KEY` | API key (avoids passing it in the constructor) |
| `ENSOUL_BASE_URL` | API base URL (default: `https://api.ensoul-ai.com`) |

**Demo API** — the current hosted demo is available at:

```bash
export ENSOUL_BASE_URL="https://api.demo.ensoul-ai.com"
export ENSOUL_API_KEY="your-api-key"
```

With these set, `EnsoulClient client;` connects to the demo with no constructor arguments.

You can also pass the base URL explicitly:

```cpp
ensoul::EnsoulClient client("ens_...", "https://api.demo.ensoul-ai.com");
```

## Authentication

**API key**:

```cpp
ensoul::EnsoulClient client("sk-your-api-key");
// or set ENSOUL_API_KEY in the environment
```

**Bearer token**:

```cpp
ensoul::EnsoulClient client("", "https://api.demo.ensoul-ai.com", "your-oauth-token");
```

**OAuth2 token exchange**:

```cpp
auto token = client.auth().token(
    "you@example.com",  // username
    "your-password"
);
// token.access_token, token.expires_in
```

## Resources

| Accessor | Description |
|---|---|
| `client.personas()` | CRUD, list (paginated), batch create |
| `client.chat()` | Send messages, SSE streaming, conversation history |
| `client.domains()` | Domain configuration management |
| `client.simulations()` | Time-based evolution simulations |
| `client.aggregate()` | Aggregate queries with optional SSE streaming |
| `client.memory()` | Persona memory management |
| `client.sessions()` | Hierarchical session orchestration |
| `client.frameworks()` | Framework management |
| `client.auth()` | OAuth2 token exchange (form-encoded) |
| `client.health()` | Health checks (not versioned under /v1/) |
| `client.info()` | Server configuration and capabilities |

## Requirements

- CMake 3.14+
- C++17 compiler (GCC 7+, Clang 5+, MSVC 2017+)
- OpenSSL (optional, required for HTTPS endpoints)
- Dependencies fetched automatically via CMake FetchContent:
  - [cpp-httplib](https://github.com/yhirose/cpp-httplib) v0.15.3
  - [nlohmann/json](https://github.com/nlohmann/json) v3.11.3
  - [Catch2](https://github.com/catchorg/Catch2) v3.5.2 (tests only)
