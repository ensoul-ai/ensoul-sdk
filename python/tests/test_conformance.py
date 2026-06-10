"""Cross-SDK conformance tests for the Python SDK.

These tests run against a mock server started by the conformance orchestrator.
They are automatically skipped when ENSOUL_CONFORMANCE_URL is not set,
so regular `pytest` runs are unaffected.
"""
from __future__ import annotations

import os

import pytest

CONFORMANCE_URL = os.environ.get("ENSOUL_CONFORMANCE_URL")

pytestmark = pytest.mark.skipif(
    not CONFORMANCE_URL,
    reason="ENSOUL_CONFORMANCE_URL not set — skipping conformance tests",
)


@pytest.fixture
def client():
    """Create an Ensoul client pointed at the conformance mock server."""
    from ensoul.client import Ensoul

    c = Ensoul(
        api_key="sk_test_123",
        base_url=CONFORMANCE_URL,
        max_retries=0,
        custom_headers={"X-SDK-Language": "python"},
    )
    yield c
    c.close()


@pytest.fixture
def no_auth_client():
    """Create an Ensoul client with no auth credentials."""
    from ensoul.client import Ensoul

    c = Ensoul(
        api_key="",
        base_url=CONFORMANCE_URL,
        max_retries=0,
    )
    yield c
    c.close()


# ---------------------------------------------------------------------------
# Personas
# ---------------------------------------------------------------------------


class TestPersonas:
    def test_persona_create(self, client):
        persona = client.personas.create(
            name="Test Persona",
            domain="test_domain",
            personality_data={"trait_a": 75, "trait_b": 50},
        )
        assert persona.id == "p_test_001"
        assert persona.name == "Test Persona"
        assert persona.domain == "test_domain"

    def test_persona_get(self, client):
        persona = client.personas.get("p_test_001")
        assert persona.id == "p_test_001"
        assert persona.name == "Test Persona"
        assert persona.domain == "test_domain"

    def test_persona_list_pagination(self, client):
        page = client.personas.list(page=1, per_page=10)
        assert len(page.items) >= 1
        assert page.total == 25
        assert page.page == 1
        assert page.per_page == 10
        assert page.pages == 3

    def test_persona_not_found(self, client):
        from ensoul.errors import NotFoundError

        with pytest.raises(NotFoundError) as exc_info:
            client.personas.get("nonexistent_persona_id")
        assert exc_info.value.status_code == 404

    def test_persona_update(self, client):
        persona = client.personas.update(
            "p_test_001",
            name="Updated Persona",
            personality_data={"trait_a": 80, "trait_b": 60},
        )
        assert persona.id == "p_test_001"
        assert persona.name == "Updated Persona"

    def test_persona_delete(self, client):
        result = client.personas.delete("p_test_001")
        assert result is None


# ---------------------------------------------------------------------------
# Chat
# ---------------------------------------------------------------------------


class TestChat:
    def test_chat_send(self, client):
        response = client.chat.send("p_test_001", "Hello, how are you?")
        assert response.response
        assert response.conversation_id
        assert response.token_usage.total_tokens > 0

    def test_chat_stream_sse(self, client):
        from ensoul.streaming import parse_chat_event

        stream = client.chat.stream("p_test_001", "Tell me about yourself.")
        events = []
        for sse_event in stream:
            events.append(parse_chat_event(sse_event))

        assert len(events) == 5

        # Check chunk ordering
        for i, event in enumerate(events):
            assert event.chunk_index == i
            assert event.conversation_id == "conv_stream_001"

        # Final event
        assert events[-1].is_final is True
        assert events[-1].token_usage is not None
        assert events[-1].token_usage["total_tokens"] > 0

        # Non-final events
        for event in events[:-1]:
            assert event.is_final is False

    def test_chat_get_conversations(self, client):
        page = client.chat.get_conversations("p_test_001")
        assert len(page.items) >= 1
        assert page.total == 2


# ---------------------------------------------------------------------------
# Domains
# ---------------------------------------------------------------------------


class TestDomains:
    def test_domain_list(self, client):
        page = client.domains.list()
        assert len(page.items) >= 1

    def test_domain_get(self, client):
        domain = client.domains.get("d_test_001")
        assert domain["id"] == "d_test_001"
        assert domain["name"] == "Test Domain"
        assert domain["field_count"] == 12


# ---------------------------------------------------------------------------
# Simulations
# ---------------------------------------------------------------------------


class TestSimulations:
    def test_simulation_create(self, client):
        sim = client.simulations.create(
            name="Test Simulation",
            domain_id="d_test_001",
        )
        assert sim.id == "sim_test_001"
        assert sim.status == "created"

    def test_simulation_start(self, client):
        result = client.simulations.start("sim_test_001", ticks=50)
        assert result["status"] == "running"
        assert result["ticks_requested"] == 50


