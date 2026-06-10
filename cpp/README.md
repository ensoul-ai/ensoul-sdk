# Ensoul C++ SDK

Official C++ client library for the Ensoul personality simulation API.

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

    // Create a persona
    auto persona = client.personas().create({
        {"name", "Aria"},
        {"domain", "my_domain"}
    });

    std::cout << "Created: " << persona["id"] << "\n";

    // Send a chat message
    auto reply = client.chat().send(persona["id"], "Hello, how are you?");
    std::cout << reply["response"] << "\n";

    return 0;
}
```

The API key can also be set via the `ENSOUL_API_KEY` environment variable, in which case the constructor can be called with no arguments: `ensoul::EnsoulClient client;`.

## Streaming (SSE)

Chat and aggregate endpoints support server-sent events via a pull-iterator interface:

```cpp
auto stream = client.chat().stream_sse(persona_id, "Tell me a story.");

for (auto event = stream.next(); event; event = stream.next()) {
    std::cout << event->data;
}
std::cout << "\n";
```

The `SseStream` object holds the connection open and yields one `SseEvent` per call to `next()`. It returns `std::nullopt` when the stream ends.

## Pagination

List endpoints return a `Page<T>` that supports automatic pagination via a callback:

```cpp
client.personas().list().for_each_item([](const nlohmann::json& persona) {
    std::cout << persona["id"] << " - " << persona["name"] << "\n";
});
```

To iterate manually or limit pages:

```cpp
auto page = client.personas().list({{"limit", 20}});
while (page) {
    for (auto& item : page->items) {
        process(item);
    }
    page = page->next_page();
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
    std::cerr << "Rate limited, retry after: " << e.retry_after_seconds() << "s\n";
} catch (const ensoul::AuthenticationError& e) {
    std::cerr << "Invalid credentials\n";
} catch (const ensoul::ApiError& e) {
    std::cerr << "API error " << e.status_code() << ": " << e.what() << "\n";
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
