"""Sessions resource for the Ensoul SDK."""

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
        persona_id: str,
        *,
        tier: int = 0,
        parent_session_id: str | None = None,
        system_instructions: str | None = None,
        **kwargs: Any,
    ) -> dict:
        """POST /v1/personas/{persona_id}/sessions"""
        body: dict[str, Any] = {"tier": tier}
        if parent_session_id is not None:
            body["parent_session_id"] = parent_session_id
        if system_instructions is not None:
            body["system_instructions"] = system_instructions
        body.update({k: v for k, v in kwargs.items() if v is not None})
        response = self._client.post(f"/v1/personas/{persona_id}/sessions", json=body)
        return response.json()

    def get(self, persona_id: str, session_id: str) -> dict:
        """GET /v1/personas/{persona_id}/sessions/{session_id}"""
        response = self._client.get(f"/v1/personas/{persona_id}/sessions/{session_id}")
        return response.json()

    def list(
        self,
        persona_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> SyncPage:
        """GET /v1/personas/{persona_id}/sessions"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = self._client.get(f"/v1/personas/{persona_id}/sessions", params=params)
        data = response.json()
        raw_items: list[dict] = data.get("items", [])
        return SyncPage(
            items=raw_items,
            total=data.get("total", len(raw_items)),
            page=data.get("page", page),
            per_page=data.get("per_page", per_page),
            pages=data.get("pages", 1),
            client=self._client,
            method="GET",
            path=f"/v1/personas/{persona_id}/sessions",
            params=params,
            model=lambda x: x,
        )

    def get_children(self, persona_id: str, session_id: str) -> list:
        """GET /v1/personas/{persona_id}/sessions/{session_id}/children"""
        response = self._client.get(
            f"/v1/personas/{persona_id}/sessions/{session_id}/children"
        )
        data = response.json()
        return data if isinstance(data, list) else data.get("items", [])

    def aggregate_children(
        self,
        persona_id: str,
        session_id: str,
        *,
        aggregation_mode: str = "summary",
    ) -> dict:
        """POST /v1/personas/{persona_id}/sessions/{session_id}/aggregate"""
        body: dict[str, Any] = {"aggregation_mode": aggregation_mode}
        response = self._client.post(
            f"/v1/personas/{persona_id}/sessions/{session_id}/aggregate",
            json=body,
        )
        return response.json()


class AsyncSessions:
    """Asynchronous sessions resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def create(
        self,
        persona_id: str,
        *,
        tier: int = 0,
        parent_session_id: str | None = None,
        system_instructions: str | None = None,
        **kwargs: Any,
    ) -> dict:
        """POST /v1/personas/{persona_id}/sessions"""
        body: dict[str, Any] = {"tier": tier}
        if parent_session_id is not None:
            body["parent_session_id"] = parent_session_id
        if system_instructions is not None:
            body["system_instructions"] = system_instructions
        body.update({k: v for k, v in kwargs.items() if v is not None})
        response = await self._client.post(f"/v1/personas/{persona_id}/sessions", json=body)
        return response.json()

    async def get(self, persona_id: str, session_id: str) -> dict:
        """GET /v1/personas/{persona_id}/sessions/{session_id}"""
        response = await self._client.get(f"/v1/personas/{persona_id}/sessions/{session_id}")
        return response.json()

    async def list(
        self,
        persona_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> AsyncPage:
        """GET /v1/personas/{persona_id}/sessions"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = await self._client.get(f"/v1/personas/{persona_id}/sessions", params=params)
        data = response.json()
        raw_items: list[dict] = data.get("items", [])
        return AsyncPage(
            items=raw_items,
            total=data.get("total", len(raw_items)),
            page=data.get("page", page),
            per_page=data.get("per_page", per_page),
            pages=data.get("pages", 1),
            client=self._client,
            method="GET",
            path=f"/v1/personas/{persona_id}/sessions",
            params=params,
            model=lambda x: x,
        )

    async def get_children(self, persona_id: str, session_id: str) -> list:
        """GET /v1/personas/{persona_id}/sessions/{session_id}/children"""
        response = await self._client.get(
            f"/v1/personas/{persona_id}/sessions/{session_id}/children"
        )
        data = response.json()
        return data if isinstance(data, list) else data.get("items", [])

    async def aggregate_children(
        self,
        persona_id: str,
        session_id: str,
        *,
        aggregation_mode: str = "summary",
    ) -> dict:
        """POST /v1/personas/{persona_id}/sessions/{session_id}/aggregate"""
        body: dict[str, Any] = {"aggregation_mode": aggregation_mode}
        response = await self._client.post(
            f"/v1/personas/{persona_id}/sessions/{session_id}/aggregate",
            json=body,
        )
        return response.json()
