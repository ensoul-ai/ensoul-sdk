"""Tests for the Personas resource using respx mocking."""

from __future__ import annotations

import json

import httpx
import pytest
import respx

from ensoul import Ensoul
from ensoul.generated.personas import (
    PersonaBatchResponse,
    PersonaResponse,
    PersonalityVectorResponse,
)

TEST_BASE_URL = "https://test.ensoul.ai"


@pytest.fixture
def client():
    return Ensoul(api_key="sk_test_123", base_url=TEST_BASE_URL)


def _persona_payload(idx: int = 0, persona_fixtures=None) -> dict:
    if persona_fixtures:
        return persona_fixtures[idx % len(persona_fixtures)]
    return {
        "id": f"persona_test_{idx:03d}",
        "name": f"Test Persona {idx}",
        "domain": "test_domain",
        "personality_data": {"openness": 70},
        "avatar_url": None,
        "archetype": "test_archetype",
        "age": 30,
        "country": "test_country",
        "region": "test_region",
        "city": "Test City",
        "batch_id": None,
        "created_at": "2025-01-15T10:30:00Z",
    }


class TestPersonasCreate:
    def test_create_returns_persona_response(self, client, persona_fixtures):
        payload = persona_fixtures[0]
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.post("/v1/personas").mock(
                return_value=httpx.Response(200, json=payload)
            )
            result = client.personas.create(
                name="Alex Rivera",
                domain="test_domain_a",
                personality_data={"openness": 75},
            )
        assert isinstance(result, PersonaResponse)
        assert result.id == payload["id"]
        assert result.name == payload["name"]
        assert result.domain == payload["domain"]

    def test_create_sends_correct_body(self, client):
        payload = _persona_payload()
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            route = mock.post("/v1/personas").mock(
                return_value=httpx.Response(200, json=payload)
            )
            client.personas.create(
                name="New Persona",
                domain="my_domain",
                personality_data={"trait": 50},
            )
        sent_body = json.loads(route.calls[0].request.content)
        assert sent_body["name"] == "New Persona"
        assert sent_body["domain"] == "my_domain"
        assert sent_body["personality_data"] == {"trait": 50}


class TestPersonasGet:
    def test_get_returns_persona_response(self, client, persona_fixtures):
        payload = persona_fixtures[0]
        persona_id = payload["id"]
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get(f"/v1/personas/{persona_id}").mock(
                return_value=httpx.Response(200, json=payload)
            )
            result = client.personas.get(persona_id)
        assert isinstance(result, PersonaResponse)
        assert result.id == persona_id

    def test_get_raises_not_found(self, client, error_fixtures):
        fix = error_fixtures["404_persona"]
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas/nonexistent").mock(
                return_value=httpx.Response(fix["status"], json=fix["body"])
            )
            from ensoul.errors import NotFoundError
            with pytest.raises(NotFoundError):
                client.personas.get("nonexistent")


class TestPersonasList:
    def test_list_returns_sync_page(self, client, persona_fixtures):
        list_payload = {
            "items": persona_fixtures[:2],
            "total": 2,
            "page": 1,
            "per_page": 20,
            "pages": 1,
        }
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=list_payload)
            )
            page = client.personas.list()
        assert len(page.items) == 2
        assert page.total == 2
        assert page.page == 1
        assert isinstance(page.items[0], PersonaResponse)

    def test_list_with_filter_params(self, client, persona_fixtures):
        list_payload = {
            "items": [persona_fixtures[0]],
            "total": 1,
            "page": 1,
            "per_page": 20,
            "pages": 1,
        }
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            route = mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=list_payload)
            )
            client.personas.list(region="test_region_1", per_page=10)
        request = route.calls[0].request
        assert "region=test_region_1" in str(request.url)

    def test_list_pagination_has_next_page(self, client, persona_fixtures):
        list_payload = {
            "items": [persona_fixtures[0]],
            "total": 3,
            "page": 1,
            "per_page": 1,
            "pages": 3,
        }
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=list_payload)
            )
            page = client.personas.list(per_page=1)
        assert page.has_next_page()


class TestPersonasUpdate:
    def test_update_returns_persona_response(self, client, persona_fixtures):
        payload = {**persona_fixtures[0], "name": "Updated Name"}
        persona_id = payload["id"]
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.put(f"/v1/personas/{persona_id}").mock(
                return_value=httpx.Response(200, json=payload)
            )
            result = client.personas.update(persona_id, name="Updated Name")
        assert isinstance(result, PersonaResponse)
        assert result.name == "Updated Name"


class TestPersonasDelete:
    def test_delete_returns_none(self, client, persona_fixtures):
        persona_id = persona_fixtures[0]["id"]
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.delete(f"/v1/personas/{persona_id}").mock(
                return_value=httpx.Response(204)
            )
            result = client.personas.delete(persona_id)
        assert result is None


class TestPersonasBatchCreate:
    def test_batch_create_returns_batch_response(self, client):
        batch_payload = {
            "created": 2,
            "persona_ids": ["persona_001", "persona_002"],
            "batch_id": "batch_test_001",
            "domain": "test_domain",
        }
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.post("/v1/personas/batch").mock(
                return_value=httpx.Response(200, json=batch_payload)
            )
            result = client.personas.batch_create(
                personas=[
                    {"name": "P1", "domain": "test_domain"},
                    {"name": "P2", "domain": "test_domain"},
                ],
                batch_id="batch_test_001",
                domain="test_domain",
            )
        assert isinstance(result, PersonaBatchResponse)
        assert result.created == 2
        assert len(result.persona_ids) == 2


class TestPersonasPersonality:
    def test_get_personality_returns_vector_response(self, client, persona_fixtures):
        persona_id = persona_fixtures[0]["id"]
        personality_payload = {
            "persona_id": persona_id,
            "domain": "test_domain_a",
            "personality_data": {"openness": 75, "conscientiousness": 60},
            "communication_style": {"formality": 50},
            "core_values": ["creativity"],
        }
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get(f"/v1/personas/{persona_id}/personality").mock(
                return_value=httpx.Response(200, json=personality_payload)
            )
            result = client.personas.get_personality(persona_id)
        assert isinstance(result, PersonalityVectorResponse)
        assert result.persona_id == persona_id
