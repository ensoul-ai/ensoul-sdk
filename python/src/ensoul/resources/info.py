"""Info resource for the Ensoul SDK.

As of API 0.2.0 the four ``/v1/info/*`` routes were replaced by a single
``GET /v1/api/info`` returning an ``APIInfoResponse`` blob. The convenience
methods below each fetch that blob and return their relevant sub-section, so
existing call sites keep working without four separate round-trips becoming
four copies of the same payload. See
``sdks/openapi/namespace-migration-contract.md``.
"""

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

    def get(self) -> dict:
        """GET /v1/api/info — full server info (``APIInfoResponse``)."""
        return self._client.get("/v1/api/info").json()

    def config(self) -> dict:
        """Full server configuration blob (alias for :meth:`get`)."""
        return self.get()

    def rate_limits(self) -> dict:
        """Rate-limiting configuration sub-section."""
        return self.get().get("rate_limiting", {})

    def tiers(self) -> list:
        """Access-tier definitions sub-section."""
        return self.get().get("access_tiers", [])

    def features(self) -> dict:
        """Feature-flags sub-section."""
        return self.get().get("features", {})


class AsyncInfo:
    """Asynchronous info resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def get(self) -> dict:
        """GET /v1/api/info — full server info (``APIInfoResponse``)."""
        return (await self._client.get("/v1/api/info")).json()

    async def config(self) -> dict:
        """Full server configuration blob (alias for :meth:`get`)."""
        return await self.get()

    async def rate_limits(self) -> dict:
        """Rate-limiting configuration sub-section."""
        return (await self.get()).get("rate_limiting", {})

    async def tiers(self) -> list:
        """Access-tier definitions sub-section."""
        return (await self.get()).get("access_tiers", [])

    async def features(self) -> dict:
        """Feature-flags sub-section."""
        return (await self.get()).get("features", {})
