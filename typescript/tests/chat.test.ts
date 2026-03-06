import { describe, it, expect, beforeEach, vi } from "vitest";
import { Ensoul } from "../src/client.js";

const TEST_API_KEY = "sk_test_123";
const TEST_BASE_URL = "https://test.ensoul.ai";

function mockFetch(status: number, body: unknown, headers?: Record<string, string>): void {
  vi.stubGlobal(
    "fetch",
    vi.fn().mockResolvedValue(
      new Response(JSON.stringify(body), {
        status,
        headers: new Headers({ "Content-Type": "application/json", ...headers }),
      })
    )
  );
}

beforeEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

describe("Chat resource", () => {
  let client: Ensoul;

  beforeEach(() => {
    client = new Ensoul({ apiKey: TEST_API_KEY, baseUrl: TEST_BASE_URL, maxRetries: 0 });
  });

  describe("send()", () => {
    const CHAT_RESPONSE = {
      response: "Hello! I'm Alex Rivera, nice to meet you.",
      conversation_id: "conv_abc123",
      persona_id: "persona_test_001",
      message_id: "msg_001",
      token_usage: { input_tokens: 10, output_tokens: 25, total_tokens: 35 },
    };

    it("sends a POST request to /v1/personas/:id/chat", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Hello!");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas/persona_test_001/chat");
      expect(init.method).toBe("POST");
    });

    it("includes the message in the request body", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Hello, how are you?");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.message).toBe("Hello, how are you?");
    });

    it("includes optional conversationId in request body when provided", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Continue our chat", {
        conversationId: "conv_existing",
      });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.conversation_id).toBe("conv_existing");
    });

    it("includes temperature when provided", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Hello", { temperature: 0.7 });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.temperature).toBe(0.7);
    });

    it("includes maxTokens when provided", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Hello", { maxTokens: 500 });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.max_tokens).toBe(500);
    });

    it("includes includeMemories when provided", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Hello", { includeMemories: true });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.include_memories).toBe(true);
    });

    it("includes includeKnowledge when provided", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Hello", { includeKnowledge: false });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.include_knowledge).toBe(false);
    });

    it("does not include optional fields when not provided", async () => {
      mockFetch(200, CHAT_RESPONSE);

      await client.chat.send("persona_test_001", "Hello");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body).not.toHaveProperty("conversation_id");
      expect(body).not.toHaveProperty("temperature");
      expect(body).not.toHaveProperty("max_tokens");
      expect(body).not.toHaveProperty("include_memories");
      expect(body).not.toHaveProperty("include_knowledge");
    });

    it("returns a ChatResponse", async () => {
      mockFetch(200, CHAT_RESPONSE);

      const result = await client.chat.send("persona_test_001", "Hello!");

      expect(result).toMatchObject({
        response: "Hello! I'm Alex Rivera, nice to meet you.",
        conversation_id: "conv_abc123",
        persona_id: "persona_test_001",
      });
    });
  });

  describe("getConversations()", () => {
    const CONVERSATION_LIST_RESPONSE = {
      items: [
        {
          conversation_id: "conv_abc123",
          persona_id: "persona_test_001",
          message_count: 5,
          created_at: "2025-01-15T10:30:00Z",
          updated_at: "2025-01-15T10:35:00Z",
        },
        {
          conversation_id: "conv_def456",
          persona_id: "persona_test_001",
          message_count: 2,
          created_at: "2025-01-14T09:00:00Z",
          updated_at: "2025-01-14T09:05:00Z",
        },
      ],
      total: 2,
      page: 1,
      per_page: 20,
      pages: 1,
    };

    it("sends a GET request to /v1/personas/:id/conversations", async () => {
      mockFetch(200, CONVERSATION_LIST_RESPONSE);

      await client.chat.getConversations("persona_test_001");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas/persona_test_001/conversations");
      expect(init.method).toBe("GET");
    });

    it("returns a paginated list of conversations", async () => {
      mockFetch(200, CONVERSATION_LIST_RESPONSE);

      const page = await client.chat.getConversations("persona_test_001");

      expect(page.items).toHaveLength(2);
      expect(page.total).toBe(2);
      expect(page.page).toBe(1);
      expect(page.perPage).toBe(20);
      expect(page.pages).toBe(1);
    });

    it("passes page and perPage query parameters", async () => {
      mockFetch(200, { ...CONVERSATION_LIST_RESPONSE, page: 2, per_page: 10 });

      await client.chat.getConversations("persona_test_001", { page: 2, perPage: 10 });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("page=2");
      expect(url).toContain("per_page=10");
    });
  });

  describe("getConversation()", () => {
    const CONVERSATION_RESPONSE = {
      conversation_id: "conv_abc123",
      persona_id: "persona_test_001",
      messages: [
        { role: "user", content: "Hello!", created_at: "2025-01-15T10:30:00Z" },
        {
          role: "assistant",
          content: "Hi there!",
          created_at: "2025-01-15T10:30:01Z",
        },
      ],
      created_at: "2025-01-15T10:30:00Z",
      updated_at: "2025-01-15T10:30:01Z",
    };

    it("sends a GET request to /v1/personas/:id/conversations/:convId", async () => {
      mockFetch(200, CONVERSATION_RESPONSE);

      await client.chat.getConversation("persona_test_001", "conv_abc123");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas/persona_test_001/conversations/conv_abc123");
      expect(init.method).toBe("GET");
    });

    it("returns a ConversationResponse", async () => {
      mockFetch(200, CONVERSATION_RESPONSE);

      const result = await client.chat.getConversation("persona_test_001", "conv_abc123");

      expect(result).toMatchObject({
        conversation_id: "conv_abc123",
        persona_id: "persona_test_001",
      });
    });

    it("includes messages in the response", async () => {
      mockFetch(200, CONVERSATION_RESPONSE);

      const result = await client.chat.getConversation("persona_test_001", "conv_abc123");

      expect((result as typeof CONVERSATION_RESPONSE).messages).toHaveLength(2);
    });
  });
});
