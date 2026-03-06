"""Memory resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage

__all__ = [
    "Memory",
    "AsyncMemory",
]


class Memory:
    """Synchronous memory resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def create(
        self,
        persona_id: str,
        *,
        content: str,
        memory_type: str = "episodic",
        importance: float = 0.5,
        metadata: dict | None = None,
    ) -> dict:
        """POST /v1/personas/{persona_id}/memories"""
        body: dict[str, Any] = {
            "content": content,
            "memory_type": memory_type,
            "importance": importance,
        }
        if metadata is not None:
            body["metadata"] = metadata
        response = self._client.post(f"/v1/personas/{persona_id}/memories", json=body)
        return response.json()

    def list(
        self,
        persona_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> SyncPage:
        """GET /v1/personas/{persona_id}/memories"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = self._client.get(f"/v1/personas/{persona_id}/memories", params=params)
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
            path=f"/v1/personas/{persona_id}/memories",
            params=params,
            model=lambda x: x,
        )

    def get(self, persona_id: str, memory_id: str) -> dict:
        """GET /v1/personas/{persona_id}/memories/{memory_id}"""
        response = self._client.get(f"/v1/personas/{persona_id}/memories/{memory_id}")
        return response.json()

    def delete(self, persona_id: str, memory_id: str) -> None:
        """DELETE /v1/personas/{persona_id}/memories/{memory_id}"""
        self._client.delete(f"/v1/personas/{persona_id}/memories/{memory_id}")

    def batch_create(self, persona_id: str, memories: list[dict]) -> dict:
        """POST /v1/personas/{persona_id}/memories/batch"""
        response = self._client.post(
            f"/v1/personas/{persona_id}/memories/batch",
            json={"memories": memories},
        )
        return response.json()

    def consolidate(self, persona_id: str) -> dict:
        """POST /v1/personas/{persona_id}/memories/consolidate"""
        response = self._client.post(f"/v1/personas/{persona_id}/memories/consolidate", json={})
        return response.json()

    def query_knowledge(self, persona_id: str, query: str) -> dict:
        """POST /v1/personas/{persona_id}/knowledge/query"""
        response = self._client.post(
            f"/v1/personas/{persona_id}/knowledge/query",
            json={"query": query},
        )
        return response.json()


class AsyncMemory:
    """Asynchronous memory resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def create(
        self,
        persona_id: str,
        *,
        content: str,
        memory_type: str = "episodic",
        importance: float = 0.5,
        metadata: dict | None = None,
    ) -> dict:
        """POST /v1/personas/{persona_id}/memories"""
        body: dict[str, Any] = {
            "content": content,
            "memory_type": memory_type,
            "importance": importance,
        }
        if metadata is not None:
            body["metadata"] = metadata
        response = await self._client.post(f"/v1/personas/{persona_id}/memories", json=body)
        return response.json()

    async def list(
        self,
        persona_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> AsyncPage:
        """GET /v1/personas/{persona_id}/memories"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = await self._client.get(f"/v1/personas/{persona_id}/memories", params=params)
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
            path=f"/v1/personas/{persona_id}/memories",
            params=params,
            model=lambda x: x,
        )

    async def get(self, persona_id: str, memory_id: str) -> dict:
        """GET /v1/personas/{persona_id}/memories/{memory_id}"""
        response = await self._client.get(f"/v1/personas/{persona_id}/memories/{memory_id}")
        return response.json()

    async def delete(self, persona_id: str, memory_id: str) -> None:
        """DELETE /v1/personas/{persona_id}/memories/{memory_id}"""
        await self._client.delete(f"/v1/personas/{persona_id}/memories/{memory_id}")

    async def batch_create(self, persona_id: str, memories: list[dict]) -> dict:
        """POST /v1/personas/{persona_id}/memories/batch"""
        response = await self._client.post(
            f"/v1/personas/{persona_id}/memories/batch",
            json={"memories": memories},
        )
        return response.json()

    async def consolidate(self, persona_id: str) -> dict:
        """POST /v1/personas/{persona_id}/memories/consolidate"""
        response = await self._client.post(f"/v1/personas/{persona_id}/memories/consolidate", json={})
        return response.json()

    async def query_knowledge(self, persona_id: str, query: str) -> dict:
        """POST /v1/personas/{persona_id}/knowledge/query"""
        response = await self._client.post(
            f"/v1/personas/{persona_id}/knowledge/query",
            json={"query": query},
        )
        return response.json()
