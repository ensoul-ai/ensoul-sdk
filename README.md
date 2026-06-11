# Ensoul SDK

Official SDK suite for the [Ensoul](https://ensoul-ai.com) API, a domain-agnostic personality simulation framework for creating authentic, evolving synthetic populations at scale.

**Upgrading from 0.1.x?** 0.2.0 is a breaking release that realigns every SDK
with the live API. See [MIGRATION.md](MIGRATION.md).

## SDKs

| Language | Path | HTTP Library | Status |
|----------|------|-------------|--------|
| [Python](#python) | [`python/`](python/) | httpx | Stable |
| [TypeScript](#typescript) | [`typescript/`](typescript/) | native fetch | Stable |
| [Kotlin](#kotlin) | [`kotlin/`](kotlin/) | Ktor CIO | Stable |
| [Swift](#swift) | [`swift/`](swift/) | URLSession | Stable |
| [Unity/C#](#unity-c) | [`unity/`](unity/) | System.Net.Http | Stable |
| [C++](#c) | [`cpp/`](cpp/) | cpp-httplib | Stable |
| [Godot/GDScript](#godot-gdscript) | [`godot/`](godot/) | HTTPRequest | Stable |

All SDKs share a unified architecture:
- **Generated types** from the OpenAPI spec (models, enums, endpoints)
- **HTTP transport** with retry, rate-limiting, and dual auth (API key + OAuth2)
- **SSE streaming** for chat, aggregate queries, simulations, and memory generation
- **Auto-pagination** with `auto_paging_iter()` / `autoPagingIter()` helpers
- **12 resource namespaces**: personas, chat, domains, simulations, aggregate, memory, sessions, frameworks, auth, health, info, audit

## Quick Start

### Prerequisites

- **API key** — create one in [Ensoul Studio](https://ensoul-ai.com) under Settings → API Keys

### Environment

All SDKs read the same environment variables:

```bash
export ENSOUL_API_KEY="your-api-key-here"
# Optional — defaults to https://api.ensoul-ai.com
export ENSOUL_BASE_URL="https://api.ensoul-ai.com"
```

---

## Python

**Requirements:** Python 3.11+

```bash
pip install ensoul
```

```python
from ensoul import Ensoul

client = Ensoul()  # reads ENSOUL_API_KEY and ENSOUL_BASE_URL from env

# Health check
health = client.health.check()

# List personas (paginated)
page = client.personas.list(page=1, per_page=10)
for persona in page.items:
    print(f"{persona.name}: {persona.description}")

# Chat with streaming
for event in client.chat.send_stream(persona_id="...", message="Hello!"):
    print(event.data, end="", flush=True)

# Async client
from ensoul import AsyncEnsoul

async_client = AsyncEnsoul()
page = await async_client.personas.list()
```

---

## TypeScript

**Requirements:** Node 18+

```bash
npm install @ensoul-ai/sdk
```

```typescript
import { Ensoul } from '@ensoul-ai/sdk';

const client = new Ensoul();  // reads from env

// Health check
const health = await client.health.check();

// List personas (paginated)
const page = await client.personas.list({ page: 1, perPage: 10 });
for (const persona of page.items) {
  console.log(`${persona.name}: ${persona.description}`);
}

// Chat with streaming
const stream = await client.chat.sendStream({ personaId: '...', message: 'Hello!' });
for await (const event of stream) {
  process.stdout.write(event.data);
}

// Auto-paginate through all results
for await (const persona of page.autoPagingIter()) {
  console.log(persona.name);
}
```

---

## Kotlin

**Requirements:** JDK 17, Gradle

Add to `build.gradle.kts`:

```kotlin
repositories {
    mavenCentral()
    maven {
        url = uri("https://maven.pkg.github.com/ensoul-ai/ensoul-sdk")
        credentials {
            username = System.getenv("GITHUB_ACTOR")
            password = System.getenv("GITHUB_TOKEN")
        }
    }
}

dependencies {
    implementation("ai.ensoul:ensoul-sdk:0.2.0")
}
```

```kotlin
import ai.ensoul.sdk.EnsoulClient

suspend fun main() {
    val client = EnsoulClient()  // reads from env

    // Health check
    val health = client.health.check()

    // List personas
    val page = client.personas.list(page = 1, perPage = 10)
    page.items.forEach { println("${it.name}: ${it.description}") }

    // Chat with streaming (Kotlin Flow)
    client.chat.sendStream(personaId = "...", message = "Hello!")
        .collect { event -> print(event.data) }
}
```

---

## Swift

**Requirements:** Swift 5.9+, Xcode 15+

Add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ensoul-ai/ensoul-sdk.git", from: "0.2.0")
]
```

```swift
import Ensoul

let client = EnsoulClient()  // reads from env

// Health check
let health = try await client.health.check()

// List personas
let page = try await client.personas.list(page: 1, perPage: 10)
for persona in page.items {
    print("\(persona.name): \(persona.description)")
}

// Chat with streaming (AsyncSequence)
for try await event in client.chat.sendStream(personaId: "...", message: "Hello!") {
    print(event.data, terminator: "")
}
```

---

## Unity (C#)

**Requirements:** Unity 2021.3+, .NET Standard 2.1

Add to `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.ensoul.sdk": "https://github.com/ensoul-ai/ensoul-sdk.git?path=unity#v0.2.0",
    "com.unity.nuget.newtonsoft-json": "3.2.1"
  }
}
```

```csharp
using Ensoul;

var client = new EnsoulClient();  // reads from env

// Health check
var health = await client.Health.CheckAsync();

// List personas
var page = await client.Personas.ListAsync(page: 1, perPage: 10);
foreach (var persona in page.Items)
    Debug.Log($"{persona.Name}: {persona.Description}");

// Chat with streaming (IAsyncEnumerable)
await foreach (var evt in client.Chat.SendStreamAsync(personaId: "...", message: "Hello!"))
    Debug.Log(evt.Data);
```

---

## C++

**Requirements:** CMake 3.14+, C++17 compiler

Add to `CMakeLists.txt`:

```cmake
include(FetchContent)
FetchContent_Declare(ensoul
  GIT_REPOSITORY https://github.com/ensoul-ai/ensoul-sdk.git
  GIT_TAG v0.2.0
  SOURCE_SUBDIR cpp
)
FetchContent_MakeAvailable(ensoul)

target_link_libraries(your_target PRIVATE ensoul)
```

```cpp
#include <ensoul/ensoul.hpp>
#include <iostream>

int main() {
    auto client = ensoul::EnsoulClient();  // reads from env

    // Health check
    auto health = client.health().check();
    std::cout << "Status: " << health.dump() << std::endl;

    // List personas
    auto page = client.personas().list(1, 10);
    for (const auto& p : page.items) {
        std::cout << p.name << ": " << p.description << std::endl;
    }

    // Chat with streaming (pull iterator)
    auto stream = client.chat().send_stream("...", "Hello!");
    while (auto event = stream.next()) {
        std::cout << event->data << std::flush;
    }
}
```

---

## Godot (GDScript)

**Requirements:** Godot 4.0+

Copy the addon into your project:

```bash
git clone --depth 1 --branch v0.2.0 https://github.com/ensoul-ai/ensoul-sdk.git /tmp/ensoul-sdk
cp -r /tmp/ensoul-sdk/godot/addons/ensoul your-project/addons/ensoul
```

Enable the plugin in **Project > Project Settings > Plugins > Ensoul**.

```gdscript
func _ready() -> void:
    Ensoul.configure("ens_your_api_key", "https://api.ensoul-ai.com")

    # Health check
    var health := await Ensoul.health.check()
    print("Status: ", health)

    # List personas
    var page := await Ensoul.personas.list(1, 10)
    for persona in page.items:
        print("%s: %s" % [persona.name, persona.description])

    # Chat with streaming (signals)
    var stream := await Ensoul.chat.send_stream("...", "Hello!")
    stream.event_received.connect(func(event): print(event.data))
```

---

## Authentication

All SDKs support two authentication methods:

### API Key (recommended)
```bash
export ENSOUL_API_KEY="ens_your_key_here"
```

Or pass directly:
```python
client = Ensoul(api_key="ens_your_key_here")
```

### OAuth2 Bearer Token
```python
client = Ensoul(bearer_token="eyJ...")
```

Tokens can be obtained via the auth resource:
```python
token_response = client.auth.token_exchange(username="...", password="...")
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **401 Unauthorized** | Verify `ENSOUL_API_KEY` is set and valid |
| **Connection error** | Check `ENSOUL_BASE_URL` is unset or set to `https://api.ensoul-ai.com` |
| **npm 401 (TypeScript)** | Your `.npmrc` needs a GitHub PAT with `read:packages` scope |
| **Maven 401 (Kotlin)** | Set `GITHUB_ACTOR` and `GITHUB_TOKEN` (PAT with `read:packages`) |
| **SPM resolve fails (Swift)** | Ensure Swift 5.9+ and the repo URL ends in `.git` |
| **Unity package not found** | Ensure git URL includes `?path=unity` and `#v0.2.0` |
| **C++ OpenSSL not found** | Install OpenSSL dev headers, or the SDK falls back to HTTP |

## License

Apache-2.0
