import { describe, it, expect, beforeEach, vi } from "vitest";
import { Ensoul } from "../src/client.js";

const TEST_API_KEY = "sk_test_123";
const TEST_BASE_URL = "https://test.ensoul.ai";

// Inline fixture data
const PERSONA_001 = {
  id: "persona_test_001",
  name: "Alex Rivera",
  domain: "test_domain_a",
  personality_data: {
    big_five_domain_scores: {
      openness: 75,
      conscientiousness: 60,
      extraversion: 55,
      agreeableness: 70,
      neuroticism: 40,
    },
  },
  archetype: "creative_professional",
  age: 32,
  country: "test_country_1",
  region: "test_region_1",
  city: "Test City A",
  avatar_url: null,
  batch_id: null,
  created_at: "2025-01-15T10:30:00Z",
};

const PERSONA_002 = {
  id: "persona_test_002",
  name: "Morgan Chen",
  domain: "test_domain_a",
  personality_data: {
    big_five_domain_scores: {
      openness: 40,
      conscientiousness: 85,
      extraversion: 30,
      agreeableness: 65,
      neuroticism: 55,
    },
  },
  archetype: "analyst",
  age: 45,
  country: "test_country_2",
  region: "test_region_2",
  city: "Test City B",
  avatar_url: null,
  batch_id: "batch_test_001",
  created_at: "2025-01-15T10:31:00Z",
};

const PERSONA_003 = {
  id: "persona_test_003",
  name: "Kai Thornton",
  domain: "test_domain_b",
  personality_data: {
    alignment: { lawful_chaotic: 60, good_evil: 80 },
    virtues: { courage: 90, wisdom: 70, temperance: 45 },
  },
  archetype: "guardian",
  age: 28,
  country: "test_country_1",
  region: "test_region_3",
  city: "Test City C",
  avatar_url: null,
  batch_id: null,
  created_at: "2025-02-01T14:00:00Z",
};

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

function mockFetchSequence(
  responses: Array<{ status: number; body: unknown; headers?: Record<string, string> }>
): void {
  const fetchMock = vi.fn();
  responses.forEach((r) => {
    fetchMock.mockResolvedValueOnce(
      new Response(JSON.stringify(r.body), {
        status: r.status,
        headers: new Headers({ "Content-Type": "application/json", ...r.headers }),
      })
    );
  });
  vi.stubGlobal("fetch", fetchMock);
}

beforeEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

