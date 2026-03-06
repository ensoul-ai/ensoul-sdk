"""Domains resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage

__all__ = [
    "Domains",
    "AsyncDomains",
]


class Domains:
    """Synchronous domains resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def list(self, *, page: int = 1, per_page: int = 20, **kwargs: Any) -> SyncPage[dict]:
        """GET /v1/domains"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = self._client.get("/v1/domains", params=params)
        data = response.json()
        return SyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data["per_page"],
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/domains",
            params=params,
            model=dict,
        )

    def get(self, domain_id: str) -> dict[str, Any]:
        """GET /v1/domains/{domain_id}"""
        response = self._client.get(f"/v1/domains/{domain_id}")
        return response.json()

    def create(self, **kwargs: Any) -> dict[str, Any]:
        """POST /v1/domains"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = self._client.post("/v1/domains", json=body)
        return response.json()

    def update(self, domain_id: str, **kwargs: Any) -> dict[str, Any]:
        """PUT /v1/domains/{domain_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = self._client.put(f"/v1/domains/{domain_id}", json=body)
        return response.json()

    def delete(self, domain_id: str) -> None:
        """DELETE /v1/domains/{domain_id}"""
        self._client.delete(f"/v1/domains/{domain_id}")

    def validate(self, domain_id: str) -> dict[str, Any]:
        """POST /v1/domains/{domain_id}/validate"""
        response = self._client.post(f"/v1/domains/{domain_id}/validate", json={})
        return response.json()


class AsyncDomains:
    """Async version of the domains resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def list(
        self, *, page: int = 1, per_page: int = 20, **kwargs: Any
    ) -> AsyncPage[dict]:
        """GET /v1/domains"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = await self._client.get("/v1/domains", params=params)
        data = response.json()
        return AsyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data["per_page"],
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/domains",
            params=params,
            model=dict,
        )

    async def get(self, domain_id: str) -> dict[str, Any]:
        """GET /v1/domains/{domain_id}"""
        response = await self._client.get(f"/v1/domains/{domain_id}")
        return response.json()

    async def create(self, **kwargs: Any) -> dict[str, Any]:
        """POST /v1/domains"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = await self._client.post("/v1/domains", json=body)
        return response.json()

    async def update(self, domain_id: str, **kwargs: Any) -> dict[str, Any]:
        """PUT /v1/domains/{domain_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = await self._client.put(f"/v1/domains/{domain_id}", json=body)
        return response.json()

    async def delete(self, domain_id: str) -> None:
        """DELETE /v1/domains/{domain_id}"""
        await self._client.delete(f"/v1/domains/{domain_id}")

    async def validate(self, domain_id: str) -> dict[str, Any]:
        """POST /v1/domains/{domain_id}/validate"""
        response = await self._client.post(
            f"/v1/domains/{domain_id}/validate", json={}
        )
        return response.json()
