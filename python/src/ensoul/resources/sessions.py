"""Sessions resource for the Ensoul SDK.

Hierarchical session orchestration under ``/v1/sessions/*``. As of API 0.2.0
these routes are no longer nested under a persona: a session is created against
the authenticated team/user context, so ``create`` no longer takes a
``persona_id`` (the ``SessionCreate`` body has no persona field). This is a
distinct family from ``/v1/chat/sessions`` (chat-message threads). See
``sdks/openapi/namespace-migration-contract.md``.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage

__all__ = [
    "Sessions",
    "AsyncSessions",
]


class Sessions:
    """Synchronous sessions resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def create(
        self,
        *,
        tier: int = 0,
        parent_session_id: str | None = None,
        system_instructions: str | None = None,
        **kwargs: Any,
    ) -> dict:
        """POST /v1/sessions — create a session (``SessionCreate``)."""
        body: dict[str, Any] = {"tier": tier}
        if parent_session_id is not None:
            body["parent_session_id"] = parent_session_id
        if system_instructions is not None:
            body["system_instructions"] = system_instructions
        body.update({k: v for k, v in kwargs.items() if v is not None})
        return self._client.post("/v1/sessions", json=body).json()

    def get(self, session_id: str) -> dict:
        """GET /v1/sessions/{session_id}"""
        return self._client.get(f"/v1/sessions/{session_id}").json()

    def delete(self, session_id: str, *, cancel_children: bool = False) -> None:
        """DELETE /v1/sessions/{session_id}"""
        suffix = f"?cancel_children={str(cancel_children).lower()}"
        self._client.delete(f"/v1/sessions/{session_id}{suffix}")

    def list(
        self,
        *,
        tier: int | None = None,
        status: str | None = None,
        parent_session_id: str | None = None,
        page: int = 1,
        per_page: int = 20,
    ) -> SyncPage:
        """GET /v1/sessions — list sessions (paginated)."""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        for k, v in {
            "tier": tier,
            "status": status,
            "parent_session_id": parent_session_id,
        }.items():
            if v is not None:
                params[k] = v
        data = self._client.get("/v1/sessions", params=params).json()
        raw_items: list[dict] = data.get("items", [])
        return SyncPage(
            items=raw_items,
            total=data.get("total", len(raw_items)),
            page=data.get("page", page),
            per_page=data.get("per_page", per_page),
            pages=data.get("pages", 1),
            client=self._client,
            method="GET",
            path="/v1/sessions",
            params=params,
            model=lambda x: x,
        )

    def hierarchy(self) -> dict:
        """GET /v1/sessions/hierarchy — full session tree."""
        return self._client.get("/v1/sessions/hierarchy").json()

    def info(self) -> dict:
        """GET /v1/sessions/info — session-system info."""
        return self._client.get("/v1/sessions/info").json()

    def stats(self) -> dict:
        """GET /v1/sessions/stats/summary — session statistics."""
        return self._client.get("/v1/sessions/stats/summary").json()

    def get_children(self, session_id: str, *, page: int = 1, per_page: int = 20) -> list:
        """GET /v1/sessions/{session_id}/children"""
        params: dict[str, Any] = {"page": page, "per_page": per_page}
        data = self._client.get(
            f"/v1/sessions/{session_id}/children", params=params
        ).json()
        return data if isinstance(data, list) else data.get("items", [])

    def aggregate_children(
        self,
        session_id: str,
        *,
        aggregation_mode: str = "summary",
    ) -> dict:
        """POST /v1/sessions/{session_id}/aggregate (``AggregateChildrenRequest``)."""
        body: dict[str, Any] = {"aggregation_mode": aggregation_mode}
        return self._client.post(
            f"/v1/sessions/{session_id}/aggregate", json=body
        ).json()


class AsyncSessions:
    """Asynchronous sessions resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def create(
        self,
        *,
        tier: int = 0,
        parent_session_id: str | None = None,
        system_instructions: str | None = None,
        **kwargs: Any,
    ) -> dict:
        """POST /v1/sessions — create a session (``SessionCreate``)."""
        body: dict[str, Any] = {"tier": tier}
        if parent_session_id is not None:
            body["parent_session_id"] = parent_session_id
        if system_instructions is not None:
            body["system_instructions"] = system_instructions
        body.update({k: v for k, v in kwargs.items() if v is not None})
        return (await self._client.post("/v1/sessions", json=body)).json()

    async def get(self, session_id: str) -> dict:
        """GET /v1/sessions/{session_id}"""
        return (await self._client.get(f"/v1/sessions/{session_id}")).json()

    async def delete(self, session_id: str, *, cancel_children: bool = False) -> None:
        """DELETE /v1/sessions/{session_id}"""
        suffix = f"?cancel_children={str(cancel_children).lower()}"
        await self._client.delete(f"/v1/sessions/{session_id}{suffix}")

    async def list(
        self,
        *,
        tier: int | None = None,
        status: str | None = None,
        parent_session_id: str | None = None,
        page: int = 1,
        per_page: int = 20,
    ) -> AsyncPage:
        """GET /v1/sessions — list sessions (paginated)."""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        for k, v in {
            "tier": tier,
            "status": status,
            "parent_session_id": parent_session_id,
        }.items():
            if v is not None:
                params[k] = v
        data = (await self._client.get("/v1/sessions", params=params)).json()
        raw_items: list[dict] = data.get("items", [])
        return AsyncPage(
            items=raw_items,
            total=data.get("total", len(raw_items)),
            page=data.get("page", page),
            per_page=data.get("per_page", per_page),
            pages=data.get("pages", 1),
            client=self._client,
            method="GET",
            path="/v1/sessions",
            params=params,
            model=lambda x: x,
        )

    async def hierarchy(self) -> dict:
        """GET /v1/sessions/hierarchy — full session tree."""
        return (await self._client.get("/v1/sessions/hierarchy")).json()

    async def info(self) -> dict:
        """GET /v1/sessions/info — session-system info."""
        return (await self._client.get("/v1/sessions/info")).json()

    async def stats(self) -> dict:
        """GET /v1/sessions/stats/summary — session statistics."""
        return (await self._client.get("/v1/sessions/stats/summary")).json()

    async def get_children(
        self, session_id: str, *, page: int = 1, per_page: int = 20
    ) -> list:
        """GET /v1/sessions/{session_id}/children"""
        params: dict[str, Any] = {"page": page, "per_page": per_page}
        data = (
            await self._client.get(
                f"/v1/sessions/{session_id}/children", params=params
            )
        ).json()
        return data if isinstance(data, list) else data.get("items", [])

    async def aggregate_children(
        self,
        session_id: str,
        *,
        aggregation_mode: str = "summary",
    ) -> dict:
        """POST /v1/sessions/{session_id}/aggregate (``AggregateChildrenRequest``)."""
        body: dict[str, Any] = {"aggregation_mode": aggregation_mode}
        return (
            await self._client.post(
                f"/v1/sessions/{session_id}/aggregate", json=body
            )
        ).json()