describe("Personas resource", () => {
  let client: Ensoul;

  beforeEach(() => {
    client = new Ensoul({ apiKey: TEST_API_KEY, baseUrl: TEST_BASE_URL, maxRetries: 0 });
  });

  describe("create()", () => {
    it("sends a POST request to /v1/personas with correct body", async () => {
      mockFetch(201, PERSONA_001);

      await client.personas.create({
        name: "Alex Rivera",
        domain: "test_domain_a",
        personalityData: { big_five_domain_scores: { openness: 75 } },
      });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      expect(fetchMock).toHaveBeenCalledOnce();
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas");
      expect(init.method).toBe("POST");
    });

    it("sends the API key in the X-API-Key header", async () => {
      mockFetch(201, PERSONA_001);

      await client.personas.create({ name: "Alex Rivera", domain: "test_domain_a" });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const headers = init.headers as Record<string, string>;
      expect(headers["X-API-Key"]).toBe(TEST_API_KEY);
    });

    it("includes all provided fields in the request body", async () => {
      mockFetch(201, PERSONA_001);

      await client.personas.create({
        name: "Alex Rivera",
        domain: "test_domain_a",
        personalityData: { big_five_domain_scores: { openness: 75 } },
      });

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      const body = JSON.parse(init.body as string);
      expect(body.name).toBe("Alex Rivera");
      expect(body.domain).toBe("test_domain_a");
      expect(body.personality_data).toBeDefined();
    });

    it("returns a typed PersonaResponse", async () => {
      mockFetch(201, PERSONA_001);

      const result = await client.personas.create({ name: "Alex Rivera", domain: "test_domain_a" });

      expect(result).toMatchObject({
        id: "persona_test_001",
        name: "Alex Rivera",
        domain: "test_domain_a",
      });
    });
  });

  describe("get()", () => {
    it("sends a GET request to /v1/personas/:id", async () => {
      mockFetch(200, PERSONA_001);

      await client.personas.get("persona_test_001");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas/persona_test_001");
      expect(init.method).toBe("GET");
    });

    it("returns a typed PersonaResponse", async () => {
      mockFetch(200, PERSONA_002);

      const result = await client.personas.get("persona_test_002");

      expect(result).toMatchObject({
        id: "persona_test_002",
        name: "Morgan Chen",
        archetype: "analyst",
      });
    });
  });

  describe("list()", () => {
    it("sends a GET request to /v1/personas", async () => {
      const listResponse = {
        items: [PERSONA_001, PERSONA_002],
        total: 2,
        page: 1,
        per_page: 20,
        pages: 1,
      };
      mockFetch(200, listResponse);

      await client.personas.list();

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas");
    });

    it("returns a Page with correct items, total, page, perPage, pages", async () => {
      const listResponse = {
        items: [PERSONA_001, PERSONA_002],
        total: 50,
        page: 1,
        per_page: 20,
        pages: 3,
      };
      mockFetch(200, listResponse);

      const page = await client.personas.list();

      expect(page.items).toHaveLength(2);
      expect(page.total).toBe(50);
      expect(page.page).toBe(1);
      expect(page.perPage).toBe(20);
      expect(page.pages).toBe(3);
    });

    it("hasNextPage() returns true when not on last page", async () => {
      const listResponse = {
        items: [PERSONA_001],
        total: 50,
        page: 1,
        per_page: 20,
        pages: 3,
      };
      mockFetch(200, listResponse);

      const page = await client.personas.list();
      expect(page.hasNextPage()).toBe(true);
    });

    it("hasNextPage() returns false on last page", async () => {
      const listResponse = {
        items: [PERSONA_001],
        total: 1,
        page: 1,
        per_page: 20,
        pages: 1,
      };
      mockFetch(200, listResponse);

      const page = await client.personas.list();
      expect(page.hasNextPage()).toBe(false);
    });

    it("autoPagingIter() yields all items across 2 pages", async () => {
      const page1Response = {
        items: [PERSONA_001, PERSONA_002],
        total: 3,
        page: 1,
        per_page: 2,
        pages: 2,
      };
      const page2Response = {
        items: [PERSONA_003],
        total: 3,
        page: 2,
        per_page: 2,
        pages: 2,
      };
      mockFetchSequence([
        { status: 200, body: page1Response },
        { status: 200, body: page2Response },
      ]);

      const page = await client.personas.list({ perPage: 2 });
      const allItems: unknown[] = [];
      for await (const item of page.autoPagingIter()) {
        allItems.push(item);
      }

      expect(allItems).toHaveLength(3);
    });
  });

  describe("delete()", () => {
    it("sends a DELETE request to /v1/personas/:id", async () => {
      mockFetch(200, {});

      await client.personas.delete("persona_test_001");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas/persona_test_001");
      expect(init.method).toBe("DELETE");
    });
  });

  describe("batchCreate()", () => {
    it("sends a POST request to /v1/personas/batch with correct body", async () => {
      const batchResponse = {
        batch_id: "batch_test_001",
        created: 2,
        failed: 0,
        personas: [PERSONA_001, PERSONA_002],
      };
      mockFetch(200, batchResponse);

      await client.personas.batchCreate(
        [
          { name: "Alex Rivera", domain: "test_domain_a" },
          { name: "Morgan Chen", domain: "test_domain_a" },
        ],
        { batchId: "batch_test_001" }
      );

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas/batch");
      expect(init.method).toBe("POST");
      const body = JSON.parse(init.body as string);
      expect(body.personas).toHaveLength(2);
      expect(body.batch_id).toBe("batch_test_001");
    });

    it("returns a PersonaBatchResponse", async () => {
      const batchResponse = {
        batch_id: "batch_test_001",
        created: 2,
        failed: 0,
        personas: [PERSONA_001, PERSONA_002],
      };
      mockFetch(200, batchResponse);

      const result = await client.personas.batchCreate([
        { name: "Alex Rivera", domain: "test_domain_a" },
      ]);

      expect(result).toMatchObject({ batch_id: "batch_test_001", created: 2 });
    });
  });

  describe("getPersonality()", () => {
    it("sends a GET request to /v1/personas/:id/personality", async () => {
      const personalityResponse = {
        persona_id: "persona_test_001",
        vector: [0.1, 0.2, 0.3],
        dimensions: ["openness", "conscientiousness", "extraversion"],
      };
      mockFetch(200, personalityResponse);

      await client.personas.getPersonality("persona_test_001");

      const fetchMock = globalThis.fetch as ReturnType<typeof vi.fn>;
      const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
      expect(url).toContain("/v1/personas/persona_test_001/personality");
      expect(init.method).toBe("GET");
    });

    it("returns a PersonalityVectorResponse", async () => {
      const personalityResponse = {
        persona_id: "persona_test_001",
        vector: [0.1, 0.2, 0.3],
        dimensions: ["openness", "conscientiousness", "extraversion"],
      };
      mockFetch(200, personalityResponse);

      const result = await client.personas.getPersonality("persona_test_001");
      expect(result).toMatchObject({ persona_id: "persona_test_001" });
    });
  });
});
