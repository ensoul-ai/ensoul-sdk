import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";

interface PaginatedData {
  items: Record<string, unknown>[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

export class Memory {
  constructor(private readonly client: HTTPClient) {}

  async create(
    personaId: string,
    options: {
      content: string;
      memoryType?: string;
      importance?: number;
      metadata?: Record<string, unknown>;
    },
  ): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {
      content: options.content,
      memory_type: options.memoryType ?? "episodic",
      importance: options.importance ?? 0.5,
    };
    if (options.metadata != null) body.metadata = options.metadata;
    return this.client.post(`/v1/personas/${personaId}/memories`, body);
  }

  async list(
    personaId: string,
    options?: { page?: number; perPage?: number },
  ): Promise<Page<Record<string, unknown>>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };

    const data = await this.client.get<PaginatedData>(`/v1/personas/${personaId}/memories`, params);

    const fetcher: PageFetcher<Record<string, unknown>> = async (p) => {
      const d = await this.client.get<PaginatedData>(`/v1/personas/${personaId}/memories`, p);
      return { items: d.items, total: d.total, page: d.page, perPage: d.per_page, pages: d.pages };
    };

    return new Page<Record<string, unknown>>({
      items: data.items,
      total: data.total ?? data.items.length,
      page: data.page ?? 1,
      perPage: data.per_page ?? 20,
      pages: data.pages ?? 1,
      params,
      fetcher,
    });
  }

  async get(personaId: string, memoryId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/personas/${personaId}/memories/${memoryId}`);
  }

  async delete(personaId: string, memoryId: string): Promise<void> {
    await this.client.delete(`/v1/personas/${personaId}/memories/${memoryId}`);
  }

  async batchCreate(personaId: string, memories: Array<Record<string, unknown>>): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/personas/${personaId}/memories/batch`, { memories });
  }

  async consolidate(personaId: string): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/personas/${personaId}/memories/consolidate`, {});
  }

  async queryKnowledge(personaId: string, query: string): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/personas/${personaId}/knowledge/query`, { query });
  }
}
