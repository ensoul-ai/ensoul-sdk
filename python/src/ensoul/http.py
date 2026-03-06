"""HTTP transport layer for the Ensoul SDK."""

from __future__ import annotations

import random
import time

import httpx

from ensoul._types import HeadersLike, QueryParams
from ensoul.auth import APIKeyAuth, AuthProvider, BearerAuth
from ensoul.config import API_VERSION, ClientConfig
from ensoul.errors import RateLimitError, raise_for_status
from ensoul.rate_limit import RateLimitTracker
from ensoul.streaming import AsyncSSEStream, SyncSSEStream

__all__ = [
    "SyncHTTPClient",
    "AsyncHTTPClient",
]

_RETRY_STATUS_CODES = {429, 500, 502, 503}
_SDK_USER_AGENT = "ensoul-python/0.1.0"


def _build_auth(config: ClientConfig) -> AuthProvider:
    if config.api_key is not None:
        return APIKeyAuth(config.api_key)
    if config.bearer_token is not None:
        return BearerAuth(access_token=config.bearer_token)
    # No credentials — requests will still go through (server decides)
    return APIKeyAuth("")


def _normalize_path(path: str) -> str:
    """Ensure path starts with /v1/. Handles paths with or without leading slash."""
    if path.startswith(f"/{API_VERSION}/") or path.startswith(f"{API_VERSION}/"):
        return path if path.startswith("/") else f"/{path}"
    path = path.lstrip("/")
    return f"/{API_VERSION}/{path}"


def _retry_wait(attempt: int, retry_after: float | None) -> float:
    """Compute seconds to wait before the next retry attempt.

    Uses the Retry-After header when available; otherwise exponential backoff
    with jitter: base * 2^attempt + random(0, 1).
    """
    if retry_after is not None and retry_after > 0:
        return retry_after
    base_wait = min(0.5 * (2 ** attempt), 30.0)
    jitter = random.uniform(0.0, 1.0)
    return base_wait + jitter


class SyncHTTPClient:
    """Synchronous HTTP transport client."""

    def __init__(self, config: ClientConfig) -> None:
        self._config = config
        self._auth: AuthProvider = _build_auth(config)
        self._rate_limiter = RateLimitTracker()

        default_headers: dict[str, str] = {
            "User-Agent": _SDK_USER_AGENT,
            "Accept": "application/json",
            **config.custom_headers,
        }
        self._client = httpx.Client(
            base_url=config.base_url,
            timeout=config.timeout,
            headers=default_headers,
            follow_redirects=True,
        )

    def request(
        self,
        method: str,
        path: str,
        *,
        json: dict | None = None,
        params: QueryParams | None = None,
        headers: HeadersLike | None = None,
        stream: bool = False,
    ) -> httpx.Response:
        """Make an authenticated HTTP request with retries and rate limit handling."""
        path = _normalize_path(path)
        last_exc: Exception | None = None

        for attempt in range(self._config.max_retries + 1):
            # Wait if rate limit is exhausted before sending
            should_wait, wait_seconds = self._rate_limiter.should_wait()
            if should_wait:
                time.sleep(wait_seconds)

            req_headers: dict[str, str] = {**self._auth.auth_headers()}
            if headers:
                req_headers.update(headers)

            try:
                if stream:
                    response = self._client.send(
                        self._client.build_request(
                            method,
                            path,
                            json=json,
                            params=params,
                            headers=req_headers,
                        ),
                        stream=True,
                    )
                else:
                    response = self._client.request(
                        method,
                        path,
                        json=json,
                        params=params,
                        headers=req_headers,
                    )

                self._rate_limiter.update(response)

                if response.status_code in _RETRY_STATUS_CODES and attempt < self._config.max_retries:
                    retry_after: float | None = None
                    if response.status_code == 429:
                        raw = response.headers.get("Retry-After")
                        if raw is not None:
                            try:
                                retry_after = float(raw)
                            except ValueError:
                                pass
                    wait = _retry_wait(attempt, retry_after)
                    time.sleep(wait)
                    continue

                raise_for_status(response)
                return response

            except RateLimitError:
                raise
            except httpx.TimeoutException as exc:
                last_exc = exc
                if attempt < self._config.max_retries:
                    time.sleep(_retry_wait(attempt, None))
                    continue
                raise
            except httpx.TransportError as exc:
                last_exc = exc
                if attempt < self._config.max_retries:
                    time.sleep(_retry_wait(attempt, None))
                    continue
                raise

        # Should not be reached; satisfy type checker
        if last_exc is not None:
            raise last_exc
        raise RuntimeError("Exhausted retries without a response")

    def get(self, path: str, *, params: QueryParams | None = None) -> httpx.Response:
        return self.request("GET", path, params=params)

    def get_raw(self, path: str, *, params: QueryParams | None = None) -> httpx.Response:
        """GET without /v1/ prefix normalization — for paths like /health."""
        req_headers: dict[str, str] = {**self._auth.auth_headers()}
        response = self._client.request("GET", path, params=params, headers=req_headers)
        raise_for_status(response)
        return response

    def post(self, path: str, *, json: dict | None = None, params: QueryParams | None = None) -> httpx.Response:
        return self.request("POST", path, json=json, params=params)

    def put(self, path: str, *, json: dict | None = None) -> httpx.Response:
        return self.request("PUT", path, json=json)

    def patch(self, path: str, *, json: dict | None = None) -> httpx.Response:
        return self.request("PATCH", path, json=json)

    def delete(self, path: str) -> httpx.Response:
        return self.request("DELETE", path)

    def stream_sse(
        self,
        method: str,
        path: str,
        *,
        json: dict | None = None,
        params: QueryParams | None = None,
    ) -> SyncSSEStream:
        """Make a streaming request and return a synchronous SSE stream."""
        response = self.request(method, path, json=json, params=params, stream=True)
        return SyncSSEStream(response)

    def close(self) -> None:
        """Close the underlying HTTP client and release connections."""
        self._client.close()

    def __enter__(self) -> SyncHTTPClient:
        return self

    def __exit__(self, *args: object) -> None:
        self.close()


