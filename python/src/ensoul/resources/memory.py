"""Memory resource for the Ensoul SDK.

Maps to the ``/v1/memory/*`` API namespace. As of API 0.2.0 the memory routes
were rebased off ``/v1/personas/{id}/memories`` onto ``/v1/memory/{persona_id}``;
see ``sdks/openapi/namespace-migration-contract.md``.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient

__all__ = [
    "Memory",
    "AsyncMemory",
]


class Memory:
    """Synchronous memory resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def stats(self) -> dict:
        """GET /v1/memory/stats — global memory statistics."""
        return self._client.get("/v1/memory/stats").json()

    def create(
        self,
        persona_id: str,
        *,
        content: str,
        source: str = "user",
        references: dict | None = None,
    ) -> dict:
        """POST /v1/memory/{persona_id} — add a memory (``MemoryCreate``)."""
        body: dict[str, Any] = {"content": content, "source": source}
        if references is not None:
            body["references"] = references
        return self._client.post(f"/v1/memory/{persona_id}", json=body).json()

    def list(
        self,
        persona_id: str,
        *,
        limit: int = 50,
        offset: int = 0,
    ) -> dict:
        """GET /v1/memory/{persona_id} — list memories.

        Returns the ``MemoriesResponse`` shape
        ``{persona_id, memories, working_memory, total}`` (not a paginated
        envelope — the API does not page this route).
        """
        params: dict[str, Any] = {"limit": limit, "offset": offset}
        return self._client.get(f"/v1/memory/{persona_id}", params=params).json()

    def clear(self, persona_id: str) -> None:
        """DELETE /v1/memory/{persona_id} — delete all memories for a persona."""
        self._client.delete(f"/v1/memory/{persona_id}")

    def delete(self, persona_id: str, memory_id: str) -> None:
        """DELETE /v1/memory/{persona_id}/{memory_id} — delete one memory."""
        self._client.delete(f"/v1/memory/{persona_id}/{memory_id}")

    def update_access(self, persona_id: str, memory_id: str) -> dict:
        """PATCH /v1/memory/{persona_id}/{memory_id}/access — record an access."""
        return self._client.patch(
            f"/v1/memory/{persona_id}/{memory_id}/access"
        ).json()

    def batch_create(self, persona_id: str, memories: list[dict]) -> dict:
        """POST /v1/memory/{persona_id}/batch — add many memories at once."""
        return self._client.post(
            f"/v1/memory/{persona_id}/batch",
            json={"memories": memories},
        ).json()

    def consolidate(self, persona_id: str) -> dict:
        """POST /v1/memory/{persona_id}/consolidate — consolidate memories."""
        return self._client.post(
            f"/v1/memory/{persona_id}/consolidate", json={}
        ).json()

    def generate(self, persona_id: str, **kwargs: Any) -> dict:
        """POST /v1/memory/{persona_id}/generate — generate memories."""
        return self._client.post(
            f"/v1/memory/{persona_id}/generate", json=dict(kwargs)
        ).json()

    def working(self, persona_id: str) -> dict:
        """GET /v1/memory/{persona_id}/working — working-memory snapshot."""
        return self._client.get(f"/v1/memory/{persona_id}/working").json()

    def get_knowledge(self, persona_id: str) -> dict:
        """GET /v1/memory/{persona_id}/knowledge — retrieve RAG knowledge."""
        return self._client.get(f"/v1/memory/{persona_id}/knowledge").json()

    def add_knowledge(self, persona_id: str, *, content: str, source: str) -> dict:
        """POST /v1/memory/{persona_id}/knowledge — add RAG knowledge (``KnowledgeCreate``)."""
        return self._client.post(
            f"/v1/memory/{persona_id}/knowledge",
            json={"content": content, "source": source},
        ).json()


class AsyncMemory:
    """Asynchronous memory resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def stats(self) -> dict:
        """GET /v1/memory/stats — global memory statistics."""
        return (await self._client.get("/v1/memory/stats")).json()

    async def create(
        self,
        persona_id: str,
        *,
        content: str,
        source: str = "user",
        references: dict | None = None,
    ) -> dict:
        """POST /v1/memory/{persona_id} — add a memory (``MemoryCreate``)."""
        body: dict[str, Any] = {"content": content, "source": source}
        if references is not None:
            body["references"] = references
        return (await self._client.post(f"/v1/memory/{persona_id}", json=body)).json()

    async def list(
        self,
        persona_id: str,
        *,
        limit: int = 50,
        offset: int = 0,
    ) -> dict:
        """GET /v1/memory/{persona_id} — list memories (``MemoriesResponse``)."""
        params: dict[str, Any] = {"limit": limit, "offset": offset}
        return (await self._client.get(f"/v1/memory/{persona_id}", params=params)).json()

    async def clear(self, persona_id: str) -> None:
        """DELETE /v1/memory/{persona_id} — delete all memories for a persona."""
        await self._client.delete(f"/v1/memory/{persona_id}")

    async def delete(self, persona_id: str, memory_id: str) -> None:
        """DELETE /v1/memory/{persona_id}/{memory_id} — delete one memory."""
        await self._client.delete(f"/v1/memory/{persona_id}/{memory_id}")

    async def update_access(self, persona_id: str, memory_id: str) -> dict:
        """PATCH /v1/memory/{persona_id}/{memory_id}/access — record an access."""
        return (
            await self._client.patch(f"/v1/memory/{persona_id}/{memory_id}/access")
        ).json()

    async def batch_create(self, persona_id: str, memories: list[dict]) -> dict:
        """POST /v1/memory/{persona_id}/batch — add many memories at once."""
        return (
            await self._client.post(
                f"/v1/memory/{persona_id}/batch", json={"memories": memories}
            )
        ).json()

    async def consolidate(self, persona_id: str) -> dict:
        """POST /v1/memory/{persona_id}/consolidate — consolidate memories."""
        return (
            await self._client.post(f"/v1/memory/{persona_id}/consolidate", json={})
        ).json()

    async def generate(self, persona_id: str, **kwargs: Any) -> dict:
        """POST /v1/memory/{persona_id}/generate — generate memories."""
        return (
            await self._client.post(
                f"/v1/memory/{persona_id}/generate", json=dict(kwargs)
            )
        ).json()

    async def working(self, persona_id: str) -> dict:
        """GET /v1/memory/{persona_id}/working — working-memory snapshot."""
        return (await self._client.get(f"/v1/memory/{persona_id}/working")).json()

    async def get_knowledge(self, persona_id: str) -> dict:
        """GET /v1/memory/{persona_id}/knowledge — retrieve RAG knowledge."""
        return (await self._client.get(f"/v1/memory/{persona_id}/knowledge")).json()

    async def add_knowledge(self, persona_id: str, *, content: str, source: str) -> dict:
        """POST /v1/memory/{persona_id}/knowledge — add RAG knowledge (``KnowledgeCreate``)."""
        return (
            await self._client.post(
                f"/v1/memory/{persona_id}/knowledge",
                json={"content": content, "source": source},
            )
        ).json()
