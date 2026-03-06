#include <catch2/catch_test_macros.hpp>
#include "fixtures.hpp"

using namespace ensoul;
using namespace ensoul::testing;

TEST_CASE("chat.send sends POST to chat endpoint", "[chat]") {
    auto [client, mock] = make_test_client_with_response(200, CHAT_RESPONSE_JSON);
    auto result = client.chat().send("p1", "Hello");
    CHECK(mock->last_request()->method == "POST");
    CHECK(mock->last_request()->path == "/v1/personas/p1/chat");
    CHECK(mock->last_request()->json_body["message"] == "Hello");
}

TEST_CASE("chat.send returns ChatResponse with correct fields", "[chat]") {
    auto [client, mock] = make_test_client_with_response(200, CHAT_RESPONSE_JSON);
    auto result = client.chat().send("p1", "Hello");
    CHECK(result.response == "Hello, human!");
    CHECK(result.conversation_id == "conv-1");
    CHECK(result.token_usage.input_tokens == 10);
    CHECK(result.token_usage.output_tokens == 5);
    CHECK(result.token_usage.total_tokens == 15);
    CHECK(result.latency_ms == 200);
    CHECK(result.model == "claude-3");
}

TEST_CASE("chat.stream sends POST to stream endpoint", "[chat]") {
    auto [client, mock] = make_test_client_with_response(200, "data: test\n\n");
    auto stream = client.chat().stream("p1", "Hello");
    CHECK(mock->last_request()->path == "/v1/personas/p1/chat/stream");
}

TEST_CASE("chat.get_conversations sends GET with params", "[chat]") {
    auto [client, mock] = make_test_client_with_response(200, CONVERSATION_LIST_JSON);
    auto page = client.chat().get_conversations("p1", 1, 20);
    CHECK(mock->last_request()->method == "GET");
    CHECK(mock->last_request()->path == "/v1/personas/p1/conversations");
    CHECK(mock->last_request()->params.at("page") == "1");
}

TEST_CASE("chat.get_conversations returns Page of items", "[chat]") {
    auto [client, mock] = make_test_client_with_response(200, CONVERSATION_LIST_JSON);
    auto page = client.chat().get_conversations("p1");
    CHECK(page.items.size() == 1);
    CHECK(page.items[0].conversation_id == "conv-1");
    CHECK(page.total == 1);
}

TEST_CASE("chat.get_conversation sends GET to correct path", "[chat]") {
    auto [client, mock] = make_test_client_with_response(200, CONVERSATION_JSON);
    auto result = client.chat().get_conversation("p1", "conv-1");
    CHECK(mock->last_request()->path == "/v1/personas/p1/conversations/conv-1");
}

TEST_CASE("chat.get_conversation returns conversation with messages", "[chat]") {
    auto [client, mock] = make_test_client_with_response(200, CONVERSATION_JSON);
    auto result = client.chat().get_conversation("p1", "conv-1");
    CHECK(result.conversation_id == "conv-1");
    CHECK(result.messages.size() == 2);
    CHECK(result.messages[0].role == "user");
    CHECK(result.messages[1].content == "Hi!");
    CHECK(result.total_tokens == 50);
}