# ---------------------------------------------------------------------------
# Memory
# ---------------------------------------------------------------------------


class TestMemory:
    def test_memory_create(self, client):
        mem = client.memory.create(
            "p_test_001",
            content="Remembers meeting a friend at the park",
            source="user",
        )
        assert mem["id"] == "mem_test_001"
        assert mem["persona_id"] == "p_test_001"

    def test_memory_delete(self, client):
        result = client.memory.delete("p_test_001", "mem_test_001")
        assert result is None


# ---------------------------------------------------------------------------
# Sessions
# ---------------------------------------------------------------------------


class TestSessions:
    def test_session_create(self, client):
        session = client.sessions.create(tier=0)
        assert session["id"] == "sess_test_001"
        assert session["tier"] == 0
        assert session["parent_session_id"] is None


# ---------------------------------------------------------------------------
# Aggregate
# ---------------------------------------------------------------------------


class TestAggregate:
    def test_aggregate_count(self, client):
        result = client.aggregate.count(domain="demo")
        assert result["sample_size"] == 500
        assert result["confidence"] == 0.95


# ---------------------------------------------------------------------------
# Health
# ---------------------------------------------------------------------------


class TestHealth:
    def test_health_check(self, client):
        result = client.health.check()
        assert result["status"] == "ok"
        assert result["version"]
        assert result["uptime_seconds"] > 0


# ---------------------------------------------------------------------------
# Info
# ---------------------------------------------------------------------------


class TestInfo:
    def test_info_config(self, client):
        result = client.info.config()
        assert result["api_version"] == "1.0.0"
        assert result["max_batch_size"] == 100


# ---------------------------------------------------------------------------
# Auth Resources
# ---------------------------------------------------------------------------


class TestAuthResources:
    def test_auth_token_exchange(self, client):
        token_resp = client.auth.token("testuser", "testpass")
        assert token_resp.access_token
        assert token_resp.token_type == "bearer"
        assert token_resp.expires_in == 3600

    def test_auth_me(self, client):
        user = client.auth.me()
        assert user.consumer_id == "user_test_001"
        assert user.username == "testuser"


# ---------------------------------------------------------------------------
# Frameworks
# ---------------------------------------------------------------------------


class TestFrameworks:
    def test_framework_update(self, client):
        fw = client.frameworks.update(
            "fw_test_001",
            name="Big Five Updated",
            description="Updated five-factor personality model",
        )
        assert fw["id"] == "fw_test_001"
        assert fw["name"] == "Big Five Updated"


# ---------------------------------------------------------------------------
# Errors
# ---------------------------------------------------------------------------


class TestErrors:
    def test_error_rate_limit(self, client):
        from ensoul.errors import RateLimitError

        with pytest.raises(RateLimitError) as exc_info:
            client._client.request(
                "GET", "/v1/personas",
                headers={"X-Trigger-RateLimit": "true"},
            )
        assert exc_info.value.retry_after == 30

    def test_error_validation(self, client):
        from ensoul.errors import ValidationError

        with pytest.raises(ValidationError) as exc_info:
            client._client.post("/v1/personas", json={})
        assert len(exc_info.value.details) >= 1

    def test_error_authentication(self, no_auth_client):
        from ensoul.errors import AuthenticationError

        with pytest.raises(AuthenticationError) as exc_info:
            no_auth_client.personas.list()
        assert exc_info.value.status_code == 401

    def test_error_server(self, client):
        from ensoul.errors import ServerError

        with pytest.raises(ServerError) as exc_info:
            client._client.request(
                "GET",
                "/v1/personas",
                headers={"X-Trigger-ServerError": "true"},
            )
        assert exc_info.value.status_code == 500

    def test_error_authorization_forbidden(self):
        from ensoul.client import Ensoul
        from ensoul.errors import AuthorizationError

        c = Ensoul(
            api_key="sk_test_123",
            base_url=CONFORMANCE_URL,
            max_retries=0,
            custom_headers={"X-Trigger-Forbidden": "true"},
        )
        try:
            with pytest.raises(AuthorizationError) as exc_info:
                c.personas.list()
            assert exc_info.value.status_code == 403
        finally:
            c.close()

    def test_error_retry_503(self):
        from ensoul.client import Ensoul

        c = Ensoul(
            api_key="sk_test_123",
            base_url=CONFORMANCE_URL,
            max_retries=2,
            custom_headers={
                "X-Trigger-503-Once": "true",
                "X-SDK-Language": "python-retry",
            },
        )
        try:
            page = c.personas.list()
            assert len(page.items) >= 1
        finally:
            c.close()


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------


