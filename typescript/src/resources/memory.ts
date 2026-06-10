import type { HTTPClient } from "../http.js";

/**
 * Memory resource — `/v1/memory/*`.
 *
 * As of API 0.2.0 these routes were rebased off `/v1/personas/{id}/memories`
 * onto `/v1/memory/{personaId}`. See
 * `sdks/openapi/namespace-migration-contract.md`.
 */
export class Memory {
  constructor(private readonly client: HTTPClient) {}

  /** GET /v1/memory/stats — global memory statistics. */
  async stats(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/memory/stats");
  }

  /** POST /v1/memory/{personaId} — add a memory (`MemoryCreate`). */
  async create(
    personaId: string,
    options: {
      content: string;
      source?: string;
      references?: Record<string, unknown>;
    },
  ): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {
      content: options.content,
      source: options.source ?? "user",
    };
    if (options.references != null) body.references = options.references;
    return this.client.post(`/v1/memory/${personaId}`, body);
  }

  /**
   * GET /v1/memory/{personaId} — list memories.
   *
   * Returns the `MemoriesResponse` shape
   * `{ persona_id, memories, working_memory, total }` (not a paginated
   * envelope — the API does not page this route).
   */
  async list(
    personaId: string,
    options?: { limit?: number; offset?: number },
  ): Promise<Record<string, unknown>> {
    const params: Record<string, unknown> = {
      limit: options?.limit ?? 50,
      offset: options?.offset ?? 0,
    };
    return this.client.get(`/v1/memory/${personaId}`, params);
  }

  /** DELETE /v1/memory/{personaId} — delete all memories for a persona. */
  async clear(personaId: string): Promise<void> {
    await this.client.delete(`/v1/memory/${personaId}`);
  }

  /** DELETE /v1/memory/{personaId}/{memoryId} — delete one memory. */
  async delete(personaId: string, memoryId: string): Promise<void> {
    await this.client.delete(`/v1/memory/${personaId}/${memoryId}`);
  }

  /** PATCH /v1/memory/{personaId}/{memoryId}/access — record an access. */
  async updateAccess(personaId: string, memoryId: string): Promise<Record<string, unknown>> {
    return this.client.patch(`/v1/memory/${personaId}/${memoryId}/access`);
  }

  /** POST /v1/memory/{personaId}/batch — add many memories at once. */
  async batchCreate(
    personaId: string,
    memories: Array<Record<string, unknown>>,
  ): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/memory/${personaId}/batch`, { memories });
  }

  /** POST /v1/memory/{personaId}/consolidate — consolidate memories. */
  async consolidate(personaId: string): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/memory/${personaId}/consolidate`, {});
  }

  /** POST /v1/memory/{personaId}/generate — generate memories. */
  async generate(
    personaId: string,
    options: Record<string, unknown> = {},
  ): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/memory/${personaId}/generate`, options);
  }

  /** GET /v1/memory/{personaId}/working — working-memory snapshot. */
  async working(personaId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/memory/${personaId}/working`);
  }

  /** GET /v1/memory/{personaId}/knowledge — retrieve RAG knowledge. */
  async getKnowledge(personaId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/memory/${personaId}/knowledge`);
  }

  /** POST /v1/memory/{personaId}/knowledge — add RAG knowledge (`KnowledgeCreate`). */
  async addKnowledge(
    personaId: string,
    options: { content: string; source: string },
  ): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/memory/${personaId}/knowledge`, {
      content: options.content,
      source: options.source,
    });
  }
}
