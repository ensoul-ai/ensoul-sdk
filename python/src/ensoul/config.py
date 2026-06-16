"""Client configuration for the Ensoul SDK."""

from __future__ import annotations

from dataclasses import dataclass, field

__all__ = [
    "ClientConfig",
    "DEFAULT_BASE_URL",
    "DEFAULT_TIMEOUT",
    "DEFAULT_CONNECT_TIMEOUT",
    "DEFAULT_MAX_RETRIES",
    "API_VERSION",
]

DEFAULT_BASE_URL = "https://api.ensoul-ai.com"
# Inference endpoints (domain generation, chat, aggregate streaming) run real-time
# LLM calls that routinely take 30-120s+ — domain generation alone has been measured
# at ~123s. A 30s default made the documented "easy path" (domains.generate) time out
# on a new developer's first call. The transport caps the *connect* phase separately
# (see http.py) so a genuinely unreachable host still fails fast.
DEFAULT_TIMEOUT = 300.0
# Seconds to allow for establishing the TCP/TLS connection. Capped well below the
# overall timeout so an unreachable host fails fast instead of hanging for minutes.
DEFAULT_CONNECT_TIMEOUT = 10.0
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
        """Base URL with API version, e.g., https://api.ensoul-ai.com/v1"""
        return f"{self.base_url.rstrip('/')}/{API_VERSION}"
