import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";

interface PaginatedData {
  items: Record<string, unknown>[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

/**
 * Sessions resource — hierarchical session orchestration under `/v1/sessions/*`.
 *
 * As of API 0.2.0 these routes are no longer nested under a persona: a session
 * is created against the authenticated team/user context, so `create` no longer
 * takes a `personaId` (the `SessionCreate` body has no persona field). This is a
 * distinct family from `/v1/chat/sessions` (chat-message threads). See
 * `sdks/openapi/namespace-migration-contract.md`.
 */
export class Sessions {
  constructor(private readonly client: HTTPClient) {}

  /** POST /v1/sessions — create a session (`SessionCreate`). */
  async create(
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
    return this.client.post("/v1/sessions", body);
  }

  /** GET /v1/sessions/{sessionId} */
  async get(sessionId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/sessions/${sessionId}`);
  }

  /** DELETE /v1/sessions/{sessionId} */
  async delete(sessionId: string, options?: { cancelChildren?: boolean }): Promise<void> {
    await this.client.delete(`/v1/sessions/${sessionId}`, {
      cancel_children: options?.cancelChildren ?? false,
    });
  }

  /** GET /v1/sessions — list sessions (paginated). */
  async list(
    options?: {
      tier?: number;
      status?: string;
      parentSessionId?: string;
      page?: number;
      perPage?: number;
    },
  ): Promise<Page<Record<string, unknown>>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };
    if (options?.tier != null) params.tier = options.tier;
    if (options?.status != null) params.status = options.status;
    if (options?.parentSessionId != null) params.parent_session_id = options.parentSessionId;

    const data = await this.client.get<PaginatedData>("/v1/sessions", params);

    const fetcher: PageFetcher<Record<string, unknown>> = async (p) => {
      const d = await this.client.get<PaginatedData>("/v1/sessions", p);
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

  /** GET /v1/sessions/hierarchy — full session tree. */
  async hierarchy(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/sessions/hierarchy");
  }

  /** GET /v1/sessions/info — session-system info. */
  async info(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/sessions/info");
  }

  /** GET /v1/sessions/stats/summary — session statistics. */
  async stats(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/sessions/stats/summary");
  }

  /** GET /v1/sessions/{sessionId}/children */
  async getChildren(
    sessionId: string,
    options?: { page?: number; perPage?: number },
  ): Promise<unknown[]> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };
    const data = await this.client.get<unknown>(`/v1/sessions/${sessionId}/children`, params);
    return Array.isArray(data) ? data : ((data as Record<string, unknown>).items as unknown[]) ?? [];
  }

  /** POST /v1/sessions/{sessionId}/aggregate (`AggregateChildrenRequest`). */
  async aggregateChildren(
    sessionId: string,
    options: { aggregationMode?: string } = {},
  ): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {
      aggregation_mode: options.aggregationMode ?? "summary",
    };
    return this.client.post(`/v1/sessions/${sessionId}/aggregate`, body);
  }
}
