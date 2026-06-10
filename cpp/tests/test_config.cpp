#include <catch2/catch_test_macros.hpp>
#include "ensoul/config.hpp"

using namespace ensoul;

TEST_CASE("ClientConfig has correct defaults", "[config]") {
    ClientConfig config;
    CHECK(config.base_url == "https://api.ensoul-ai.com");
    CHECK(config.timeout_ms == 30000);
    CHECK(config.max_retries == 2);
    CHECK(config.api_key.empty());
    CHECK(config.bearer_token.empty());
    CHECK(config.custom_headers.empty());
}

TEST_CASE("ClientConfig custom values", "[config]") {
    ClientConfig config;
    config.base_url = "https://custom.api.com";
    config.api_key = "my-key";
    config.timeout_ms = 5000;
    config.max_retries = 5;
    CHECK(config.base_url == "https://custom.api.com");
    CHECK(config.api_key == "my-key");
    CHECK(config.timeout_ms == 5000);
    CHECK(config.max_retries == 5);
}

TEST_CASE("api_url strips trailing slash and appends /v1", "[config]") {
    ClientConfig config;
    config.base_url = "https://api.ensoul-ai.com/";
    CHECK(config.api_url() == "https://api.ensoul-ai.com/v1");
}

TEST_CASE("api_url without trailing slash", "[config]") {
    ClientConfig config;
    config.base_url = "https://api.ensoul-ai.com";
    CHECK(config.api_url() == "https://api.ensoul-ai.com/v1");
}

TEST_CASE("Constants have expected values", "[config]") {
    CHECK(std::string(DEFAULT_BASE_URL) == "https://api.ensoul-ai.com");
    CHECK(DEFAULT_TIMEOUT_MS == 30000);
    CHECK(DEFAULT_MAX_RETRIES == 2);
    CHECK(std::string(API_VERSION) == "v1");
}
