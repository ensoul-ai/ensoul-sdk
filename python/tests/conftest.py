"""Shared fixtures for Ensoul SDK tests."""

from __future__ import annotations

import json
from pathlib import Path

import pytest
import respx

from ensoul import Ensoul
from ensoul.config import ClientConfig

FIXTURES_DIR = Path(__file__).parent.parent.parent / "shared" / "test-fixtures"

TEST_BASE_URL = "https://test.ensoul.ai"
TEST_API_KEY = "sk_test_123"


@pytest.fixture
def config() -> ClientConfig:
    return ClientConfig(base_url=TEST_BASE_URL, api_key=TEST_API_KEY)


@pytest.fixture
def client() -> Ensoul:
    return Ensoul(api_key=TEST_API_KEY, base_url=TEST_BASE_URL)


@pytest.fixture
def mock_api():
    with respx.mock(base_url=TEST_BASE_URL) as respx_mock:
        yield respx_mock


@pytest.fixture
def persona_fixtures() -> list[dict]:
    with open(FIXTURES_DIR / "personas.json") as f:
        return json.load(f)


@pytest.fixture
def error_fixtures() -> dict:
    with open(FIXTURES_DIR / "error-responses.json") as f:
        return json.load(f)


@pytest.fixture
def sse_fixture_lines() -> list[str]:
    """Return raw JSONL lines from sse-events.jsonl."""
    return (FIXTURES_DIR / "sse-events.jsonl").read_text().splitlines()
