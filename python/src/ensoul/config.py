"""Client configuration for the Ensoul SDK."""

from __future__ import annotations

from dataclasses import dataclass, field

__all__ = [
    "ClientConfig",
    "DEFAULT_BASE_URL",
    "DEFAULT_TIMEOUT",
    "DEFAULT_MAX_RETRIES",
    "API_VERSION",
]

DEFAULT_BASE_URL = "https://api.ensoul.ai"
DEFAULT_TIMEOUT = 30.0
DEFAULT_MAX_RETRIES = 2
API_VERSION = "v1"


@dataclass
class ClientConfig:
    base_url: str = DEFAULT_BASE_URL
    api_key: str | None = None
    bearer_token: str | None = None
    timeout: float = DEFAULT_TIMEOUT
    max_retries: int = DEFAULT_MAX_RETRIES
    custom_headers: dict[str, str] = field(default_factory=dict)

    @property
    def api_url(self) -> str:
        """Base URL with API version, e.g., https://api.ensoul.ai/v1"""
        return f"{self.base_url.rstrip('/')}/{API_VERSION}"
