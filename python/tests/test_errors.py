"""Tests for the error hierarchy and raise_for_status."""

from __future__ import annotations

import json

import httpx
import pytest

from ensoul.errors import (
    APIError,
    AuthenticationError,
    AuthorizationError,
    ConflictError,
    ErrorDetail,
    EnsoulError,
    NotFoundError,
    RateLimitError,
    ServerError,
    ValidationError,
    raise_for_status,
)


def _make_response(status_code: int, body: dict, headers: dict | None = None) -> httpx.Response:
    """Build a fake httpx.Response for testing raise_for_status."""
    response_headers = {"content-type": "application/json"}
    if headers:
        response_headers.update(headers)
    return httpx.Response(
        status_code=status_code,
        content=json.dumps(body).encode(),
        headers=response_headers,
    )


class TestErrorHierarchy:
    def test_ensoul_error_is_base(self):
        err = EnsoulError("base")
        assert isinstance(err, Exception)
        assert err.message == "base"

    def test_api_error_inherits_ensoul_error(self):
        err = APIError(400, "Bad Request", "bad input")
        assert isinstance(err, EnsoulError)
        assert err.status_code == 400
        assert err.error == "Bad Request"
        assert err.message == "bad input"
        assert err.request_id is None

    def test_api_error_with_request_id(self):
        err = APIError(400, "Error", "msg", request_id="req_abc")
        assert err.request_id == "req_abc"

    def test_authentication_error(self):
        err = AuthenticationError(401, "Unauthorized", "Token expired")
        assert isinstance(err, APIError)
        assert err.status_code == 401

    def test_authorization_error(self):
        err = AuthorizationError(
            403, "Forbidden", "Insufficient tier",
            required_tier="PRO", current_tier="FREE",
        )
        assert isinstance(err, APIError)
        assert err.required_tier == "PRO"
        assert err.current_tier == "FREE"

    def test_not_found_error(self):
        err = NotFoundError(
            404, "Not Found", "Persona not found",
            resource_type="persona", resource_id="p_123",
        )
        assert isinstance(err, APIError)
        assert err.resource_type == "persona"
        assert err.resource_id == "p_123"

    def test_rate_limit_error(self):
        err = RateLimitError(429, "Rate Limit Exceeded", "Too many requests", retry_after=30)
        assert isinstance(err, APIError)
        assert err.retry_after == 30

    def test_validation_error(self):
        details = [ErrorDetail(field="body.name", message="required", type="missing")]
        err = ValidationError(422, "Validation Error", "Failed", details=details)
        assert isinstance(err, APIError)
        assert len(err.details) == 1
        assert err.details[0].field == "body.name"

    def test_conflict_error(self):
        err = ConflictError(409, "Conflict", "Already exists")
        assert isinstance(err, APIError)

    def test_server_error(self):
        err = ServerError(500, "Internal Server Error", "Unexpected failure")
        assert isinstance(err, APIError)

    def test_api_error_repr(self):
        err = APIError(404, "Not Found", "Missing")
        r = repr(err)
        assert "404" in r
        assert "Not Found" in r


class TestRaiseForStatus:
    def test_2xx_does_not_raise(self):
        for status in (200, 201, 204):
            response = _make_response(status, {})
            raise_for_status(response)  # should not raise

    def test_401_raises_authentication_error(self, error_fixtures):
        fix = error_fixtures["401_invalid_token"]
        response = _make_response(fix["status"], fix["body"])
        with pytest.raises(AuthenticationError) as exc_info:
            raise_for_status(response)
        assert exc_info.value.status_code == 401
        assert exc_info.value.request_id == "req_test_401_a"

    def test_401_missing_auth(self, error_fixtures):
        fix = error_fixtures["401_missing_auth"]
        response = _make_response(fix["status"], fix["body"])
        with pytest.raises(AuthenticationError):
            raise_for_status(response)

    def test_403_raises_authorization_error(self, error_fixtures):
        fix = error_fixtures["403_insufficient_tier"]
        response = _make_response(fix["status"], fix["body"])
        with pytest.raises(AuthorizationError) as exc_info:
            raise_for_status(response)
        assert exc_info.value.status_code == 403

    def test_404_raises_not_found_error(self, error_fixtures):
        fix = error_fixtures["404_persona"]
        response = _make_response(fix["status"], fix["body"])
        with pytest.raises(NotFoundError) as exc_info:
            raise_for_status(response)
        assert exc_info.value.status_code == 404
        assert exc_info.value.message == "Persona not found"

    def test_422_raises_validation_error_with_details(self, error_fixtures):
        fix = error_fixtures["422_validation"]
        response = _make_response(fix["status"], fix["body"])
        with pytest.raises(ValidationError) as exc_info:
            raise_for_status(response)
        err = exc_info.value
        assert err.status_code == 422
        assert len(err.details) == 2
        assert err.details[0].field == "body.name"
        assert err.details[1].field == "body.domain"

    def test_429_raises_rate_limit_error(self, error_fixtures):
        fix = error_fixtures["429_rate_limit"]
        response = _make_response(fix["status"], fix["body"], headers=fix["headers"])
        with pytest.raises(RateLimitError) as exc_info:
            raise_for_status(response)
        assert exc_info.value.retry_after == 30

    def test_500_raises_server_error(self, error_fixtures):
        fix = error_fixtures["500_internal"]
        response = _make_response(fix["status"], fix["body"])
        with pytest.raises(ServerError) as exc_info:
            raise_for_status(response)
        assert exc_info.value.status_code == 500

    def test_503_raises_server_error(self, error_fixtures):
        fix = error_fixtures["503_unavailable"]
        response = _make_response(fix["status"], fix["body"])
        with pytest.raises(ServerError):
            raise_for_status(response)

    def test_409_raises_conflict_error(self):
        response = _make_response(409, {"error": "Conflict", "message": "Already exists"})
        with pytest.raises(ConflictError):
            raise_for_status(response)

    def test_unknown_4xx_raises_api_error(self):
        response = _make_response(418, {"error": "Teapot", "message": "I'm a teapot"})
        with pytest.raises(APIError) as exc_info:
            raise_for_status(response)
        assert exc_info.value.status_code == 418

    def test_invalid_json_body_falls_back(self):
        response = httpx.Response(
            status_code=500,
            content=b"Internal Server Error",
            headers={"content-type": "text/plain"},
        )
        with pytest.raises(APIError):
            raise_for_status(response)
