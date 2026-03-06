import { describe, it, expect, beforeEach, vi } from "vitest";
import {
  EnsoulError,
  APIError,
  AuthenticationError,
  AuthorizationError,
  NotFoundError,
  ConflictError,
  ValidationError,
  RateLimitError,
  ServerError,
  raiseForStatus,
} from "../src/errors.js";

beforeEach(() => {
  vi.restoreAllMocks();
});

describe("Error classes", () => {
  describe("EnsoulError", () => {
    it("has correct name", () => {
      const err = new EnsoulError("test");
      expect(err.name).toBe("EnsoulError");
    });

    it("is an instance of Error", () => {
      const err = new EnsoulError("test");
      expect(err).toBeInstanceOf(Error);
    });

    it("carries message", () => {
      const err = new EnsoulError("something went wrong");
      expect(err.message).toBe("something went wrong");
    });
  });

  describe("APIError", () => {
    it("has correct name and properties", () => {
      const err = new APIError(400, "bad_request", "Bad request", "req-001");
      expect(err.name).toBe("APIError");
      expect(err.statusCode).toBe(400);
      expect(err.error).toBe("bad_request");
      expect(err.message).toBe("Bad request");
      expect(err.requestId).toBe("req-001");
    });

    it("is an instance of EnsoulError and Error", () => {
      const err = new APIError(400, "bad_request", "Bad request");
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });

    it("requestId can be undefined", () => {
      const err = new APIError(400, "bad_request", "Bad request");
      expect(err.requestId).toBeUndefined();
    });
  });

  describe("AuthenticationError", () => {
    it("has correct name", () => {
      const err = new AuthenticationError(401, "invalid_token", "Token is invalid");
      expect(err.name).toBe("AuthenticationError");
    });

    it("is an instance of APIError, EnsoulError, and Error", () => {
      const err = new AuthenticationError(401, "invalid_token", "Token is invalid");
      expect(err).toBeInstanceOf(APIError);
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });

    it("has correct status code and properties", () => {
      const err = new AuthenticationError(401, "invalid_token", "Token is invalid", "req-abc");
      expect(err.statusCode).toBe(401);
      expect(err.error).toBe("invalid_token");
      expect(err.requestId).toBe("req-abc");
    });
  });

  describe("AuthorizationError", () => {
    it("has correct name", () => {
      const err = new AuthorizationError(403, "insufficient_tier", "Upgrade required");
      expect(err.name).toBe("AuthorizationError");
    });

    it("is an instance of APIError, EnsoulError, and Error", () => {
      const err = new AuthorizationError(403, "insufficient_tier", "Upgrade required");
      expect(err).toBeInstanceOf(APIError);
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });

    it("carries requiredTier and currentTier", () => {
      const err = new AuthorizationError(
        403,
        "insufficient_tier",
        "Upgrade required",
        "req-001",
        "professional",
        "free"
      );
      expect(err.requiredTier).toBe("professional");
      expect(err.currentTier).toBe("free");
    });

    it("allows undefined tiers", () => {
      const err = new AuthorizationError(403, "forbidden", "Forbidden");
      expect(err.requiredTier).toBeUndefined();
      expect(err.currentTier).toBeUndefined();
    });
  });

  describe("NotFoundError", () => {
    it("has correct name", () => {
      const err = new NotFoundError(404, "not_found", "Persona not found");
      expect(err.name).toBe("NotFoundError");
    });

    it("is an instance of APIError, EnsoulError, and Error", () => {
      const err = new NotFoundError(404, "not_found", "Persona not found");
      expect(err).toBeInstanceOf(APIError);
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });

    it("carries resourceType and resourceId", () => {
      const err = new NotFoundError(404, "not_found", "Not found", "req-001", "persona", "persona_001");
      expect(err.resourceType).toBe("persona");
      expect(err.resourceId).toBe("persona_001");
    });
  });

  describe("ConflictError", () => {
    it("has correct name", () => {
      const err = new ConflictError(409, "conflict", "Already exists");
      expect(err.name).toBe("ConflictError");
    });

    it("is an instance of APIError, EnsoulError, and Error", () => {
      const err = new ConflictError(409, "conflict", "Already exists");
      expect(err).toBeInstanceOf(APIError);
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });
  });

  describe("ValidationError", () => {
    it("has correct name", () => {
      const err = new ValidationError(422, "validation_error", "Invalid data");
      expect(err.name).toBe("ValidationError");
    });

    it("is an instance of APIError, EnsoulError, and Error", () => {
      const err = new ValidationError(422, "validation_error", "Invalid data");
      expect(err).toBeInstanceOf(APIError);
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });

    it("carries details array", () => {
      const details = [
        { field: "name", message: "required", type: "missing_field" },
        { field: "domain", message: "too short", type: "value_error" },
      ];
      const err = new ValidationError(422, "validation_error", "Invalid data", "req-001", details);
      expect(err.details).toHaveLength(2);
      expect(err.details[0].field).toBe("name");
      expect(err.details[1].field).toBe("domain");
    });

    it("defaults to empty details array", () => {
      const err = new ValidationError(422, "validation_error", "Invalid data");
      expect(err.details).toEqual([]);
    });
  });

  describe("RateLimitError", () => {
    it("has correct name", () => {
      const err = new RateLimitError(429, "rate_limit_exceeded", "Too many requests");
      expect(err.name).toBe("RateLimitError");
    });

    it("is an instance of APIError, EnsoulError, and Error", () => {
      const err = new RateLimitError(429, "rate_limit_exceeded", "Too many requests");
      expect(err).toBeInstanceOf(APIError);
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });

    it("carries retryAfter value", () => {
      const err = new RateLimitError(429, "rate_limit_exceeded", "Too many requests", "req-001", 60);
      expect(err.retryAfter).toBe(60);
    });

    it("defaults retryAfter to 0", () => {
      const err = new RateLimitError(429, "rate_limit_exceeded", "Too many requests");
      expect(err.retryAfter).toBe(0);
    });
  });

  describe("ServerError", () => {
    it("has correct name", () => {
      const err = new ServerError(500, "internal_server_error", "Server error");
      expect(err.name).toBe("ServerError");
    });

    it("is an instance of APIError, EnsoulError, and Error", () => {
      const err = new ServerError(500, "internal_server_error", "Server error");
      expect(err).toBeInstanceOf(APIError);
      expect(err).toBeInstanceOf(EnsoulError);
      expect(err).toBeInstanceOf(Error);
    });
  });
});

