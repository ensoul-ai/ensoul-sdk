"""Authentication strategies for the Ensoul SDK."""

from __future__ import annotations

import time
from typing import Protocol, runtime_checkable

__all__ = [
    "AuthProvider",
    "APIKeyAuth",
    "BearerAuth",
]


@runtime_checkable
class AuthProvider(Protocol):
    """Protocol for auth strategies that produce request headers."""

    def auth_headers(self) -> dict[str, str]:
        """Return headers required to authenticate a request."""
        ...


class APIKeyAuth:
    """API key authentication via X-API-Key header."""

    def __init__(self, api_key: str) -> None:
        self._api_key = api_key

    def auth_headers(self) -> dict[str, str]:
        return {"X-API-Key": self._api_key}


class BearerAuth:
    """OAuth2 JWT authentication with token state tracking.

    The actual refresh HTTP call is performed by the HTTP client layer, not here.
    This class tracks token state and expiry only.
    """

    # Refresh proactively this many seconds before actual expiry
    _REFRESH_BUFFER_SECONDS = 60.0

    def __init__(
        self,
        access_token: str,
        refresh_token: str | None = None,
        expires_at: float | None = None,
    ) -> None:
        self.access_token = access_token
        self.refresh_token = refresh_token
        self.expires_at = expires_at  # Unix timestamp

    def auth_headers(self) -> dict[str, str]:
        return {"Authorization": f"Bearer {self.access_token}"}

    def is_expired(self) -> bool:
        """True if the access token has already expired."""
        if self.expires_at is None:
            return False
        return time.time() >= self.expires_at

    def needs_refresh(self) -> bool:
        """True if the token expires within 60 seconds (or is already expired)."""
        if self.expires_at is None:
            return False
        return time.time() >= (self.expires_at - self._REFRESH_BUFFER_SECONDS)
