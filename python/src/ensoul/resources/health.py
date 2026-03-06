"""Health resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient

__all__ = [
    "Health",
    "AsyncHealth",
]


class Health:
    """Synchronous health resource.

    Health endpoints live at /health (no /v1/ prefix).
    Uses get_raw() to skip /v1/ normalization while retaining auth and SDK error mapping.
    """

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def check(self) -> dict:
        """GET /health — general health check."""
        return self._client.get_raw("/health").json()

    def ready(self) -> dict:
        """GET /health/ready — readiness check."""
        return self._client.get_raw("/health/ready").json()

    def live(self) -> dict:
        """GET /health/live — liveness check."""
        return self._client.get_raw("/health/live").json()


class AsyncHealth:
    """Asynchronous health resource.

    Health endpoints live at /health (no /v1/ prefix).
    Uses get_raw() to skip /v1/ normalization while retaining auth and SDK error mapping.
    """

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def check(self) -> dict:
        """GET /health — general health check."""
        return (await self._client.get_raw("/health")).json()

    async def ready(self) -> dict:
        """GET /health/ready — readiness check."""
        return (await self._client.get_raw("/health/ready")).json()

    async def live(self) -> dict:
        """GET /health/live — liveness check."""
        return (await self._client.get_raw("/health/live")).json()
