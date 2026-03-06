/**
 * Cross-SDK conformance tests for the TypeScript SDK.
 *
 * These tests run against a mock server started by the conformance orchestrator.
 * They are automatically skipped when ENSOUL_CONFORMANCE_URL is not set,
 * so regular `vitest run` is unaffected.
 */
import { describe, it, expect, afterAll } from "vitest";
import { Ensoul } from "../src/client.js";
import {
  NotFoundError,
  AuthenticationError,
  AuthorizationError,
  RateLimitError,
  ValidationError,
  ServerError,
} from "../src/errors.js";
import { parseChatEvent, type ChatStreamEvent } from "../src/streaming.js";
import type { HTTPClient } from "../src/http.js";

const CONFORMANCE_URL = process.env.ENSOUL_CONFORMANCE_URL;
const describeConformance = CONFORMANCE_URL ? describe : describe.skip;

describeConformance("Conformance Tests", () => {
  const client = new Ensoul({
    apiKey: "sk_test_123",
    baseUrl: CONFORMANCE_URL!,
    maxRetries: 0,
    customHeaders: { "X-SDK-Language": "typescript" },
  });

  const noAuthClient = new Ensoul({
    apiKey: "",
    baseUrl: CONFORMANCE_URL!,
    maxRetries: 0,
  });

  afterAll(() => {
    client.close();
    noAuthClient.close();
  });

  // ---------------------------------------------------------------------------
  // Personas
  // ---------------------------------------------------------------------------

  describe("Personas", () => {
    it("test_persona_create", async () => {
      const persona = await client.personas.create({
        name: "Test Persona",
        domain: "test_domain",
        personalityData: { trait_a: 75, trait_b: 50 },
      });
      expect(persona.id).toBe("p_test_001");
      expect(persona.name).toBe("Test Persona");
      expect(persona.domain).toBe("test_domain");
    });

    it("test_persona_get", async () => {
      const persona = await client.personas.get("p_test_001");
      expect(persona.id).toBe("p_test_001");
      expect(persona.name).toBe("Test Persona");
      expect(persona.domain).toBe("test_domain");
    });

    it("test_persona_update", async () => {
      const persona = await client.personas.update("p_test_001", {
        name: "Updated Persona",
        personalityData: { trait_a: 80, trait_b: 60 },
      });
      expect(persona.id).toBe("p_test_001");
      expect(persona.name).toBe("Updated Persona");
    });

    it("test_persona_delete", async () => {
      await expect(
        client.personas.delete("p_test_001"),
      ).resolves.toBeUndefined();
    });

    it("test_persona_list_pagination", async () => {
      const page = await client.personas.list({ page: 1, perPage: 10 });
      expect(page.items.length).toBeGreaterThanOrEqual(1);
      expect(page.total).toBe(25);
      expect(page.page).toBe(1);
      expect(page.perPage).toBe(10);
      expect(page.pages).toBe(3);
    });

    it("test_persona_not_found", async () => {
      await expect(
        client.personas.get("nonexistent_persona_id"),
      ).rejects.toThrow(NotFoundError);

      try {
        await client.personas.get("nonexistent_persona_id");
      } catch (err) {
        expect(err).toBeInstanceOf(NotFoundError);
        expect((err as NotFoundError).statusCode).toBe(404);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------

  describe("Chat", () => {
    it("test_chat_send", async () => {
      const response = await client.chat.send("p_test_001", "Hello, how are you?");
      expect(response.response).toBeTruthy();
      expect(response.conversation_id).toBeTruthy();
      expect(response.token_usage.total_tokens).toBeGreaterThan(0);
    });

    it("test_chat_stream_sse", async () => {
      const stream = await client.chat.stream("p_test_001", "Tell me about yourself.");
      const events: ChatStreamEvent[] = [];

      for await (const sseEvent of stream) {
        events.push(parseChatEvent(sseEvent));
      }

      expect(events).toHaveLength(5);

      // Check chunk ordering
      for (let i = 0; i < events.length; i++) {
        expect(events[i]!.chunkIndex).toBe(i);
      }

      // Final event
      const lastEvent = events[events.length - 1]!;
      expect(lastEvent.isFinal).toBe(true);
      expect(lastEvent.tokenUsage).toBeDefined();
      expect(lastEvent.tokenUsage!.totalTokens).toBeGreaterThan(0);

      // Non-final events
      for (const event of events.slice(0, -1)) {
        expect(event.isFinal).toBe(false);
      }
    });

    it("test_chat_get_conversations", async () => {
      const page = await client.chat.getConversations("p_test_001");
      expect(page.items.length).toBeGreaterThanOrEqual(1);
      expect(page.total).toBe(2);
    });
  });

  // ---------------------------------------------------------------------------
  // Domains
  // ---------------------------------------------------------------------------

  describe("Domains", () => {
    it("test_domain_list", async () => {
      const page = await client.domains.list();
      expect(page.items.length).toBeGreaterThanOrEqual(1);
    });

    it("test_domain_get", async () => {
      const domain = await client.domains.get("d_test_001");
      expect(domain.id).toBe("d_test_001");
      expect(domain.name).toBe("Test Domain");
    });
  });

  // ---------------------------------------------------------------------------
  // Simulations
  // ---------------------------------------------------------------------------

  describe("Simulations", () => {
    it("test_simulation_create", async () => {
      const sim = await client.simulations.create({
        name: "Test Simulation",
        domainId: "d_test_001",
      });
      expect(sim.id).toBe("sim_test_001");
      expect(sim.status).toBe("created");
    });

    it("test_simulation_start", async () => {
      const result = await client.simulations.start("sim_test_001", { ticks: 50 });
      expect(result.status).toBe("running");
      expect(result.ticks_requested).toBe(50);
    });
  });

  // ---------------------------------------------------------------------------
  // Memory
  // ---------------------------------------------------------------------------

  describe("Memory", () => {
    it("test_memory_create", async () => {
      const mem = await client.memory.create("p_test_001", {
        content: "Remembered something important",
        memoryType: "episodic",
        importance: 0.7,
      });
      expect(mem.id).toBe("mem_test_001");
    });

    it("test_memory_delete", async () => {
      await expect(
        client.memory.delete("p_test_001", "mem_test_001"),
      ).resolves.toBeUndefined();
    });
  });

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  describe("Sessions", () => {
    it("test_session_create", async () => {
      const session = await client.sessions.create("p_test_001", { tier: 0 });
      expect(session.id).toBe("sess_test_001");
      expect(session.tier).toBe(0);
      expect(session.parent_session_id).toBeNull();
    });
  });

  // ---------------------------------------------------------------------------
  // Aggregate
  // ---------------------------------------------------------------------------

  describe("Aggregate", () => {
    it("test_aggregate_query", async () => {
      const result = await client.aggregate.query("average trait_a by region");
      expect(result.sample_size).toBe(500);
      expect(result.confidence).toBe(0.95);
    });
  });

  // ---------------------------------------------------------------------------
  // Health
  // ---------------------------------------------------------------------------

  describe("Health", () => {
    it("test_health_check", async () => {
      const result = await client.health.check();
      expect(result.status).toBe("ok");
      expect(result.version).toBeTruthy();
    });
  });

  // ---------------------------------------------------------------------------
  // Info
  // ---------------------------------------------------------------------------

  describe("Info", () => {
    it("test_info_config", async () => {
      const result = await client.info.config();
      expect(result.api_version).toBe("1.0.0");
      expect(result.max_batch_size).toBe(100);
    });
  });

  // ---------------------------------------------------------------------------
  // Auth Resources
  // ---------------------------------------------------------------------------

  describe("Auth Resources", () => {
    it("test_auth_token_exchange", async () => {
      const token = await client.auth.token("testuser", "testpass");
      expect(token.access_token).toBeTruthy();
      expect(token.token_type).toBe("bearer");
      expect(token.expires_in).toBe(3600);
    });

    it("test_auth_me", async () => {
      const user = await client.auth.me();
      expect(user.consumer_id).toBe("user_test_001");
      expect(user.username).toBe("testuser");
    });
  });

  // ---------------------------------------------------------------------------
  // Frameworks
  // ---------------------------------------------------------------------------

  describe("Frameworks", () => {
    it("test_framework_update", async () => {
      const fw = await client.frameworks.update("fw_test_001", {
        name: "Big Five Updated",
      });
      expect(fw.id).toBe("fw_test_001");
      expect(fw.name).toBe("Big Five Updated");
    });
  });

  // ---------------------------------------------------------------------------
  // Errors
  // ---------------------------------------------------------------------------

  describe("Errors", () => {
    it("test_error_rate_limit", async () => {
      const rateLimitClient = new Ensoul({
        apiKey: "sk_test_123",
        baseUrl: CONFORMANCE_URL!,
        maxRetries: 0,
        customHeaders: { "X-Trigger-RateLimit": "true" },
      });

      try {
        await expect(rateLimitClient.personas.list()).rejects.toThrow(RateLimitError);

        try {
          await rateLimitClient.personas.list();
        } catch (err) {
          expect(err).toBeInstanceOf(RateLimitError);
          expect((err as RateLimitError).retryAfter).toBe(30);
        }
      } finally {
        rateLimitClient.close();
      }
    });

    it("test_error_validation", async () => {
      // Access the internal HTTP client to POST an empty body to /v1/personas
      const httpClient = (client as unknown as { _client: HTTPClient })._client;

      await expect(
        httpClient.post("/v1/personas", {}),
      ).rejects.toThrow(ValidationError);

      try {
        await httpClient.post("/v1/personas", {});
      } catch (err) {
        expect(err).toBeInstanceOf(ValidationError);
        expect((err as ValidationError).details.length).toBeGreaterThanOrEqual(1);
      }
    });

    it("test_error_authentication", async () => {
      await expect(noAuthClient.personas.list()).rejects.toThrow(AuthenticationError);

      try {
        await noAuthClient.personas.list();
      } catch (err) {
        expect(err).toBeInstanceOf(AuthenticationError);
        expect((err as AuthenticationError).statusCode).toBe(401);
      }
    });

    it("test_error_server", async () => {
      const serverErrorClient = new Ensoul({
        apiKey: "sk_test_123",
        baseUrl: CONFORMANCE_URL!,
        maxRetries: 0,
        customHeaders: { "X-Trigger-ServerError": "true" },
      });

      try {
        await expect(serverErrorClient.personas.list()).rejects.toThrow(ServerError);

        try {
          await serverErrorClient.personas.list();
        } catch (err) {
          expect(err).toBeInstanceOf(ServerError);
          expect((err as ServerError).statusCode).toBe(500);
        }
      } finally {
        serverErrorClient.close();
      }
    });

    it("test_error_authorization_forbidden", async () => {
      const forbiddenClient = new Ensoul({
        apiKey: "sk_test_123",
        baseUrl: CONFORMANCE_URL!,
        maxRetries: 0,
        customHeaders: { "X-Trigger-Forbidden": "true" },
      });

      try {
        await expect(forbiddenClient.personas.list()).rejects.toThrow(AuthorizationError);

        try {
          await forbiddenClient.personas.list();
        } catch (err) {
          expect(err).toBeInstanceOf(AuthorizationError);
          expect((err as AuthorizationError).statusCode).toBe(403);
        }
      } finally {
        forbiddenClient.close();
      }
    });

    it("test_error_retry_503", async () => {
      const retryClient = new Ensoul({
        apiKey: "sk_test_123",
        baseUrl: CONFORMANCE_URL!,
        maxRetries: 2,
        customHeaders: {
          "X-Trigger-503-Once": "true",
          "X-SDK-Language": "typescript-retry",
        },
      });

      try {
        const page = await retryClient.personas.list();
        expect(page.items.length).toBeGreaterThanOrEqual(1);
      } finally {
        retryClient.close();
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  describe("Auth", () => {
    it("test_auth_api_key_header", async () => {
      // If we can list personas successfully, the auth header was correct
      const page = await client.personas.list();
      expect(page.items.length).toBeGreaterThanOrEqual(1);
    });

    it("test_auth_no_credentials", async () => {
      await expect(noAuthClient.personas.list()).rejects.toThrow(AuthenticationError);
    });

    it("test_auth_bearer_token", async () => {
      const bearerClient = new Ensoul({
        bearerToken: "test_token_123",
        baseUrl: CONFORMANCE_URL!,
        maxRetries: 0,
      });

      try {
        const page = await bearerClient.personas.list();
        expect(page.items.length).toBeGreaterThanOrEqual(1);
      } finally {
        bearerClient.close();
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  describe("Pagination", () => {
    it("test_pagination_auto_fetch", async () => {
      const page = await client.frameworks.list({ perPage: 2 });
      const allItems: Record<string, unknown>[] = [];

      for await (const item of page.autoPagingIter()) {
        allItems.push(item);
      }

      expect(allItems).toHaveLength(3);
    });
  });

  // ---------------------------------------------------------------------------
  // Client Configuration
  // ---------------------------------------------------------------------------

  describe("Client Configuration", () => {
    it("test_client_custom_base_url", async () => {
      // Verify the client respects custom baseUrl by connecting to mock server
      const customClient = new Ensoul({
        apiKey: "sk_test_123",
        baseUrl: CONFORMANCE_URL!,
        maxRetries: 0,
      });

      try {
        const page = await customClient.personas.list();
        expect(page.items.length).toBeGreaterThanOrEqual(1);
      } finally {
        customClient.close();
      }
    });
  });
});
