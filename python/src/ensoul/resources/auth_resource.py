"""Auth resource for the Ensoul SDK.

Named auth_resource.py to avoid conflict with the transport auth.py module.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

from ensoul.errors import raise_for_status
from ensoul.generated.auth import APIKeyResponse, TokenResponse, UserResponse

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient

__all__ = [
    "AuthResource",
    "AsyncAuthResource",
]


class AuthResource:
    """Synchronous auth resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def token(self, username: str, password: str) -> TokenResponse:
        """POST /v1/auth/token — OAuth2 password flow (form-encoded).

        This endpoint uses application/x-www-form-urlencoded, not JSON.
        Accesses the underlying httpx client directly for form encoding.
        """
        response = self._client._client.post(
            "/v1/auth/token",
            data={"username": username, "password": password, "grant_type": "password"},
            headers={**self._client._auth.auth_headers()},
        )
        raise_for_status(response)
        return TokenResponse.model_validate(response.json())

    def refresh(self, refresh_token: str) -> TokenResponse:
        """POST /v1/auth/refresh — exchange refresh token for new JWT."""
        body: dict[str, Any] = {"refresh_token": refresh_token, "grant_type": "refresh_token"}
        response = self._client.post("/v1/auth/refresh", json=body)
        return TokenResponse.model_validate(response.json())

    def me(self) -> UserResponse:
        """GET /v1/auth/me — current authenticated user."""
        response = self._client.get("/v1/auth/me")
        return UserResponse.model_validate(response.json())

    def create_api_key(self, name: str, *, expires_days: int = 365, scopes: list[str] | None = None) -> APIKeyResponse:
        """POST /v1/api-keys — create a new API key."""
        body: dict[str, Any] = {"name": name, "expires_days": expires_days}
        if scopes is not None:
            body["scopes"] = scopes
        response = self._client.post("/v1/api-keys", json=body)
        return APIKeyResponse.model_validate(response.json())

    def list_api_keys(self) -> list[APIKeyResponse]:
        """GET /v1/api-keys — list all API keys."""
        response = self._client.get("/v1/api-keys")
        data = response.json()
        items = data if isinstance(data, list) else data.get("items", [])
        return [APIKeyResponse.model_validate(item) for item in items]

    def revoke_api_key(self, key_id: str) -> None:
        """DELETE /v1/api-keys/{key_id}"""
        self._client.delete(f"/v1/api-keys/{key_id}")


class AsyncAuthResource:
    """Asynchronous auth resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def token(self, username: str, password: str) -> TokenResponse:
        """POST /v1/auth/token — OAuth2 password flow (form-encoded).

        This endpoint uses application/x-www-form-urlencoded, not JSON.
        Accesses the underlying httpx client directly for form encoding.
        """
        response = await self._client._client.post(
            "/v1/auth/token",
            data={"username": username, "password": password, "grant_type": "password"},
            headers={**self._client._auth.auth_headers()},
        )
        raise_for_status(response)
        return TokenResponse.model_validate(response.json())

    async def refresh(self, refresh_token: str) -> TokenResponse:
        """POST /v1/auth/refresh — exchange refresh token for new JWT."""
        body: dict[str, Any] = {"refresh_token": refresh_token, "grant_type": "refresh_token"}
        response = await self._client.post("/v1/auth/refresh", json=body)
        return TokenResponse.model_validate(response.json())

    async def me(self) -> UserResponse:
        """GET /v1/auth/me — current authenticated user."""
        response = await self._client.get("/v1/auth/me")
        return UserResponse.model_validate(response.json())

    async def create_api_key(self, name: str, *, expires_days: int = 365, scopes: list[str] | None = None) -> APIKeyResponse:
        """POST /v1/api-keys — create a new API key."""
        body: dict[str, Any] = {"name": name, "expires_days": expires_days}
        if scopes is not None:
            body["scopes"] = scopes
        response = await self._client.post("/v1/api-keys", json=body)
        return APIKeyResponse.model_validate(response.json())

    async def list_api_keys(self) -> list[APIKeyResponse]:
        """GET /v1/api-keys — list all API keys."""
        response = await self._client.get("/v1/api-keys")
        data = response.json()
        items = data if isinstance(data, list) else data.get("items", [])
        return [APIKeyResponse.model_validate(item) for item in items]

    async def revoke_api_key(self, key_id: str) -> None:
        """DELETE /v1/api-keys/{key_id}"""
        await self._client.delete(f"/v1/api-keys/{key_id}")
