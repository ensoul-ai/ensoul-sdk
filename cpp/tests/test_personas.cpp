#include <catch2/catch_test_macros.hpp>
#include "fixtures.hpp"

using namespace ensoul;
using namespace ensoul::testing;

TEST_CASE("personas.create sends POST to /v1/personas", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_JSON);
    auto result = client.personas().create("Alice", "test-domain");
    REQUIRE(mock->captured_requests.size() == 1);
    CHECK(mock->last_request()->method == "POST");
    CHECK(mock->last_request()->path == "/v1/personas");
    CHECK(result.id == "p1");
    CHECK(result.name == "Alice");
}

TEST_CASE("personas.create includes body fields", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_JSON);
    client.personas().create("Alice", "test-domain");
    auto body = mock->last_request()->json_body;
    CHECK(body["name"] == "Alice");
    CHECK(body["domain"] == "test-domain");
}

TEST_CASE("personas.get sends GET to /v1/personas/{id}", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_JSON);
    auto result = client.personas().get("p1");
    CHECK(mock->last_request()->method == "GET");
    CHECK(mock->last_request()->path == "/v1/personas/p1");
    CHECK(result.domain == "test-domain");
}

TEST_CASE("personas.update sends PUT to /v1/personas/{id}", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_JSON);
    nlohmann::json fields = {{"name", "Updated"}};
    client.personas().update("p1", fields);
    CHECK(mock->last_request()->method == "PUT");
    CHECK(mock->last_request()->path == "/v1/personas/p1");
}

TEST_CASE("personas.delete_ sends DELETE to /v1/personas/{id}", "[personas]") {
    auto [client, mock] = make_test_client();
    client.personas().delete_("p1");
    CHECK(mock->last_request()->method == "DELETE");
    CHECK(mock->last_request()->path == "/v1/personas/p1");
}

TEST_CASE("personas.list sends GET with page params", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_LIST_JSON);
    auto page = client.personas().list(1, 20);
    CHECK(mock->last_request()->method == "GET");
    CHECK(mock->last_request()->path == "/v1/personas");
    CHECK(mock->last_request()->params.at("page") == "1");
    CHECK(mock->last_request()->params.at("per_page") == "20");
}

TEST_CASE("personas.list returns Page with correct items", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONA_LIST_JSON);
    auto page = client.personas().list();
    CHECK(page.items.size() == 2);
    CHECK(page.total == 2);
    CHECK(page.page == 1);
    CHECK(page.pages == 1);
    CHECK(page.items[0].name == "Alice");
    CHECK(page.items[1].name == "Bob");
}

TEST_CASE("personas.batch_create sends POST to /v1/personas/batch", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, BATCH_RESPONSE_JSON);
    nlohmann::json personas = nlohmann::json::array({
        {{"name", "A"}, {"domain", "d"}},
        {{"name", "B"}, {"domain", "d"}}
    });
    auto result = client.personas().batch_create(personas, "batch-1", "test-domain");
    CHECK(mock->last_request()->path == "/v1/personas/batch");
    CHECK(result.created == 2);
    CHECK(result.persona_ids.size() == 2);
}

TEST_CASE("personas.get_personality sends GET to personality endpoint", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, PERSONALITY_JSON);
    auto result = client.personas().get_personality("p1");
    CHECK(mock->last_request()->path == "/v1/personas/p1/personality");
    CHECK(result.persona_id == "p1");
    CHECK(result.domain == "test-domain");
}

TEST_CASE("personas.get_filters sends GET to filters endpoint", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, FILTERS_JSON);
    auto result = client.personas().get_filters();
    CHECK(mock->last_request()->path == "/v1/personas/filters");
    CHECK(result.total_personas == 100);
}

TEST_CASE("personas.get_connections sends GET to connections endpoint", "[personas]") {
    auto [client, mock] = make_test_client_with_response(200, R"([{"id": "c1"}])");
    auto result = client.personas().get_connections("p1");
    CHECK(mock->last_request()->path == "/v1/personas/p1/connections");
    CHECK(result.is_array());
}
