"""Tests for ClientConfig."""

from __future__ import annotations

import pytest

from ensoul.config import (
    API_VERSION,
    DEFAULT_BASE_URL,
    DEFAULT_MAX_RETRIES,
    DEFAULT_TIMEOUT,
    ClientConfig,
)


class TestClientConfig:
    def test_defaults(self):
        config = ClientConfig()
        assert config.base_url == DEFAULT_BASE_URL
        assert config.api_key is None
        assert config.bearer_token is None
        assert config.timeout == DEFAULT_TIMEOUT
        assert config.max_retries == DEFAULT_MAX_RETRIES
        assert config.custom_headers == {}

    def test_custom_values(self):
        config = ClientConfig(
            base_url="https://custom.example.com",
            api_key="sk_test_abc",
            bearer_token="bearer_xyz",
            timeout=60.0,
            max_retries=5,
            custom_headers={"X-Custom": "value"},
        )
        assert config.base_url == "https://custom.example.com"
        assert config.api_key == "sk_test_abc"
        assert config.bearer_token == "bearer_xyz"
        assert config.timeout == 60.0
        assert config.max_retries == 5
        assert config.custom_headers == {"X-Custom": "value"}

    def test_api_url_property(self):
        config = ClientConfig(base_url="https://api.ensoul.ai")
        assert config.api_url == f"https://api.ensoul.ai/{API_VERSION}"

    def test_api_url_strips_trailing_slash(self):
        config = ClientConfig(base_url="https://api.ensoul.ai/")
        assert config.api_url == f"https://api.ensoul.ai/{API_VERSION}"
        # should not have double slashes
        assert "//" not in config.api_url.replace("https://", "")

    def test_api_url_with_custom_base(self):
        config = ClientConfig(base_url="http://localhost:8000")
        assert config.api_url == f"http://localhost:8000/{API_VERSION}"