class AsyncHTTPClient:
    """Asynchronous HTTP transport client."""

    def __init__(self, config: ClientConfig) -> None:
        self._config = config
        self._auth: AuthProvider = _build_auth(config)
        self._rate_limiter = RateLimitTracker()

        default_headers: dict[str, str] = {
            "User-Agent": _SDK_USER_AGENT,
            "Accept": "application/json",
            **config.custom_headers,
        }
        self._client = httpx.AsyncClient(
            base_url=config.base_url,
            timeout=config.timeout,
            headers=default_headers,
            follow_redirects=True,
        )

    async def request(
        self,
        method: str,
        path: str,
        *,
        json: dict | None = None,
        params: QueryParams | None = None,
        headers: HeadersLike | None = None,
        stream: bool = False,
    ) -> httpx.Response:
        """Make an authenticated async HTTP request with retries and rate limit handling."""
        import asyncio

        path = _normalize_path(path)
        last_exc: Exception | None = None

        for attempt in range(self._config.max_retries + 1):
            should_wait, wait_seconds = self._rate_limiter.should_wait()
            if should_wait:
                await asyncio.sleep(wait_seconds)

            req_headers: dict[str, str] = {**self._auth.auth_headers()}
            if headers:
                req_headers.update(headers)

            try:
                if stream:
                    response = await self._client.send(
                        self._client.build_request(
                            method,
                            path,
                            json=json,
                            params=params,
                            headers=req_headers,
                        ),
                        stream=True,
                    )
                else:
                    response = await self._client.request(
                        method,
                        path,
                        json=json,
                        params=params,
                        headers=req_headers,
                    )

                self._rate_limiter.update(response)

                if response.status_code in _RETRY_STATUS_CODES and attempt < self._config.max_retries:
                    retry_after: float | None = None
                    if response.status_code == 429:
                        raw = response.headers.get("Retry-After")
                        if raw is not None:
                            try:
                                retry_after = float(raw)
                            except ValueError:
                                pass
                    wait = _retry_wait(attempt, retry_after)
                    await asyncio.sleep(wait)
                    continue

                raise_for_status(response)
                return response

            except RateLimitError:
                raise
            except httpx.TimeoutException as exc:
                last_exc = exc
                if attempt < self._config.max_retries:
                    await asyncio.sleep(_retry_wait(attempt, None))
                    continue
                raise
            except httpx.TransportError as exc:
                last_exc = exc
                if attempt < self._config.max_retries:
                    await asyncio.sleep(_retry_wait(attempt, None))
                    continue
                raise

        if last_exc is not None:
            raise last_exc
        raise RuntimeError("Exhausted retries without a response")

    async def get(self, path: str, *, params: QueryParams | None = None) -> httpx.Response:
        return await self.request("GET", path, params=params)

    async def get_raw(self, path: str, *, params: QueryParams | None = None) -> httpx.Response:
        """GET without /v1/ prefix normalization — for paths like /health."""
        req_headers: dict[str, str] = {**self._auth.auth_headers()}
        response = await self._client.request("GET", path, params=params, headers=req_headers)
        raise_for_status(response)
        return response

    async def post(self, path: str, *, json: dict | None = None, params: QueryParams | None = None) -> httpx.Response:
        return await self.request("POST", path, json=json, params=params)

    async def put(self, path: str, *, json: dict | None = None) -> httpx.Response:
        return await self.request("PUT", path, json=json)

    async def patch(self, path: str, *, json: dict | None = None) -> httpx.Response:
        return await self.request("PATCH", path, json=json)

    async def delete(self, path: str) -> httpx.Response:
        return await self.request("DELETE", path)

    async def stream_sse(
        self,
        method: str,
        path: str,
        *,
        json: dict | None = None,
        params: QueryParams | None = None,
    ) -> AsyncSSEStream:
        """Make a streaming request and return an async SSE stream."""
        response = await self.request(method, path, json=json, params=params, stream=True)
        return AsyncSSEStream(response)

    async def close(self) -> None:
        """Close the underlying async HTTP client and release connections."""
        await self._client.aclose()

    async def __aenter__(self) -> AsyncHTTPClient:
        return self

    async def __aexit__(self, *args: object) -> None:
        await self.close()