class TestAuth:
    def test_auth_api_key_header(self, client):
        """Verify the SDK sends X-Api-Key header (mock server validates it)."""
        # If we can list personas successfully, the auth header was correct
        page = client.personas.list()
        assert len(page.items) >= 1

    def test_auth_no_credentials(self, no_auth_client):
        from ensoul.errors import AuthenticationError

        with pytest.raises(AuthenticationError):
            no_auth_client.personas.list()

    def test_auth_bearer_token(self):
        from ensoul.client import Ensoul

        c = Ensoul(
            bearer_token="test_token_123",
            base_url=CONFORMANCE_URL,
            max_retries=0,
            custom_headers={"X-SDK-Language": "python"},
        )
        try:
            page = c.personas.list()
            assert len(page.items) >= 1
        finally:
            c.close()


# ---------------------------------------------------------------------------
# Chat sessions (persisted history)
# ---------------------------------------------------------------------------


class TestChatSessions:
    def test_create_session(self, client):
        session = client.chat.create_session(
            team_id="team_test_001",
            user_id="user_test_001",
            domain_id="d_test_001",
            persona_id="persona_test_001",
            title="Test Chat Session",
        )
        assert session["id"] == "csess_test_001"
        assert session["is_archived"] is False

    def test_list_sessions(self, client):
        result = client.chat.list_sessions(user_id="user_test_001")
        assert len(result["sessions"]) >= 1
        assert result["pagination"]["total"] == 1

    def test_session_stats(self, client):
        result = client.chat.session_stats(
            team_id="team_test_001",
            start_date="2025-01-01",
            end_date="2025-01-31",
        )
        assert result["total"] == 7

    def test_get_session(self, client):
        session = client.chat.get_session("csess_test_001")
        assert session["id"] == "csess_test_001"
        assert len(session["messages"]) >= 1

    def test_update_session(self, client):
        session = client.chat.update_session(
            "csess_test_001", title="Renamed"
        )
        assert session["id"] == "csess_test_001"

    def test_archive_session(self, client):
        session = client.chat.archive_session("csess_test_001")
        assert session["id"] == "csess_test_001"

    def test_delete_session(self, client):
        # 204 No Content — returns None without raising.
        assert client.chat.delete_session("csess_test_001") is None

    def test_add_message(self, client):
        message = client.chat.add_message(
            "csess_test_001", role="assistant", content="Hi"
        )
        assert message["id"] == "msg_test_002"
        assert message["role"] == "assistant"

    def test_get_messages(self, client):
        messages = client.chat.get_messages("csess_test_001")
        assert len(messages) == 2
        assert messages[0]["role"] == "user"


# ---------------------------------------------------------------------------
# Simulation participants and event ticks
# ---------------------------------------------------------------------------


class TestSimulationParticipants:
    def test_list_participants(self, client):
        result = client.simulations.list_participants("sim_test_001")
        assert result["total"] == 2
        assert len(result["items"]) == 2

    def test_add_participants(self, client):
        sim = client.simulations.add_participants(
            "sim_test_001", ["persona_test_001"]
        )
        assert sim["id"] == "sim_test_001"

    def test_event_ticks(self, client):
        result = client.simulations.get_event_ticks("sim_test_001")
        assert len(result["ticks"]) == 3


# ---------------------------------------------------------------------------
# Audit and verification
# ---------------------------------------------------------------------------


class TestAudit:
    def test_get_event(self, client):
        event = client.audit.get_event("evt_test_001")
        assert event["event_id"] == "evt_test_001"
        assert event["event_hash"]

    def test_get_commitment(self, client):
        commitment = client.audit.get_commitment("cmt_test_001")
        assert commitment["commitment_id"] == "cmt_test_001"
        assert commitment["event_count"] == 42

    def test_get_proof(self, client):
        proof = client.audit.get_proof("evt_test_001")
        assert proof["verified"] is True
        assert len(proof["proof_path"]) == 2

    def test_verify(self, client):
        result = client.audit.verify("evt_test_001")
        assert result["verified"] is True

    def test_signing_key(self, client):
        pem = client.audit.get_signing_key()
        assert "BEGIN PUBLIC KEY" in pem


# ---------------------------------------------------------------------------
# Pagination
# ---------------------------------------------------------------------------


class TestPagination:
    def test_pagination_auto_fetch(self, client):
        page = client.frameworks.list(per_page=2)
        all_items = list(page.auto_paging_iter())
        assert len(all_items) == 3


# ---------------------------------------------------------------------------
# Client Configuration
# ---------------------------------------------------------------------------


class TestClientConfig:
    def test_client_custom_base_url(self):
        """Verify the client respects custom base_url by connecting to mock server."""
        from ensoul.client import Ensoul

        client = Ensoul(
            api_key="sk_test_123",
            base_url=CONFORMANCE_URL,
            max_retries=0,
        )
        try:
            page = client.personas.list()
            assert len(page.items) >= 1
        finally:
            client.close()
