"""SSE streaming support for the Ensoul SDK."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from typing import AsyncIterator, Iterator

import httpx

__all__ = [
    "SSEEvent",
    "ChatStreamEvent",
    "AggregateStreamEvent",
    "SyncSSEStream",
    "AsyncSSEStream",
    "parse_chat_event",
    "parse_aggregate_event",
]


@dataclass
class SSEEvent:
    """A single parsed Server-Sent Event."""

    event: str  # event type, e.g. "chunk" or "progress"
    data: str   # raw JSON string
    id: str | None = None
    retry: int | None = None


@dataclass
class ChatStreamEvent:
    """A parsed chat SSE chunk event."""

    chunk: str
    conversation_id: str
    chunk_index: int
    is_final: bool
    token_usage: dict[str, int] | None = None


@dataclass
class AggregateStreamEvent:
    """A parsed aggregate SSE progress event."""

    tally: dict[str, int]
    n: int
    categories: list[dict]
    can_terminate: bool
    is_final: bool
    synthesis: str | None = None
    extra: dict = field(default_factory=dict)


def _parse_sse_lines(lines: Iterator[str]) -> Iterator[SSEEvent]:
    """Parse raw SSE lines into SSEEvent objects.

    SSE format:
        event: <type>
        data: <json>
        [id: <id>]
        [retry: <ms>]
        <blank line> — delimits events
    """
    current_event: str = "message"
    current_data: list[str] = []
    current_id: str | None = None
    current_retry: int | None = None

    for line in lines:
        line = line.rstrip("\r\n")

        if line == "":
            # Blank line: dispatch event if we have data
            if current_data:
                yield SSEEvent(
                    event=current_event,
                    data="\n".join(current_data),
                    id=current_id,
                    retry=current_retry,
                )
            # Reset state for next event
            current_event = "message"
            current_data = []
            current_id = None
            current_retry = None
            continue

        if line.startswith(":"):
            # Comment line — ignore
            continue

        if ":" in line:
            field_name, _, field_value = line.partition(":")
            field_value = field_value.lstrip(" ")
        else:
            field_name = line
            field_value = ""

        if field_name == "event":
            current_event = field_value
        elif field_name == "data":
            current_data.append(field_value)
        elif field_name == "id":
            current_id = field_value
        elif field_name == "retry":
            try:
                current_retry = int(field_value)
            except ValueError:
                pass

    # Dispatch final event if stream ends without trailing blank line
    if current_data:
        yield SSEEvent(
            event=current_event,
            data="\n".join(current_data),
            id=current_id,
            retry=current_retry,
        )


async def _parse_sse_lines_async(lines: AsyncIterator[str]) -> AsyncIterator[SSEEvent]:
    """Async version of _parse_sse_lines."""
    current_event: str = "message"
    current_data: list[str] = []
    current_id: str | None = None
    current_retry: int | None = None

    async for line in lines:
        line = line.rstrip("\r\n")

        if line == "":
            if current_data:
                yield SSEEvent(
                    event=current_event,
                    data="\n".join(current_data),
                    id=current_id,
                    retry=current_retry,
                )
            current_event = "message"
            current_data = []
            current_id = None
            current_retry = None
            continue

        if line.startswith(":"):
            continue

        if ":" in line:
            field_name, _, field_value = line.partition(":")
            field_value = field_value.lstrip(" ")
        else:
            field_name = line
            field_value = ""

        if field_name == "event":
            current_event = field_value
        elif field_name == "data":
            current_data.append(field_value)
        elif field_name == "id":
            current_id = field_value
        elif field_name == "retry":
            try:
                current_retry = int(field_value)
            except ValueError:
                pass

    if current_data:
        yield SSEEvent(
            event=current_event,
            data="\n".join(current_data),
            id=current_id,
            retry=current_retry,
        )


class SyncSSEStream:
    """Synchronous SSE stream iterator backed by an httpx response."""

    def __init__(self, response: httpx.Response) -> None:
        self._response = response

    def events(self) -> Iterator[SSEEvent]:
        """Parse raw SSE lines from the response into SSEEvent objects."""
        yield from _parse_sse_lines(self._response.iter_lines())

    def __iter__(self) -> Iterator[SSEEvent]:
        return self.events()

    def close(self) -> None:
        """Close the underlying response stream."""
        self._response.close()


class AsyncSSEStream:
    """Async SSE stream iterator backed by an httpx response."""

    def __init__(self, response: httpx.Response) -> None:
        self._response = response

    def __aiter__(self) -> AsyncIterator[SSEEvent]:
        return _parse_sse_lines_async(self._response.aiter_lines())

    async def close(self) -> None:
        """Close the underlying response stream."""
        await self._response.aclose()


def parse_chat_event(event: SSEEvent) -> ChatStreamEvent:
    """Parse an SSEEvent into a ChatStreamEvent.

    Raises ValueError if the event data is not valid chat event JSON.
    """
    try:
        payload = json.loads(event.data)
    except json.JSONDecodeError as exc:
        raise ValueError(f"Invalid JSON in SSE chat event: {event.data!r}") from exc

    return ChatStreamEvent(
        chunk=payload["chunk"],
        conversation_id=payload["conversation_id"],
        chunk_index=payload["chunk_index"],
        is_final=payload["is_final"],
        token_usage=payload.get("token_usage"),
    )


def parse_aggregate_event(event: SSEEvent) -> AggregateStreamEvent:
    """Parse an SSEEvent into an AggregateStreamEvent.

    Raises ValueError if the event data is not valid aggregate event JSON.
    """
    try:
        payload = json.loads(event.data)
    except json.JSONDecodeError as exc:
        raise ValueError(f"Invalid JSON in SSE aggregate event: {event.data!r}") from exc

    known_keys = {"tally", "n", "categories", "can_terminate", "is_final", "synthesis"}
    extra = {k: v for k, v in payload.items() if k not in known_keys}

    return AggregateStreamEvent(
        tally=payload["tally"],
        n=payload["n"],
        categories=payload["categories"],
        can_terminate=payload["can_terminate"],
        is_final=payload["is_final"],
        synthesis=payload.get("synthesis"),
        extra=extra,
    )
