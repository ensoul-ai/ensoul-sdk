# Getting Started with Ensoul SDKs

This guide walks alpha testers through installing and verifying each SDK against the demo API.

## Prerequisites

- **GitHub account** with read access to `ensoul-ai/ensoul-sdk`
- **API key** — request one from the Ensoul team
- **Demo API** is running at `https://demo.ensoul-ai.com/api`

## Environment Setup

All 6 SDKs read the same environment variables:

```bash
export ENSOUL_API_KEY="your-api-key-here"
export ENSOUL_BASE_URL="https://demo.ensoul-ai.com/api"
```

## Python

**Requirements:** Python 3.11+

### Install

```bash
# From GitHub Release (recommended for alpha)
pip install https://github.com/ensoul-ai/ensoul-sdk/releases/download/v0.1.0/ensoul-0.1.0-py3-none-any.whl

# Or from source
pip install "git+https://github.com/ensoul-ai/ensoul-sdk.git#subdirectory=python"
```

### Verify

```python
from ensoul import Ensoul

client = Ensoul()  # reads ENSOUL_API_KEY and ENSOUL_BASE_URL from env
health = client.health.check()
print(f"API status: {health}")
```

## TypeScript

**Requirements:** Node 18+

### Install

```bash
# Configure GitHub npm registry
echo "@ensoul:registry=https://npm.pkg.github.com" >> .npmrc

# Authenticate (use a GitHub PAT with read:packages scope)
echo "//npm.pkg.github.com/:_authToken=YOUR_GITHUB_TOKEN" >> .npmrc

# Install
npm install @ensoul/sdk
```

### Verify

```typescript
import { Ensoul } from '@ensoul/sdk';

const client = new Ensoul();  // reads from env
const health = await client.health.check();
console.log('API status:', health);
```

## Kotlin

**Requirements:** JDK 17, Gradle

### Install

Add the GitHub Maven repository and dependency to your `build.gradle.kts`:

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
    implementation("ai.ensoul:ensoul-sdk:0.1.0")
}
```

### Verify

```kotlin
import ai.ensoul.sdk.EnsoulClient

suspend fun main() {
    val client = EnsoulClient()  // reads from env
    val health = client.health.check()
    println("API status: $health")
}
```

## Swift

**Requirements:** Swift 5.9+, Xcode 15+

### Install

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ensoul-ai/ensoul-sdk.git", from: "0.1.0")
]
```

Then add `"Ensoul"` to your target's dependencies.

### Verify

```swift
import Ensoul

let client = EnsoulClient()  // reads from env
let health = try await client.health.check()
print("API status: \(health)")
```

## Unity (C#)

**Requirements:** Unity 2021.3+, .NET Standard 2.1

### Install

Add to your `Packages/manifest.json`:

```json
{
  "dependencies": {
    "ai.ensoul.sdk": "https://github.com/ensoul-ai/ensoul-sdk.git?path=unity#v0.1.0"
  }
}
```

### Verify

```csharp
using Ensoul;

var client = new EnsoulClient();  // reads from env
var health = await client.Health.CheckAsync();
Debug.Log($"API status: {health}");
```

## Godot (GDScript)

**Requirements:** Godot 4.0+

### Install

Copy `addons/ensoul/` from the SDK repo into your Godot project's `addons/` directory:

```bash
# From the ensoul-sdk repo
cp -r godot/addons/ensoul/ /path/to/your-godot-project/addons/ensoul/
```

Then enable the plugin in **Project → Project Settings → Plugins → Ensoul**.

### Verify

```gdscript
func _ready() -> void:
    Ensoul.configure("ens_your_api_key", "https://demo.ensoul-ai.com/api")
    var h := await Ensoul.health.check()
    print("API status: ", h.get("body", {}).get("status", "unknown"))
```

## C++

**Requirements:** CMake 3.14+, C++17 compiler

### Install

Add to your `CMakeLists.txt`:

```cmake
include(FetchContent)
FetchContent_Declare(ensoul
  GIT_REPOSITORY https://github.com/ensoul-ai/ensoul-sdk.git
  GIT_TAG v0.1.0
  SOURCE_SUBDIR cpp
)
FetchContent_MakeAvailable(ensoul)

target_link_libraries(your_target PRIVATE ensoul)
```

### Verify

```cpp
#include <ensoul/ensoul.hpp>
#include <iostream>

int main() {
    auto client = ensoul::EnsoulClient();  // reads from env
    auto health = client.health().check();
    std::cout << "API status: " << health.dump() << std::endl;
}
```

## Troubleshooting

### Authentication errors (401)

- Verify `ENSOUL_API_KEY` is set: `echo $ENSOUL_API_KEY`
- Check the key is valid — request a fresh one if needed

### Connection errors

- Verify `ENSOUL_BASE_URL` is set to `https://demo.ensoul-ai.com/api`
- Check the demo server is up: `curl https://demo.ensoul-ai.com/api/health`

### GitHub npm 401 (TypeScript)

- Your `.npmrc` must have a valid GitHub PAT with `read:packages` scope
- The token must belong to an account with access to `ensoul-ai/ensoul-sdk`

### GitHub Maven 401 (Kotlin)

- Set `GITHUB_ACTOR` to your GitHub username
- Set `GITHUB_TOKEN` to a PAT with `read:packages` scope

### Swift Package Manager fails to resolve

- Ensure you're using Swift 5.9+ (`swift --version`)
- The root `Package.swift` at the repo root is what SPM resolves

### Unity package not found

- Ensure the git URL includes `?path=unity` and the tag `#v0.1.0`
- Unity's package manager needs git installed and accessible

### C++ build errors

- Ensure CMake 3.14+ and a C++17-capable compiler
- If OpenSSL is not found, the SDK falls back to HTTP (no TLS)
