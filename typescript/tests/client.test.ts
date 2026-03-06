import { describe, it, expect, beforeEach, vi } from "vitest";
import { Ensoul } from "../src/client.js";

function mockFetch(status: number, body: unknown): void {
  vi.stubGlobal(
    "fetch",
    vi.fn().mockResolvedValue(
      new Response(JSON.stringify(body), {
        status,
        headers: new Headers({ "Content-Type": "application/json" }),
      })
    )
  );
}

beforeEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
  mockFetch(200, {});
});

describe("Ensoul client", () => {
  describe("constructor", () => {
    it("creates a client instance with default options", () => {
      const client = new Ensoul({ apiKey: "sk_test_123" });
      expect(client).toBeInstanceOf(Ensoul);
    });

    it("creates with custom options", () => {
      const client = new Ensoul({
        apiKey: "sk_test_123",
        baseUrl: "https://custom.ensoul.ai",
        timeout: 5_000,
        maxRetries: 1,
      });
      expect(client).toBeInstanceOf(Ensoul);
    });

    it("creates with no options (empty constructor)", () => {
      const client = new Ensoul();
      expect(client).toBeInstanceOf(Ensoul);
    });
  });

  describe("resource namespaces", () => {
    it("creates the personas resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.personas).toBeDefined();
    });

    it("creates the chat resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.chat).toBeDefined();
    });

    it("creates the domains resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.domains).toBeDefined();
    });

    it("creates the simulations resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.simulations).toBeDefined();
    });

    it("creates the aggregate resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.aggregate).toBeDefined();
    });

    it("creates the memory resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.memory).toBeDefined();
    });

    it("creates the sessions resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.sessions).toBeDefined();
    });

    it("creates the frameworks resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.frameworks).toBeDefined();
    });

    it("creates the auth resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.auth).toBeDefined();
    });

    it("creates the health resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.health).toBeDefined();
    });

    it("creates the info resource", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(client.info).toBeDefined();
    });

    it("creates all 11 resource namespaces", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      const resources = [
        "personas",
        "chat",
        "domains",
        "simulations",
        "aggregate",
        "memory",
        "sessions",
        "frameworks",
        "auth",
        "health",
        "info",
      ] as const;
      for (const resource of resources) {
        expect(client[resource]).toBeDefined();
      }
    });
  });

  describe("resource methods exist", () => {
    it("personas has expected methods", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(typeof client.personas.create).toBe("function");
      expect(typeof client.personas.get).toBe("function");
      expect(typeof client.personas.list).toBe("function");
      expect(typeof client.personas.delete).toBe("function");
      expect(typeof client.personas.batchCreate).toBe("function");
      expect(typeof client.personas.getPersonality).toBe("function");
    });

    it("chat has expected methods", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(typeof client.chat.send).toBe("function");
      expect(typeof client.chat.getConversations).toBe("function");
      expect(typeof client.chat.getConversation).toBe("function");
    });
  });

  describe("close()", () => {
    it("close() can be called without throwing", () => {
      const client = new Ensoul({ apiKey: "sk_test" });
      expect(() => client.close()).not.toThrow();
    });
  });
});
