"""Tests for the Ensoul and AsyncEnsoul client classes."""

from __future__ import annotations

import os

import pytest

from ensoul import AsyncEnsoul, Ensoul
from ensoul.config import DEFAULT_BASE_URL, DEFAULT_MAX_RETRIES, DEFAULT_TIMEOUT
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


class TestEnsoulClient:
    def test_init_with_api_key(self):
        client = Ensoul(api_key="sk_test_123", base_url="https://test.ensoul.ai")
        assert client._config.api_key == "sk_test_123"
        client.close()

    def test_init_reads_env_var(self, monkeypatch):
        monkeypatch.setenv("ENSOUL_API_KEY", "sk_env_456")
        client = Ensoul(base_url="https://test.ensoul.ai")
        assert client._config.api_key == "sk_env_456"
        client.close()

    def test_explicit_api_key_takes_precedence_over_env(self, monkeypatch):
        monkeypatch.setenv("ENSOUL_API_KEY", "sk_env_456")
        client = Ensoul(api_key="sk_explicit", base_url="https://test.ensoul.ai")
        assert client._config.api_key == "sk_explicit"
        client.close()

    def test_no_api_key_is_allowed(self):
        # Should not raise — server decides authentication
        client = Ensoul(base_url="https://test.ensoul.ai")
        assert client._config.api_key is None
        client.close()

    def test_custom_timeout(self):
        client = Ensoul(api_key="sk_test", base_url="https://test.ensoul.ai", timeout=60.0)
        assert client._config.timeout == 60.0
        client.close()

    def test_custom_max_retries(self):
        client = Ensoul(api_key="sk_test", base_url="https://test.ensoul.ai", max_retries=5)
        assert client._config.max_retries == 5
        client.close()

    def test_custom_headers(self):
        client = Ensoul(
            api_key="sk_test",
            base_url="https://test.ensoul.ai",
            custom_headers={"X-Custom-Header": "value"},
        )
        assert client._config.custom_headers == {"X-Custom-Header": "value"}
        client.close()

    def test_resource_namespaces_are_correct_types(self):
        client = Ensoul(api_key="sk_test", base_url="https://test.ensoul.ai")
        assert isinstance(client.personas, Personas)
        assert isinstance(client.chat, Chat)
        assert isinstance(client.domains, Domains)
        assert isinstance(client.simulations, Simulations)
        assert isinstance(client.aggregate, Aggregate)
        assert isinstance(client.memory, Memory)
        assert isinstance(client.sessions, Sessions)
        assert isinstance(client.frameworks, Frameworks)
        assert isinstance(client.auth, AuthResource)
        assert isinstance(client.health, Health)
        assert isinstance(client.info, Info)
        client.close()

    def test_context_manager(self):
        with Ensoul(api_key="sk_test", base_url="https://test.ensoul.ai") as client:
            assert isinstance(client, Ensoul)
        # After exit the client should be closed (no exception)

    def test_close_is_idempotent(self):
        client = Ensoul(api_key="sk_test", base_url="https://test.ensoul.ai")
        client.close()
        # Closing again should not raise
        client.close()

    def test_default_base_url(self):
        client = Ensoul(api_key="sk_test")
        assert client._config.base_url == DEFAULT_BASE_URL
        client.close()


class TestAsyncEnsoulClient:
    def test_init_with_api_key(self):
        client = AsyncEnsoul(api_key="sk_test_123", base_url="https://test.ensoul.ai")
        assert client._config.api_key == "sk_test_123"

    def test_init_reads_env_var(self, monkeypatch):
        monkeypatch.setenv("ENSOUL_API_KEY", "sk_env_async")
        client = AsyncEnsoul(base_url="https://test.ensoul.ai")
        assert client._config.api_key == "sk_env_async"

    def test_resource_namespaces_are_correct_types(self):
        client = AsyncEnsoul(api_key="sk_test", base_url="https://test.ensoul.ai")
        assert isinstance(client.personas, AsyncPersonas)
        assert isinstance(client.chat, AsyncChat)
        assert isinstance(client.domains, AsyncDomains)
        assert isinstance(client.simulations, AsyncSimulations)
        assert isinstance(client.aggregate, AsyncAggregate)
        assert isinstance(client.memory, AsyncMemory)
        assert isinstance(client.sessions, AsyncSessions)
        assert isinstance(client.frameworks, AsyncFrameworks)
        assert isinstance(client.auth, AsyncAuthResource)
        assert isinstance(client.health, AsyncHealth)
        assert isinstance(client.info, AsyncInfo)

    @pytest.mark.asyncio
    async def test_async_context_manager(self):
        async with AsyncEnsoul(api_key="sk_test", base_url="https://test.ensoul.ai") as client:
            assert isinstance(client, AsyncEnsoul)
