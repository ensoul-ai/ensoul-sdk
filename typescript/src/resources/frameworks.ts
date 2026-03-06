import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";

interface PaginatedData {
  items: Record<string, unknown>[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

export class Frameworks {
  constructor(private readonly client: HTTPClient) {}

  async list(options?: { page?: number; perPage?: number }): Promise<Page<Record<string, unknown>>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };

    const data = await this.client.get<PaginatedData>("/v1/frameworks", params);

    const fetcher: PageFetcher<Record<string, unknown>> = async (p) => {
      const d = await this.client.get<PaginatedData>("/v1/frameworks", p);
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

  async get(frameworkId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/frameworks/${frameworkId}`);
  }

  async create(config: Record<string, unknown>): Promise<Record<string, unknown>> {
    return this.client.post("/v1/frameworks", config);
  }

  async update(frameworkId: string, config: Record<string, unknown>): Promise<Record<string, unknown>> {
    return this.client.put(`/v1/frameworks/${frameworkId}`, config);
  }

  async delete(frameworkId: string): Promise<void> {
    await this.client.delete(`/v1/frameworks/${frameworkId}`);
  }

  async validate(frameworkId: string): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/frameworks/${frameworkId}/validate`, {});
  }

  async getInstruments(frameworkId: string): Promise<unknown[]> {
    const data = await this.client.get<unknown>(`/v1/frameworks/${frameworkId}/instruments`);
    return Array.isArray(data) ? data : ((data as Record<string, unknown>).items as unknown[]) ?? [];
  }
}
