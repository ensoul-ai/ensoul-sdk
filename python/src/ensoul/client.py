"""Ensoul Python SDK client."""

from __future__ import annotations

import os
from typing import Any

from ensoul.config import (
    DEFAULT_BASE_URL,
    DEFAULT_MAX_RETRIES,
    DEFAULT_TIMEOUT,
    ClientConfig,
)
from ensoul.http import AsyncHTTPClient, SyncHTTPClient
from ensoul.resources.aggregate import Aggregate, AsyncAggregate
from ensoul.resources.auth_resource import AsyncAuthResource, AuthResource
from ensoul.resources.chat import AsyncChat, Chat
from ensoul.resources.domains import AsyncDomains, Domains
from ensoul.resources.frameworks import AsyncFrameworks, Frameworks
from ensoul.resources.health import AsyncHealth, Health
from ensoul.resources.info import AsyncInfo, Info
from ensoul.resources.memory import AsyncMemory, Memory
from ensoul.resources.personas import AsyncPersonas, Personas
from ensoul.resources.sessions import AsyncSessions, Sessions
from ensoul.resources.simulations import AsyncSimulations, Simulations

__all__ = [
    "Ensoul",
    "AsyncEnsoul",
]


class Ensoul:
    """Synchronous Ensoul API client.

    Usage::

        client = Ensoul(api_key="sk_...")
        persona = client.personas.create(
            name="Test", domain="my_domain", personality_data={...}
        )
        response = client.chat.send(persona.id, "Hello!")

        # With context manager
        with Ensoul(api_key="sk_...") as client:
            for persona in client.personas.list().auto_paging_iter():
                print(persona.name)

    The API key can also be set via the ``ENSOUL_API_KEY`` environment variable.
    """

    personas: Personas
    chat: Chat
    domains: Domains
    simulations: Simulations
    aggregate: Aggregate
    memory: Memory
    sessions: Sessions
    frameworks: Frameworks
    auth: AuthResource
    health: Health
    info: Info

    def __init__(
        self,
        api_key: str | None = None,
        *,
        base_url: str | None = None,
        bearer_token: str | None = None,
        timeout: float = DEFAULT_TIMEOUT,
        max_retries: int = DEFAULT_MAX_RETRIES,
        custom_headers: dict[str, str] | None = None,
    ) -> None:
        resolved_api_key = api_key or os.environ.get("ENSOUL_API_KEY")
        resolved_base_url = base_url or os.environ.get("ENSOUL_BASE_URL", DEFAULT_BASE_URL)

        config = ClientConfig(
            base_url=resolved_base_url,
            api_key=resolved_api_key,
            bearer_token=bearer_token,
            timeout=timeout,
            max_retries=max_retries,
            custom_headers=custom_headers or {},
        )

        self._client = SyncHTTPClient(config)
        self._config = config

        self.personas = Personas(self._client)
        self.chat = Chat(self._client)
        self.domains = Domains(self._client)
        self.simulations = Simulations(self._client)
        self.aggregate = Aggregate(self._client)
        self.memory = Memory(self._client)
        self.sessions = Sessions(self._client)
        self.frameworks = Frameworks(self._client)
        self.auth = AuthResource(self._client)
        self.health = Health(self._client)
        self.info = Info(self._client)

    def close(self) -> None:
        """Close the underlying HTTP client and release connections."""
        self._client.close()

    def __enter__(self) -> Ensoul:
        return self

    def __exit__(self, *args: Any) -> None:
        self.close()


class AsyncEnsoul:
    """Asynchronous Ensoul API client.

    Usage::

        async with AsyncEnsoul(api_key="sk_...") as client:
            persona = await client.personas.create(
                name="Test", domain="my_domain"
            )

    The API key can also be set via the ``ENSOUL_API_KEY`` environment variable.
    """

    personas: AsyncPersonas
    chat: AsyncChat
    domains: AsyncDomains
    simulations: AsyncSimulations
    aggregate: AsyncAggregate
    memory: AsyncMemory
    sessions: AsyncSessions
    frameworks: AsyncFrameworks
    auth: AsyncAuthResource
    health: AsyncHealth
    info: AsyncInfo

    def __init__(
        self,
        api_key: str | None = None,
        *,
        base_url: str | None = None,
        bearer_token: str | None = None,
        timeout: float = DEFAULT_TIMEOUT,
        max_retries: int = DEFAULT_MAX_RETRIES,
        custom_headers: dict[str, str] | None = None,
    ) -> None:
        resolved_api_key = api_key or os.environ.get("ENSOUL_API_KEY")
        resolved_base_url = base_url or os.environ.get("ENSOUL_BASE_URL", DEFAULT_BASE_URL)

        config = ClientConfig(
            base_url=resolved_base_url,
            api_key=resolved_api_key,
            bearer_token=bearer_token,
            timeout=timeout,
            max_retries=max_retries,
            custom_headers=custom_headers or {},
        )

        self._client = AsyncHTTPClient(config)
        self._config = config

        self.personas = AsyncPersonas(self._client)
        self.chat = AsyncChat(self._client)
        self.domains = AsyncDomains(self._client)
        self.simulations = AsyncSimulations(self._client)
        self.aggregate = AsyncAggregate(self._client)
        self.memory = AsyncMemory(self._client)
        self.sessions = AsyncSessions(self._client)
        self.frameworks = AsyncFrameworks(self._client)
        self.auth = AsyncAuthResource(self._client)
        self.health = AsyncHealth(self._client)
        self.info = AsyncInfo(self._client)

    async def close(self) -> None:
        """Close the underlying async HTTP client and release connections."""
        await self._client.close()

    async def __aenter__(self) -> AsyncEnsoul:
        return self

    async def __aexit__(self, *args: Any) -> None:
        await self.close()
