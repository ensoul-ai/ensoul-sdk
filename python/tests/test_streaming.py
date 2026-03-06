"""Tests for SSE streaming — line parsing and event construction."""

from __future__ import annotations

import io
import json
from typing import Iterator

import pytest

from ensoul.streaming import (
    AggregateStreamEvent,
    ChatStreamEvent,
    SSEEvent,
    SyncSSEStream,
    _parse_sse_lines,
    parse_aggregate_event,
    parse_chat_event,
)


def _lines_iter(text: str) -> Iterator[str]:
    """Yield lines from a string, simulating httpx iter_lines output."""
    for line in text.splitlines(keepends=True):
        yield line


class TestSSELineParsing:
    def test_single_event(self):
        raw = "event: chunk\ndata: {\"chunk\": \"hello\"}\n\n"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert len(events) == 1
        assert events[0].event == "chunk"
        assert events[0].data == '{"chunk": "hello"}'

    def test_multiple_events(self):
        raw = (
            "event: chunk\ndata: first\n\n"
            "event: progress\ndata: second\n\n"
        )
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert len(events) == 2
        assert events[0].event == "chunk"
        assert events[1].event == "progress"

    def test_comment_lines_ignored(self):
        raw = ": keep-alive\nevent: chunk\ndata: hello\n\n"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert len(events) == 1
        assert events[0].data == "hello"

    def test_event_without_event_field_defaults_to_message(self):
        raw = "data: hello\n\n"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert len(events) == 1
        assert events[0].event == "message"

    def test_multi_line_data_joined(self):
        raw = "data: line1\ndata: line2\n\n"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert len(events) == 1
        assert events[0].data == "line1\nline2"

    def test_id_field_parsed(self):
        raw = "event: chunk\nid: evt_001\ndata: hello\n\n"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert events[0].id == "evt_001"

    def test_retry_field_parsed(self):
        raw = "retry: 3000\nevent: chunk\ndata: hello\n\n"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert events[0].retry == 3000

    def test_retry_field_invalid_ignored(self):
        raw = "retry: not_a_number\nevent: chunk\ndata: hello\n\n"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert events[0].retry is None

    def test_empty_stream_yields_nothing(self):
        events = list(_parse_sse_lines(iter([])))
        assert events == []

    def test_final_event_without_trailing_blank_line(self):
        raw = "event: chunk\ndata: last"
        events = list(_parse_sse_lines(_lines_iter(raw)))
        assert len(events) == 1
        assert events[0].data == "last"


class TestChatStreamEventParsing:
    def test_parse_chat_event_from_fixture(self, sse_fixture_lines):
        chunk_lines = [l for l in sse_fixture_lines if json.loads(l)["event"] == "chunk"]
        assert len(chunk_lines) >= 1

        for raw_line in chunk_lines:
            fixture = json.loads(raw_line)
            sse_event = SSEEvent(event="chunk", data=json.dumps(fixture["data"]))
            chat_event = parse_chat_event(sse_event)
            assert isinstance(chat_event, ChatStreamEvent)
            assert isinstance(chat_event.chunk, str)
            assert isinstance(chat_event.conversation_id, str)
            assert isinstance(chat_event.chunk_index, int)
            assert isinstance(chat_event.is_final, bool)

    def test_parse_chat_event_final_has_token_usage(self, sse_fixture_lines):
        chunk_lines = [l for l in sse_fixture_lines if json.loads(l)["event"] == "chunk"]
        final_line = next(
            l for l in chunk_lines if json.loads(l)["data"]["is_final"]
        )
        fixture = json.loads(final_line)
        sse_event = SSEEvent(event="chunk", data=json.dumps(fixture["data"]))
        chat_event = parse_chat_event(sse_event)
        assert chat_event.is_final is True
        assert chat_event.token_usage is not None
        assert "total_tokens" in chat_event.token_usage

    def test_parse_chat_event_raises_on_invalid_json(self):
        sse_event = SSEEvent(event="chunk", data="not valid json")
        with pytest.raises(ValueError, match="Invalid JSON"):
            parse_chat_event(sse_event)

    def test_parse_chat_event_non_final_has_no_token_usage(self, sse_fixture_lines):
        chunk_lines = [l for l in sse_fixture_lines if json.loads(l)["event"] == "chunk"]
        non_final = next(
            l for l in chunk_lines if not json.loads(l)["data"]["is_final"]
        )
        fixture = json.loads(non_final)
        sse_event = SSEEvent(event="chunk", data=json.dumps(fixture["data"]))
        chat_event = parse_chat_event(sse_event)
        assert chat_event.is_final is False
        assert chat_event.token_usage is None


