import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";

interface PaginatedData {
  items: Record<string, unknown>[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

export class Sessions {
  constructor(private readonly client: HTTPClient) {}

  async create(
    personaId: string,
    options: {
      tier?: number;
      parentSessionId?: string;
      systemInstructions?: string;
      [key: string]: unknown;
    } = {},
  ): Promise<Record<string, unknown>> {
    const { tier, parentSessionId, systemInstructions, ...rest } = options;
    const body: Record<string, unknown> = { tier: tier ?? 0, ...rest };
    if (parentSessionId != null) body.parent_session_id = parentSessionId;
    if (systemInstructions != null) body.system_instructions = systemInstructions;
    return this.client.post(`/v1/personas/${personaId}/sessions`, body);
  }

  async get(personaId: string, sessionId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/personas/${personaId}/sessions/${sessionId}`);
  }

  async list(
    personaId: string,
    options?: { page?: number; perPage?: number },
  ): Promise<Page<Record<string, unknown>>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };

    const data = await this.client.get<PaginatedData>(`/v1/personas/${personaId}/sessions`, params);

    const fetcher: PageFetcher<Record<string, unknown>> = async (p) => {
      const d = await this.client.get<PaginatedData>(`/v1/personas/${personaId}/sessions`, p);
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

  async getChildren(personaId: string, sessionId: string): Promise<unknown[]> {
    const data = await this.client.get<unknown>(
      `/v1/personas/${personaId}/sessions/${sessionId}/children`,
    );
    return Array.isArray(data) ? data : ((data as Record<string, unknown>).items as unknown[]) ?? [];
  }

  async aggregateChildren(
    personaId: string,
    sessionId: string,
    options: { aggregationMode?: string } = {},
  ): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {
      aggregation_mode: options.aggregationMode ?? "summary",
    };
    return this.client.post(
      `/v1/personas/${personaId}/sessions/${sessionId}/aggregate`,
      body,
    );
  }
}
