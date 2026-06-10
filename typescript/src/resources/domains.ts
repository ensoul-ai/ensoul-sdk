import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";

interface PaginatedData {
  items: Record<string, unknown>[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

export class Domains {
  constructor(private readonly client: HTTPClient) {}

  async list(options?: {
    page?: number;
    perPage?: number;
  }): Promise<Page<Record<string, unknown>>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };

    const data = await this.client.get<PaginatedData>("/v1/domains", params);

    const fetcher: PageFetcher<Record<string, unknown>> = async (p) => {
      const d = await this.client.get<PaginatedData>("/v1/domains", p);
      return { items: d.items, total: d.total, page: d.page, perPage: d.per_page, pages: d.pages };
    };

    return new Page<Record<string, unknown>>({
      items: data.items,
      total: data.total,
      page: data.page,
      perPage: data.per_page,
      pages: data.pages,
      params,
      fetcher,
    });
  }

  async get(domainId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/domains/${domainId}`);
  }

  async create(config: Record<string, unknown>): Promise<Record<string, unknown>> {
    return this.client.post("/v1/domains", config);
  }

  async update(domainId: string, config: Record<string, unknown>): Promise<Record<string, unknown>> {
    return this.client.put(`/v1/domains/${domainId}`, config);
  }

  async delete(domainId: string): Promise<void> {
    await this.client.delete(`/v1/domains/${domainId}`);
  }

  /** POST /v1/domains/validate — validate a domain config (`DomainConfigCreate`). */
  async validate(config: Record<string, unknown>): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/domains/validate`, config);
  }
}
