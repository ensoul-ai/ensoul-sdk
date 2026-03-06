#include <catch2/catch_test_macros.hpp>
#include "fixtures.hpp"

using namespace ensoul;
using namespace ensoul::testing;

TEST_CASE("EnsoulClient VERSION is 0.1.0", "[client]") {
    CHECK(std::string(EnsoulClient::VERSION) == "0.1.0");
}

TEST_CASE("EnsoulClient can be constructed with mock transport", "[client]") {
    auto [client, mock] = make_test_client();
    REQUIRE(mock != nullptr);
}

TEST_CASE("EnsoulClient personas namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_JSON);
    auto result = client.personas().get("p1");
    CHECK(result.id == "p1");
}

TEST_CASE("EnsoulClient chat namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, CHAT_RESPONSE_JSON);
    auto result = client.chat().send("p1", "Hello");
    CHECK(result.response == "Hello, human!");
}

TEST_CASE("EnsoulClient domains namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, R"({"id": "d1"})");
    auto result = client.domains().get("d1");
    CHECK(result["id"] == "d1");
}

TEST_CASE("EnsoulClient simulations namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, SIMULATION_JSON);
    auto result = client.simulations().get("sim-1");
    CHECK(result.id == "sim-1");
}

TEST_CASE("EnsoulClient aggregate namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, R"({"result": "ok"})");
    auto result = client.aggregate().query("test");
    CHECK(result.contains("result"));
}

TEST_CASE("EnsoulClient memory namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, R"({"id": "m1"})");
    auto result = client.memory().get("p1", "m1");
    CHECK(result["id"] == "m1");
}

TEST_CASE("EnsoulClient sessions namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, R"({"id": "s1"})");
    auto result = client.sessions().get("p1", "s1");
    CHECK(result["id"] == "s1");
}

TEST_CASE("EnsoulClient frameworks namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, R"({"id": "f1"})");
    auto result = client.frameworks().get("f1");
    CHECK(result["id"] == "f1");
}

TEST_CASE("EnsoulClient auth namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, USER_RESPONSE_JSON);
    auto result = client.auth().me();
    CHECK(result.username == "testuser");
}

TEST_CASE("EnsoulClient health namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, R"({"status": "ok"})");
    auto result = client.health().check();
    CHECK(result["status"] == "ok");
}

TEST_CASE("EnsoulClient info namespace accessible", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, R"({"version": "1.0"})");
    auto result = client.info().config();
    CHECK(result["version"] == "1.0");
}

TEST_CASE("EnsoulClient request is captured by mock", "[client]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_JSON);
    client.personas().get("p1");
    REQUIRE(mock->captured_requests.size() == 1);
    CHECK(mock->last_request()->method == "GET");
    CHECK(mock->last_request()->path == "/v1/personas/p1");
}
