#include <catch2/catch_test_macros.hpp>
#include "ensoul/streaming.hpp"

using namespace ensoul;

TEST_CASE("SSE parses basic event", "[streaming]") {
    SseStream stream("data: hello\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "hello");
    CHECK(event.event == "message");
    CHECK_FALSE(stream.next_event(event));
}

TEST_CASE("SSE parses multiple events", "[streaming]") {
    SseStream stream("data: first\n\ndata: second\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "first");
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "second");
    CHECK_FALSE(stream.next_event(event));
}

TEST_CASE("SSE handles multi-line data", "[streaming]") {
    SseStream stream("data: line1\ndata: line2\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "line1\nline2");
}

TEST_CASE("SSE ignores comments", "[streaming]") {
    SseStream stream(": this is a comment\ndata: hello\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "hello");
    CHECK_FALSE(stream.next_event(event));
}

TEST_CASE("SSE parses event type", "[streaming]") {
    SseStream stream("event: chunk\ndata: payload\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.event == "chunk");
    CHECK(event.data == "payload");
}

TEST_CASE("SSE parses id field", "[streaming]") {
    SseStream stream("id: 42\ndata: hello\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.id == "42");
    CHECK(event.data == "hello");
}

TEST_CASE("SSE parses retry field", "[streaming]") {
    SseStream stream("retry: 5000\ndata: hello\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.retry == 5000);
}

TEST_CASE("SSE default event type is message", "[streaming]") {
    SseStream stream("data: hello\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.event == "message");
}

TEST_CASE("SSE blank line dispatches event", "[streaming]") {
    SseStream stream("data: one\n\ndata: two\n\n");
    SseEvent e1, e2;
    REQUIRE(stream.next_event(e1));
    REQUIRE(stream.next_event(e2));
    CHECK(e1.data == "one");
    CHECK(e2.data == "two");
}

TEST_CASE("SSE no trailing blank line still dispatches at EOF", "[streaming]") {
    SseStream stream("data: hello");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "hello");
}

TEST_CASE("SSE empty data line included", "[streaming]") {
    SseStream stream("data:\ndata: second\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "\nsecond");
}

TEST_CASE("SSE field with no colon uses empty string", "[streaming]") {
    SseStream stream("data\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "");
}

TEST_CASE("SSE state resets between events", "[streaming]") {
    SseStream stream("event: custom\ndata: first\n\ndata: second\n\n");
    SseEvent e1, e2;
    REQUIRE(stream.next_event(e1));
    REQUIRE(stream.next_event(e2));
    CHECK(e1.event == "custom");
    CHECK(e2.event == "message");
}

TEST_CASE("SSE ignores unknown fields", "[streaming]") {
    SseStream stream("unknown-field: value\ndata: hello\n\n");
    SseEvent event;
    REQUIRE(stream.next_event(event));
    CHECK(event.data == "hello");
}

TEST_CASE("parse_chat_event deserializes correctly", "[streaming]") {
    SseEvent sse;
    sse.data = R"({"chunk": "Hello", "is_final": false, "conversation_id": "c1"})";
    auto evt = parse_chat_event(sse);
    CHECK(evt.chunk == "Hello");
    CHECK(evt.is_final == false);
    CHECK(evt.conversation_id == "c1");
}

TEST_CASE("parse_chat_event is_final true", "[streaming]") {
    SseEvent sse;
    sse.data = R"({"chunk": "", "is_final": true, "conversation_id": "c1"})";
    auto evt = parse_chat_event(sse);
    CHECK(evt.is_final == true);
}

TEST_CASE("parse_chat_event with token_usage", "[streaming]") {
    SseEvent sse;
    sse.data = R"({"chunk": "done", "is_final": true, "token_usage": {"input_tokens": 10, "output_tokens": 20, "total_tokens": 30}})";
    auto evt = parse_chat_event(sse);
    REQUIRE(evt.token_usage.has_value());
    CHECK(evt.token_usage->at("input_tokens") == 10);
    CHECK(evt.token_usage->at("total_tokens") == 30);
}

TEST_CASE("parse_aggregate_event with tally", "[streaming]") {
    SseEvent sse;
    sse.data = R"({"tally": {"agree": 8, "disagree": 2}, "is_final": true})";
    auto evt = parse_aggregate_event(sse);
    CHECK(evt.tally.at("agree") == 8);
    CHECK(evt.tally.at("disagree") == 2);
    CHECK(evt.is_final == true);
}
