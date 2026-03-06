"""Frameworks resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage

__all__ = [
    "Frameworks",
    "AsyncFrameworks",
]


class Frameworks:
    """Synchronous frameworks resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def list(
        self,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> SyncPage:
        """GET /v1/frameworks"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = self._client.get("/v1/frameworks", params=params)
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
            path="/v1/frameworks",
            params=params,
            model=lambda x: x,
        )

    def get(self, framework_id: str) -> dict:
        """GET /v1/frameworks/{framework_id}"""
        response = self._client.get(f"/v1/frameworks/{framework_id}")
        return response.json()

    def create(self, **kwargs: Any) -> dict:
        """POST /v1/frameworks"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = self._client.post("/v1/frameworks", json=body)
        return response.json()

    def update(self, framework_id: str, **kwargs: Any) -> dict:
        """PUT /v1/frameworks/{framework_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = self._client.put(f"/v1/frameworks/{framework_id}", json=body)
        return response.json()

    def delete(self, framework_id: str) -> None:
        """DELETE /v1/frameworks/{framework_id}"""
        self._client.delete(f"/v1/frameworks/{framework_id}")

    def validate(self, framework_id: str) -> dict:
        """POST /v1/frameworks/{framework_id}/validate"""
        response = self._client.post(f"/v1/frameworks/{framework_id}/validate", json={})
        return response.json()

    def get_instruments(self, framework_id: str) -> list:
        """GET /v1/frameworks/{framework_id}/instruments"""
        response = self._client.get(f"/v1/frameworks/{framework_id}/instruments")
        data = response.json()
        return data if isinstance(data, list) else data.get("items", [])


class AsyncFrameworks:
    """Asynchronous frameworks resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def list(
        self,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> AsyncPage:
        """GET /v1/frameworks"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = await self._client.get("/v1/frameworks", params=params)
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
            path="/v1/frameworks",
            params=params,
            model=lambda x: x,
        )

    async def get(self, framework_id: str) -> dict:
        """GET /v1/frameworks/{framework_id}"""
        response = await self._client.get(f"/v1/frameworks/{framework_id}")
        return response.json()

    async def create(self, **kwargs: Any) -> dict:
        """POST /v1/frameworks"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = await self._client.post("/v1/frameworks", json=body)
        return response.json()

    async def update(self, framework_id: str, **kwargs: Any) -> dict:
        """PUT /v1/frameworks/{framework_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = await self._client.put(f"/v1/frameworks/{framework_id}", json=body)
        return response.json()

    async def delete(self, framework_id: str) -> None:
        """DELETE /v1/frameworks/{framework_id}"""
        await self._client.delete(f"/v1/frameworks/{framework_id}")

    async def validate(self, framework_id: str) -> dict:
        """POST /v1/frameworks/{framework_id}/validate"""
        response = await self._client.post(f"/v1/frameworks/{framework_id}/validate", json={})
        return response.json()

    async def get_instruments(self, framework_id: str) -> list:
        """GET /v1/frameworks/{framework_id}/instruments"""
        response = await self._client.get(f"/v1/frameworks/{framework_id}/instruments")
        data = response.json()
        return data if isinstance(data, list) else data.get("items", [])
