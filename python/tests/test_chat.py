"""Tests for the Chat resource."""

from __future__ import annotations

import httpx
import pytest
import respx

from ensoul import Ensoul
from ensoul.generated.chat import ChatResponse

TEST_BASE_URL = "https://test.ensoul.ai"
PERSONA_ID = "persona_test_001"


@pytest.fixture
def client():
    return Ensoul(api_key="sk_test_123", base_url=TEST_BASE_URL)


CHAT_RESPONSE_PAYLOAD = {
    "response": "I believe technology is a powerful tool for human connection.",
    "conversation_id": "conv_test_001",
    "token_usage": {
        "input_tokens": 256,
        "output_tokens": 42,
        "total_tokens": 298,
    },
    "latency_ms": 1200,
    "model": "claude-sonnet-4-6",
    "timestamp": "2025-01-15T10:30:00Z",
}


class TestChatSend:
    def test_send_returns_chat_response(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.post(f"/v1/personas/{PERSONA_ID}/chat").mock(
                return_value=httpx.Response(200, json=CHAT_RESPONSE_PAYLOAD)
            )
            result = client.chat.send(PERSONA_ID, "Hello!")
        assert isinstance(result, ChatResponse)
        assert result.response == CHAT_RESPONSE_PAYLOAD["response"]
        assert result.conversation_id == "conv_test_001"
        assert result.token_usage.total_tokens == 298

    def test_send_with_conversation_id(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            route = mock.post(f"/v1/personas/{PERSONA_ID}/chat").mock(
                return_value=httpx.Response(200, json=CHAT_RESPONSE_PAYLOAD)
            )
            client.chat.send(PERSONA_ID, "Follow up", conversation_id="conv_existing")
        import json
        sent = json.loads(route.calls[0].request.content)
        assert sent["conversation_id"] == "conv_existing"
        assert sent["message"] == "Follow up"

    def test_send_raises_on_error(self, client, error_fixtures):
        fix = error_fixtures["404_persona"]
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.post(f"/v1/personas/{PERSONA_ID}/chat").mock(
                return_value=httpx.Response(fix["status"], json=fix["body"])
            )
            from ensoul.errors import NotFoundError
            with pytest.raises(NotFoundError):
                client.chat.send(PERSONA_ID, "Hello")


class TestChatStream:
    def _make_sse_body(self, sse_fixture_lines: list[str]) -> bytes:
        """Convert JSONL fixture lines to proper SSE format."""
        import json
        parts = []
        for line in sse_fixture_lines:
            # Only take the chat chunk events (not aggregate progress events)
            data = json.loads(line)
            if data.get("event") == "chunk":
                parts.append(f"event: chunk\ndata: {json.dumps(data['data'])}\n\n")
        return "".join(parts).encode()

    def test_stream_returns_sse_stream(self, client, sse_fixture_lines):
        sse_body = self._make_sse_body(sse_fixture_lines)
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.post(f"/v1/personas/{PERSONA_ID}/chat/stream").mock(
                return_value=httpx.Response(
                    200,
                    content=sse_body,
                    headers={"content-type": "text/event-stream"},
                )
            )
            stream = client.chat.stream(PERSONA_ID, "Tell me more.")
        # Verify it's an SSE stream object
        from ensoul.streaming import SyncSSEStream
        assert isinstance(stream, SyncSSEStream)

    def test_stream_events_are_parseable(self, client, sse_fixture_lines):
        import json
        sse_body = self._make_sse_body(sse_fixture_lines)
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.post(f"/v1/personas/{PERSONA_ID}/chat/stream").mock(
                return_value=httpx.Response(
                    200,
                    content=sse_body,
                    headers={"content-type": "text/event-stream"},
                )
            )
            stream = client.chat.stream(PERSONA_ID, "Tell me more.")
            events = list(stream)

        assert len(events) > 0
        for event in events:
            assert event.event == "chunk"
            data = json.loads(event.data)
            assert "chunk" in data
            assert "conversation_id" in data


class TestChatConversations:
    def test_get_conversations_returns_page(self, client):
        conv_payload = {
            "items": [
                {
                    "conversation_id": "conv_001",
                    "persona_id": PERSONA_ID,
                    "created_at": "2025-01-15T10:00:00Z",
                    "updated_at": "2025-01-15T10:30:00Z",
                    "message_count": 4,
                    "preview": "What do you think about...",
                }
            ],
            "total": 1,
            "page": 1,
            "per_page": 20,
            "pages": 1,
            "persona_id": PERSONA_ID,
        }
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get(f"/v1/personas/{PERSONA_ID}/conversations").mock(
                return_value=httpx.Response(200, json=conv_payload)
            )
            page = client.chat.get_conversations(PERSONA_ID)
        assert len(page.items) == 1
        assert page.items[0].conversation_id == "conv_001"
