"""Info resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient

__all__ = [
    "Info",
    "AsyncInfo",
]


class Info:
    """Synchronous info resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def config(self) -> dict:
        """GET /v1/info/config — API configuration."""
        response = self._client.get("/v1/info/config")
        return response.json()

    def rate_limits(self) -> dict:
        """GET /v1/info/rate-limits — rate limit details for current tier."""
        response = self._client.get("/v1/info/rate-limits")
        return response.json()

    def tiers(self) -> dict:
        """GET /v1/info/tiers — access tier definitions."""
        response = self._client.get("/v1/info/tiers")
        return response.json()

    def features(self) -> dict:
        """GET /v1/info/features — feature flags."""
        response = self._client.get("/v1/info/features")
        return response.json()


class AsyncInfo:
    """Asynchronous info resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def config(self) -> dict:
        """GET /v1/info/config — API configuration."""
        response = await self._client.get("/v1/info/config")
        return response.json()

    async def rate_limits(self) -> dict:
        """GET /v1/info/rate-limits — rate limit details for current tier."""
        response = await self._client.get("/v1/info/rate-limits")
        return response.json()

    async def tiers(self) -> dict:
        """GET /v1/info/tiers — access tier definitions."""
        response = await self._client.get("/v1/info/tiers")
        return response.json()

    async def features(self) -> dict:
        """GET /v1/info/features — feature flags."""
        response = await self._client.get("/v1/info/features")
        return response.json()
