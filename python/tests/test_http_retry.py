"""Retry-policy tests for the HTTP transport.

The central guarantee: a non-idempotent request (POST/PATCH) that may already have
been executed server-side is NOT replayed. Domain generation runs a ~120s LLM call;
before this policy a client read-timeout triggered retries that re-ran the generation
and billed the caller multiple times for one logical request.
"""

from __future__ import annotations

import httpx
import pytest

from ensoul.config import DEFAULT_CONNECT_TIMEOUT, DEFAULT_TIMEOUT, ClientConfig
from ensoul.http import (
    SyncHTTPClient,
    _build_timeout,
    _should_retry_network,
    _should_retry_status,
)


# --- pure policy helpers ----------------------------------------------------

class TestRetryPolicy:
    def test_network_error_retried_only_for_idempotent_methods(self):
        for method in ("GET", "HEAD", "OPTIONS", "PUT", "DELETE"):
            assert _should_retry_network(method) is True
        for method in ("POST", "PATCH"):
            assert _should_retry_network(method) is False

    def test_status_retry_idempotent_covers_all_retryable_codes(self):
        for code in (429, 500, 502, 503):
            assert _should_retry_status("GET", code) is True

    def test_status_retry_post_only_for_not_processed_codes(self):
        # 429 (rate limited) and 503 (unavailable) mean the request never ran.
        assert _should_retry_status("POST", 429) is True
        assert _should_retry_status("POST", 503) is True
        # 500/502 are ambiguous for a POST — could have run — so do not replay.
        assert _should_retry_status("POST", 500) is False
        assert _should_retry_status("POST", 502) is False

    def test_non_retryable_status_never_retries(self):
        assert _should_retry_status("GET", 404) is False
        assert _should_retry_status("GET", 200) is False


class TestTimeout:
    def test_default_timeout_covers_inference(self):
        # Domain generation has been measured at ~123s; the default must comfortably
        # exceed that so the documented easy path does not time out.
        assert DEFAULT_TIMEOUT >= 180.0

    def test_connect_phase_is_capped_for_fast_failure(self):
        cfg = ClientConfig(timeout=DEFAULT_TIMEOUT)
        t = _build_timeout(cfg)
        assert t.connect == DEFAULT_CONNECT_TIMEOUT
        assert t.read == DEFAULT_TIMEOUT


# --- transport behaviour with a mocked httpx client -------------------------

class _Resp:
    def __init__(self, status_code: int) -> None:
        self.status_code = status_code
        self.headers: dict[str, str] = {}

    def json(self) -> dict:
        return {}


class TestTransportRetries:
    def _client(self, monkeypatch, side_effect):
        client = SyncHTTPClient(ClientConfig(api_key="sk", max_retries=2))
        calls = {"n": 0}

        def fake_request(*args, **kwargs):
            calls["n"] += 1
            result = side_effect(calls["n"])
            if isinstance(result, Exception):
                raise result
            return result

        monkeypatch.setattr(client._client, "request", fake_request)
        # Don't actually sleep between retries.
        monkeypatch.setattr("ensoul.http.time.sleep", lambda *_: None)
        return client, calls

    def test_post_timeout_is_not_retried(self, monkeypatch):
        client, calls = self._client(
            monkeypatch, lambda n: httpx.ReadTimeout("read timed out")
        )
        with pytest.raises(httpx.ReadTimeout):
            client.post("/v1/domains/generate", json={"description": "x"})
        assert calls["n"] == 1  # exactly one attempt — no replay, no double-bill

    def test_get_timeout_is_retried(self, monkeypatch):
        client, calls = self._client(
            monkeypatch, lambda n: httpx.ReadTimeout("read timed out")
        )
        with pytest.raises(httpx.ReadTimeout):
            client.get("/v1/personas")
        assert calls["n"] == 3  # initial + 2 retries

    def test_post_500_is_not_retried(self, monkeypatch):
        client, calls = self._client(monkeypatch, lambda n: _Resp(500))
        with pytest.raises(Exception):
            client.post("/v1/personas", json={"name": "x"})
        assert calls["n"] == 1

    def test_post_503_is_retried(self, monkeypatch):
        client, calls = self._client(monkeypatch, lambda n: _Resp(503))
        with pytest.raises(Exception):
            client.post("/v1/personas", json={"name": "x"})
        assert calls["n"] == 3  # 503 means not processed — safe to replay