class TestAggregateStreamEventParsing:
    def test_parse_aggregate_event_from_fixture(self, sse_fixture_lines):
        progress_lines = [l for l in sse_fixture_lines if json.loads(l)["event"] == "progress"]
        assert len(progress_lines) >= 1

        for raw_line in progress_lines:
            fixture = json.loads(raw_line)
            sse_event = SSEEvent(event="progress", data=json.dumps(fixture["data"]))
            agg_event = parse_aggregate_event(sse_event)
            assert isinstance(agg_event, AggregateStreamEvent)
            assert isinstance(agg_event.tally, dict)
            assert isinstance(agg_event.n, int)
            assert isinstance(agg_event.categories, list)
            assert isinstance(agg_event.can_terminate, bool)
            assert isinstance(agg_event.is_final, bool)

    def test_parse_aggregate_final_event_has_synthesis(self, sse_fixture_lines):
        progress_lines = [l for l in sse_fixture_lines if json.loads(l)["event"] == "progress"]
        final_line = next(
            l for l in progress_lines if json.loads(l)["data"]["is_final"]
        )
        fixture = json.loads(final_line)
        sse_event = SSEEvent(event="progress", data=json.dumps(fixture["data"]))
        agg_event = parse_aggregate_event(sse_event)
        assert agg_event.is_final is True
        assert agg_event.synthesis is not None

    def test_parse_aggregate_event_raises_on_invalid_json(self):
        sse_event = SSEEvent(event="progress", data="{{bad json}}")
        with pytest.raises(ValueError, match="Invalid JSON"):
            parse_aggregate_event(sse_event)

    def test_parse_aggregate_event_extra_fields_captured(self, sse_fixture_lines):
        progress_lines = [l for l in sse_fixture_lines if json.loads(l)["event"] == "progress"]
        fixture = json.loads(progress_lines[0])
        data = {**fixture["data"], "extra_field": "extra_value"}
        sse_event = SSEEvent(event="progress", data=json.dumps(data))
        agg_event = parse_aggregate_event(sse_event)
        assert "extra_field" in agg_event.extra


class TestSyncSSEStream:
    def _make_stream(self, sse_text: str) -> SyncSSEStream:
        """Build a SyncSSEStream backed by fake httpx response content."""
        import httpx
        response = httpx.Response(
            200,
            content=sse_text.encode(),
            headers={"content-type": "text/event-stream"},
        )
        return SyncSSEStream(response)

    def test_iterates_events(self, sse_fixture_lines):
        # Build SSE format from chunk events only
        sse_parts = []
        for raw_line in sse_fixture_lines:
            fixture = json.loads(raw_line)
            if fixture["event"] == "chunk":
                sse_parts.append(
                    f"event: chunk\ndata: {json.dumps(fixture['data'])}\n\n"
                )
        sse_text = "".join(sse_parts)

        stream = self._make_stream(sse_text)
        events = list(stream)
        assert len(events) == sum(
            1 for l in sse_fixture_lines if json.loads(l)["event"] == "chunk"
        )

    def test_iter_dunder_works(self, sse_fixture_lines):
        sse_parts = []
        for raw_line in sse_fixture_lines[:1]:
            fixture = json.loads(raw_line)
            if fixture["event"] == "chunk":
                sse_parts.append(
                    f"event: chunk\ndata: {json.dumps(fixture['data'])}\n\n"
                )
        sse_text = "".join(sse_parts)
        stream = self._make_stream(sse_text)
        events = [e for e in stream]
        assert len(events) >= 0  # just checking __iter__ works
