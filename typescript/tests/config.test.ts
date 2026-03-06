import { describe, it, expect, beforeEach, vi } from "vitest";
import {
  buildConfig,
  DEFAULT_BASE_URL,
  DEFAULT_TIMEOUT,
  DEFAULT_MAX_RETRIES,
} from "../src/config.js";

beforeEach(() => {
  vi.restoreAllMocks();
  // Clear the env var between tests
  delete process.env.ENSOUL_API_KEY;
});

describe("buildConfig()", () => {
  describe("default values", () => {
    it("uses the default base URL", () => {
      const config = buildConfig({});
      expect(config.baseUrl).toBe(DEFAULT_BASE_URL);
      expect(config.baseUrl).toBe("https://api.ensoul.ai");
    });

    it("uses the default timeout", () => {
      const config = buildConfig({});
      expect(config.timeout).toBe(DEFAULT_TIMEOUT);
      expect(config.timeout).toBe(30_000);
    });

    it("uses the default max retries", () => {
      const config = buildConfig({});
      expect(config.maxRetries).toBe(DEFAULT_MAX_RETRIES);
      expect(config.maxRetries).toBe(2);
    });

    it("defaults customHeaders to an empty object", () => {
      const config = buildConfig({});
      expect(config.customHeaders).toEqual({});
    });

    it("defaults apiKey to undefined when not provided and env not set", () => {
      const config = buildConfig({});
      expect(config.apiKey).toBeUndefined();
    });

    it("defaults bearerToken to undefined", () => {
      const config = buildConfig({});
      expect(config.bearerToken).toBeUndefined();
    });
  });

  describe("custom values override defaults", () => {
    it("accepts a custom baseUrl", () => {
      const config = buildConfig({ baseUrl: "https://custom.example.com" });
      expect(config.baseUrl).toBe("https://custom.example.com");
    });

    it("accepts a custom timeout", () => {
      const config = buildConfig({ timeout: 5_000 });
      expect(config.timeout).toBe(5_000);
    });

    it("accepts a custom maxRetries", () => {
      const config = buildConfig({ maxRetries: 5 });
      expect(config.maxRetries).toBe(5);
    });

    it("accepts zero maxRetries", () => {
      const config = buildConfig({ maxRetries: 0 });
      expect(config.maxRetries).toBe(0);
    });

    it("accepts custom headers", () => {
      const config = buildConfig({ customHeaders: { "X-Custom": "value" } });
      expect(config.customHeaders).toEqual({ "X-Custom": "value" });
    });

    it("accepts a bearerToken", () => {
      const config = buildConfig({ bearerToken: "my-bearer-token" });
      expect(config.bearerToken).toBe("my-bearer-token");
    });
  });

  describe("apiKey resolution", () => {
    it("uses apiKey from options when provided", () => {
      const config = buildConfig({ apiKey: "sk_test_from_options" });
      expect(config.apiKey).toBe("sk_test_from_options");
    });

    it("falls back to ENSOUL_API_KEY env variable when no apiKey option", () => {
      process.env.ENSOUL_API_KEY = "sk_env_key";
      const config = buildConfig({});
      expect(config.apiKey).toBe("sk_env_key");
    });

    it("apiKey from options takes priority over env variable", () => {
      process.env.ENSOUL_API_KEY = "sk_env_key";
      const config = buildConfig({ apiKey: "sk_options_key" });
      expect(config.apiKey).toBe("sk_options_key");
    });

    it("results in undefined when no apiKey provided and env not set", () => {
      delete process.env.ENSOUL_API_KEY;
      const config = buildConfig({});
      expect(config.apiKey).toBeUndefined();
    });
  });

  describe("full config object shape", () => {
    it("returns all required fields", () => {
      const config = buildConfig({ apiKey: "sk_test", baseUrl: "https://api.test.com" });
      expect(config).toHaveProperty("baseUrl");
      expect(config).toHaveProperty("apiKey");
      expect(config).toHaveProperty("bearerToken");
      expect(config).toHaveProperty("timeout");
      expect(config).toHaveProperty("maxRetries");
      expect(config).toHaveProperty("customHeaders");
    });

    it("can combine all options", () => {
      const config = buildConfig({
        apiKey: "sk_all",
        baseUrl: "https://api.combined.com",
        bearerToken: "bearer-abc",
        timeout: 10_000,
        maxRetries: 3,
        customHeaders: { "X-Org": "acme" },
      });
      expect(config.apiKey).toBe("sk_all");
      expect(config.baseUrl).toBe("https://api.combined.com");
      expect(config.bearerToken).toBe("bearer-abc");
      expect(config.timeout).toBe(10_000);
      expect(config.maxRetries).toBe(3);
      expect(config.customHeaders).toEqual({ "X-Org": "acme" });
    });
  });
});