describe("raiseForStatus()", () => {
  it("does nothing for status < 400", () => {
    expect(() => raiseForStatus(200, {})).not.toThrow();
    expect(() => raiseForStatus(201, {})).not.toThrow();
    expect(() => raiseForStatus(204, {})).not.toThrow();
    expect(() => raiseForStatus(301, {})).not.toThrow();
    expect(() => raiseForStatus(399, {})).not.toThrow();
  });

  it("throws AuthenticationError for 401", () => {
    const body = { error: "invalid_token", message: "Token is invalid", request_id: "req-401" };
    expect(() => raiseForStatus(401, body)).toThrow(AuthenticationError);
    try {
      raiseForStatus(401, body);
    } catch (err) {
      expect(err).toBeInstanceOf(AuthenticationError);
      expect((err as AuthenticationError).statusCode).toBe(401);
      expect((err as AuthenticationError).requestId).toBe("req-401");
    }
  });

  it("throws AuthorizationError for 403", () => {
    const body = { error: "insufficient_tier", message: "Upgrade required" };
    expect(() => raiseForStatus(403, body)).toThrow(AuthorizationError);
  });

  it("throws NotFoundError for 404", () => {
    const body = { error: "not_found", message: "Persona not found" };
    expect(() => raiseForStatus(404, body)).toThrow(NotFoundError);
  });

  it("throws ConflictError for 409", () => {
    const body = { error: "conflict", message: "Already exists" };
    expect(() => raiseForStatus(409, body)).toThrow(ConflictError);
  });

  it("throws ValidationError for 422 with parsed details", () => {
    const body = {
      error: "validation_error",
      message: "Invalid data",
      details: [
        { field: "name", message: "required", type: "missing_field" },
      ],
    };
    try {
      raiseForStatus(422, body);
      expect.fail("should have thrown");
    } catch (err) {
      expect(err).toBeInstanceOf(ValidationError);
      const valErr = err as ValidationError;
      expect(valErr.statusCode).toBe(422);
      expect(valErr.details).toHaveLength(1);
      expect(valErr.details[0].field).toBe("name");
      expect(valErr.details[0].message).toBe("required");
      expect(valErr.details[0].type).toBe("missing_field");
    }
  });

  it("throws RateLimitError for 429 with retryAfter from headers", () => {
    const body = { error: "rate_limit_exceeded", message: "Too many requests" };
    const headers = new Headers({ "Retry-After": "30" });
    try {
      raiseForStatus(429, body, headers);
      expect.fail("should have thrown");
    } catch (err) {
      expect(err).toBeInstanceOf(RateLimitError);
      expect((err as RateLimitError).retryAfter).toBe(30);
    }
  });

  it("throws RateLimitError for 429 with retryAfter=0 when no header", () => {
    const body = { error: "rate_limit_exceeded", message: "Too many requests" };
    try {
      raiseForStatus(429, body);
      expect.fail("should have thrown");
    } catch (err) {
      expect(err).toBeInstanceOf(RateLimitError);
      expect((err as RateLimitError).retryAfter).toBe(0);
    }
  });

  it("throws ServerError for 500", () => {
    const body = { error: "internal_server_error", message: "Server error" };
    expect(() => raiseForStatus(500, body)).toThrow(ServerError);
  });

  it("throws ServerError for 503", () => {
    const body = { error: "service_unavailable", message: "Service unavailable" };
    expect(() => raiseForStatus(503, body)).toThrow(ServerError);
  });

  it("throws generic APIError for unknown 4xx codes (418)", () => {
    const body = { error: "im_a_teapot", message: "I'm a teapot" };
    try {
      raiseForStatus(418, body);
      expect.fail("should have thrown");
    } catch (err) {
      expect(err).toBeInstanceOf(APIError);
      expect(err).not.toBeInstanceOf(AuthenticationError);
      expect(err).not.toBeInstanceOf(AuthorizationError);
      expect(err).not.toBeInstanceOf(NotFoundError);
      expect(err).not.toBeInstanceOf(ValidationError);
      expect(err).not.toBeInstanceOf(RateLimitError);
      expect(err).not.toBeInstanceOf(ServerError);
      expect((err as APIError).statusCode).toBe(418);
    }
  });

  it("uses fallback values when body fields are missing", () => {
    try {
      raiseForStatus(401, {});
      expect.fail("should have thrown");
    } catch (err) {
      expect(err).toBeInstanceOf(AuthenticationError);
      const authErr = err as AuthenticationError;
      expect(authErr.error).toBe("Unknown Error");
      expect(authErr.message).toBe("Unknown error");
      expect(authErr.requestId).toBeUndefined();
    }
  });
});
