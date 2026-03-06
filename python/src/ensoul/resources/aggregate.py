"""Aggregate resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.streaming import AsyncSSEStream, SyncSSEStream

__all__ = [
    "Aggregate",
    "AsyncAggregate",
]


class Aggregate:
    """Synchronous aggregate resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def query(
        self,
        query: str,
        *,
        filters: dict[str, Any] | None = None,
        aggregation_mode: str | None = None,
    ) -> dict:
        """POST /v1/aggregate/query"""
        body: dict[str, Any] = {"query": query}
        if filters is not None:
            body["filters"] = filters
        if aggregation_mode is not None:
            body["aggregation_mode"] = aggregation_mode
        response = self._client.post("/v1/aggregate/query", json=body)
        return response.json()

    def stream(
        self,
        query: str,
        *,
        filters: dict[str, Any] | None = None,
        aggregation_mode: str | None = None,
        target_confidence: float = 0.95,
        min_samples: int = 100,
        max_samples: int | None = None,
    ) -> SyncSSEStream:
        """POST /v1/aggregate/stream — returns SSE stream of progress events."""
        body: dict[str, Any] = {
            "query": query,
            "target_confidence": target_confidence,
            "min_samples": min_samples,
        }
        if filters is not None:
            body["filters"] = filters
        if aggregation_mode is not None:
            body["aggregation_mode"] = aggregation_mode
        if max_samples is not None:
            body["max_samples"] = max_samples
        return self._client.stream_sse("POST", "/v1/aggregate/stream", json=body)

    def grouped_stream(
        self,
        query: str,
        *,
        group_by: str,
        filters: dict[str, Any] | None = None,
    ) -> SyncSSEStream:
        """POST /v1/aggregate/stream/grouped"""
        body: dict[str, Any] = {"query": query, "group_by": group_by}
        if filters is not None:
            body["filters"] = filters
        return self._client.stream_sse("POST", "/v1/aggregate/stream/grouped", json=body)

    def simulate(
        self,
        *,
        scenario: str,
        target_cohort: dict[str, Any] | None = None,
        duration_days: int = 30,
        parameters: dict[str, Any] | None = None,
    ) -> dict:
        """POST /v1/aggregate/simulate"""
        body: dict[str, Any] = {
            "scenario": scenario,
            "duration_days": duration_days,
        }
        if target_cohort is not None:
            body["target_cohort"] = target_cohort
        if parameters is not None:
            body["parameters"] = parameters
        response = self._client.post("/v1/aggregate/simulate", json=body)
        return response.json()

    def trace_influence(
        self,
        persona_id: str,
        *,
        influence_type: str | None = None,
        direction: str = "downstream",
        max_depth: int = 3,
    ) -> dict:
        """GET /v1/aggregate/influence/{persona_id}"""
        params: dict[str, Any] = {"direction": direction, "max_depth": max_depth}
        if influence_type is not None:
            params["influence_type"] = influence_type
        response = self._client.get(f"/v1/aggregate/influence/{persona_id}", params=params)
        return response.json()


class AsyncAggregate:
    """Asynchronous aggregate resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def query(
        self,
        query: str,
        *,
        filters: dict[str, Any] | None = None,
        aggregation_mode: str | None = None,
    ) -> dict:
        """POST /v1/aggregate/query"""
        body: dict[str, Any] = {"query": query}
        if filters is not None:
            body["filters"] = filters
        if aggregation_mode is not None:
            body["aggregation_mode"] = aggregation_mode
        response = await self._client.post("/v1/aggregate/query", json=body)
        return response.json()

    async def stream(
        self,
        query: str,
        *,
        filters: dict[str, Any] | None = None,
        aggregation_mode: str | None = None,
        target_confidence: float = 0.95,
        min_samples: int = 100,
        max_samples: int | None = None,
    ) -> AsyncSSEStream:
        """POST /v1/aggregate/stream — returns SSE stream of progress events."""
        body: dict[str, Any] = {
            "query": query,
            "target_confidence": target_confidence,
            "min_samples": min_samples,
        }
        if filters is not None:
            body["filters"] = filters
        if aggregation_mode is not None:
            body["aggregation_mode"] = aggregation_mode
        if max_samples is not None:
            body["max_samples"] = max_samples
        return await self._client.stream_sse("POST", "/v1/aggregate/stream", json=body)

    async def grouped_stream(
        self,
        query: str,
        *,
        group_by: str,
        filters: dict[str, Any] | None = None,
    ) -> AsyncSSEStream:
        """POST /v1/aggregate/stream/grouped"""
        body: dict[str, Any] = {"query": query, "group_by": group_by}
        if filters is not None:
            body["filters"] = filters
        return await self._client.stream_sse("POST", "/v1/aggregate/stream/grouped", json=body)

    async def simulate(
        self,
        *,
        scenario: str,
        target_cohort: dict[str, Any] | None = None,
        duration_days: int = 30,
        parameters: dict[str, Any] | None = None,
    ) -> dict:
        """POST /v1/aggregate/simulate"""
        body: dict[str, Any] = {
            "scenario": scenario,
            "duration_days": duration_days,
        }
        if target_cohort is not None:
            body["target_cohort"] = target_cohort
        if parameters is not None:
            body["parameters"] = parameters
        response = await self._client.post("/v1/aggregate/simulate", json=body)
        return response.json()

    async def trace_influence(
        self,
        persona_id: str,
        *,
        influence_type: str | None = None,
        direction: str = "downstream",
        max_depth: int = 3,
    ) -> dict:
        """GET /v1/aggregate/influence/{persona_id}"""
        params: dict[str, Any] = {"direction": direction, "max_depth": max_depth}
        if influence_type is not None:
            params["influence_type"] = influence_type
        response = await self._client.get(f"/v1/aggregate/influence/{persona_id}", params=params)
        return response.json()
