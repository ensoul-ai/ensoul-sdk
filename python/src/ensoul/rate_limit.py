"""Rate limit tracking for the Ensoul SDK."""

from __future__ import annotations

import time
from dataclasses import dataclass

import httpx

__all__ = [
    "RateLimitInfo",
    "RateLimitTracker",
]


@dataclass
class RateLimitInfo:
    """Parsed rate limit state from API response headers."""

    limit: int
    remaining: int
    reset: float  # Unix timestamp when the window resets
    retry_after: float | None = None  # seconds to wait, only on 429

    @classmethod
    def from_response(cls, response: httpx.Response) -> RateLimitInfo | None:
        """Parse rate limit headers from a response.

        Returns None if the required headers are not present.
        """
        limit_raw = response.headers.get("X-RateLimit-Limit")
        remaining_raw = response.headers.get("X-RateLimit-Remaining")
        reset_raw = response.headers.get("X-RateLimit-Reset")

        if limit_raw is None or remaining_raw is None or reset_raw is None:
            return None

        try:
            limit = int(limit_raw)
            remaining = int(remaining_raw)
            reset = float(reset_raw)
        except (ValueError, TypeError):
            return None

        retry_after: float | None = None
        retry_after_raw = response.headers.get("Retry-After")
        if retry_after_raw is not None:
            try:
                retry_after = float(retry_after_raw)
            except (ValueError, TypeError):
                pass

        return cls(limit=limit, remaining=remaining, reset=reset, retry_after=retry_after)


class RateLimitTracker:
    """Tracks rate limit state across requests."""

    def __init__(self) -> None:
        self._info: RateLimitInfo | None = None

    @property
    def info(self) -> RateLimitInfo | None:
        """Current rate limit information, or None if not yet known."""
        return self._info

    def update(self, response: httpx.Response) -> None:
        """Update tracked state from a response's rate limit headers."""
        info = RateLimitInfo.from_response(response)
        if info is not None:
            self._info = info

    def should_wait(self) -> tuple[bool, float]:
        """Return (should_wait, seconds_to_wait).

        Returns True if remaining == 0 and the reset timestamp is in the future.
        """
        if self._info is None:
            return False, 0.0

        if self._info.remaining > 0:
            return False, 0.0

        now = time.time()
        seconds_until_reset = self._info.reset - now
        if seconds_until_reset <= 0:
            return False, 0.0

        return True, seconds_until_reset
