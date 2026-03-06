"""Exception hierarchy for the Ensoul SDK."""

from __future__ import annotations

from dataclasses import dataclass, field

import httpx

__all__ = [
    "EnsoulError",
    "APIError",
    "AuthenticationError",
    "AuthorizationError",
    "NotFoundError",
    "RateLimitError",
    "ValidationError",
    "ConflictError",
    "ServerError",
    "ErrorDetail",
    "raise_for_status",
]


@dataclass
class ErrorDetail:
    field: str
    message: str
    type: str


class EnsoulError(Exception):
    """Base exception for all Ensoul SDK errors."""

    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message


class APIError(EnsoulError):
    """Error returned by the Ensoul API."""

    def __init__(
        self,
        status_code: int,
        error: str,
        message: str,
        request_id: str | None = None,
    ) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.error = error
        self.request_id = request_id

    def __repr__(self) -> str:
        return (
            f"{type(self).__name__}(status_code={self.status_code}, "
            f"error={self.error!r}, message={self.message!r})"
        )


class AuthenticationError(APIError):
    """HTTP 401 — authentication failed or token missing/expired."""


class AuthorizationError(APIError):
    """HTTP 403 — authenticated but not permitted."""

    def __init__(
        self,
        status_code: int,
        error: str,
        message: str,
        request_id: str | None = None,
        required_tier: str | None = None,
        current_tier: str | None = None,
    ) -> None:
        super().__init__(status_code, error, message, request_id)
        self.required_tier = required_tier
        self.current_tier = current_tier


class NotFoundError(APIError):
    """HTTP 404 — requested resource does not exist."""

    def __init__(
        self,
        status_code: int,
        error: str,
        message: str,
        request_id: str | None = None,
        resource_type: str | None = None,
        resource_id: str | None = None,
    ) -> None:
        super().__init__(status_code, error, message, request_id)
        self.resource_type = resource_type
        self.resource_id = resource_id


class RateLimitError(APIError):
    """HTTP 429 — too many requests."""

    def __init__(
        self,
        status_code: int,
        error: str,
        message: str,
        request_id: str | None = None,
        retry_after: int = 0,
    ) -> None:
        super().__init__(status_code, error, message, request_id)
        self.retry_after = retry_after


class ValidationError(APIError):
    """HTTP 422 — request body failed validation."""

    def __init__(
        self,
        status_code: int,
        error: str,
        message: str,
        request_id: str | None = None,
        details: list[ErrorDetail] | None = None,
    ) -> None:
        super().__init__(status_code, error, message, request_id)
        self.details: list[ErrorDetail] = details or []


class ConflictError(APIError):
    """HTTP 409 — resource already exists or state conflict."""


class ServerError(APIError):
    """HTTP 500 / 503 — server-side failure."""


def raise_for_status(response: httpx.Response) -> None:
    """Raise an appropriate SDK exception for 4xx/5xx responses."""
    if response.status_code < 400:
        return

    try:
        body: dict = response.json()
    except Exception:
        body = {}

    error = body.get("error", "Unknown Error")
    message = body.get("message", response.reason_phrase or "Unknown error")
    request_id: str | None = body.get("request_id")
    status = response.status_code

    if status == 401:
        raise AuthenticationError(status, error, message, request_id)

    if status == 403:
        raise AuthorizationError(status, error, message, request_id)

    if status == 404:
        raise NotFoundError(status, error, message, request_id)

    if status == 409:
        raise ConflictError(status, error, message, request_id)

    if status == 422:
        raw_details = body.get("details", [])
        details = [
            ErrorDetail(
                field=d.get("field", ""),
                message=d.get("message", ""),
                type=d.get("type", ""),
            )
            for d in raw_details
            if isinstance(d, dict)
        ]
        raise ValidationError(status, error, message, request_id, details)

    if status == 429:
        retry_after_raw = response.headers.get("Retry-After", "0")
        try:
            retry_after = int(retry_after_raw)
        except ValueError:
            retry_after = 0
        raise RateLimitError(status, error, message, request_id, retry_after)

    if status in (500, 503):
        raise ServerError(status, error, message, request_id)

    # Generic fallback for any other 4xx/5xx
    raise APIError(status, error, message, request_id)
