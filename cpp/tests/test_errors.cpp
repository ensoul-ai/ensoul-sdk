#include <catch2/catch_test_macros.hpp>
#include "ensoul/errors.hpp"

using namespace ensoul;

TEST_CASE("raise_for_status does not throw for 200", "[errors]") {
    REQUIRE_NOTHROW(raise_for_status(200, R"({"ok": true})"));
}

TEST_CASE("raise_for_status does not throw for 201", "[errors]") {
    REQUIRE_NOTHROW(raise_for_status(201, R"({"ok": true})"));
}

TEST_CASE("raise_for_status throws AuthenticationError for 401", "[errors]") {
    try {
        raise_for_status(401, R"({"error": "Unauthorized", "message": "Token missing"})");
        REQUIRE(false);
    } catch (const AuthenticationError& e) {
        CHECK(e.status_code == 401);
        CHECK(e.error == "Unauthorized");
        CHECK(std::string(e.what()) == "Token missing");
    }
}

TEST_CASE("raise_for_status throws AuthorizationError for 403", "[errors]") {
    try {
        raise_for_status(403, R"({"error": "Forbidden", "message": "Insufficient permissions", "required_tier": "pro", "current_tier": "free"})");
        REQUIRE(false);
    } catch (const AuthorizationError& e) {
        CHECK(e.status_code == 403);
        CHECK(e.required_tier == "pro");
        CHECK(e.current_tier == "free");
    }
}

TEST_CASE("raise_for_status throws NotFoundError for 404", "[errors]") {
    try {
        raise_for_status(404, R"({"error": "Not Found", "message": "Persona not found", "resource_type": "persona", "resource_id": "p1"})");
        REQUIRE(false);
    } catch (const NotFoundError& e) {
        CHECK(e.status_code == 404);
        CHECK(e.resource_type == "persona");
        CHECK(e.resource_id == "p1");
    }
}

TEST_CASE("raise_for_status throws ConflictError for 409", "[errors]") {
    try {
        raise_for_status(409, R"({"error": "Conflict", "message": "Already exists"})");
        REQUIRE(false);
    } catch (const ConflictError& e) {
        CHECK(e.status_code == 409);
    }
}

TEST_CASE("raise_for_status throws ValidationError for 422 with details", "[errors]") {
    try {
        raise_for_status(422, R"({"error": "Validation Error", "message": "Validation failed", "details": [{"field": "name", "message": "Required", "type": "missing"}]})");
        REQUIRE(false);
    } catch (const ValidationError& e) {
        CHECK(e.status_code == 422);
        REQUIRE(e.details.size() == 1);
        CHECK(e.details[0].field == "name");
        CHECK(e.details[0].message == "Required");
        CHECK(e.details[0].type == "missing");
    }
}

TEST_CASE("raise_for_status throws RateLimitError for 429 with Retry-After", "[errors]") {
    std::map<std::string, std::string> headers = {{"Retry-After", "30"}};
    try {
        raise_for_status(429, R"({"error": "Rate Limited", "message": "Too many requests"})", headers);
        REQUIRE(false);
    } catch (const RateLimitError& e) {
        CHECK(e.status_code == 429);
        CHECK(e.retry_after == 30);
    }
}

TEST_CASE("raise_for_status throws RateLimitError for 429 with lowercase retry-after", "[errors]") {
    std::map<std::string, std::string> headers = {{"retry-after", "15"}};
    try {
        raise_for_status(429, R"({"error": "Rate Limited", "message": "Slow down"})", headers);
        REQUIRE(false);
    } catch (const RateLimitError& e) {
        CHECK(e.retry_after == 15);
    }
}

TEST_CASE("raise_for_status throws ServerError for 500", "[errors]") {
    try {
        raise_for_status(500, R"({"error": "Internal Server Error", "message": "Unexpected failure"})");
        REQUIRE(false);
    } catch (const ServerError& e) {
        CHECK(e.status_code == 500);
    }
}

TEST_CASE("raise_for_status throws ServerError for 503", "[errors]") {
    try {
        raise_for_status(503, R"({"error": "Service Unavailable", "message": "Maintenance"})");
        REQUIRE(false);
    } catch (const ServerError& e) {
        CHECK(e.status_code == 503);
    }
}

TEST_CASE("raise_for_status throws ApiError for unknown 4xx", "[errors]") {
    try {
        raise_for_status(418, R"({"error": "Teapot", "message": "I am a teapot"})");
        REQUIRE(false);
    } catch (const ApiError& e) {
        CHECK(e.status_code == 418);
        CHECK(e.error == "Teapot");
    }
}

TEST_CASE("raise_for_status with malformed JSON uses defaults", "[errors]") {
    try {
        raise_for_status(500, "not json at all");
        REQUIRE(false);
    } catch (const ServerError& e) {
        CHECK(e.error == "Unknown Error");
        CHECK(std::string(e.what()) == "Unknown error");
    }
}

TEST_CASE("raise_for_status with empty body uses defaults", "[errors]") {
    try {
        raise_for_status(401, "");
        REQUIRE(false);
    } catch (const AuthenticationError& e) {
        CHECK(e.error == "Unknown Error");
    }
}

TEST_CASE("raise_for_status with request_id sets it", "[errors]") {
    try {
        raise_for_status(401, R"({"error": "Unauthorized", "message": "Bad token", "request_id": "req-abc"})");
        REQUIRE(false);
    } catch (const AuthenticationError& e) {
        CHECK(e.request_id == "req-abc");
    }
}

TEST_CASE("EnsoulError is base of ApiError", "[errors]") {
    try {
        raise_for_status(500, R"({"error": "Error", "message": "fail"})");
        REQUIRE(false);
    } catch (const EnsoulError& e) {
        CHECK(std::string(e.what()) == "fail");
    }
}

TEST_CASE("ValidationError with no details array", "[errors]") {
    try {
        raise_for_status(422, R"({"error": "Validation Error", "message": "Bad"})");
        REQUIRE(false);
    } catch (const ValidationError& e) {
        CHECK(e.details.empty());
    }
}
