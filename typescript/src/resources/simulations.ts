import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";
import { SSEStream } from "../streaming.js";
import type { SimulationDetailResponse } from "../generated/simulations.js";

interface PaginatedData {
  items: Record<string, unknown>[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

export class Simulations {
  constructor(private readonly client: HTTPClient) {}

  async create(options: {
    name: string;
    /** `domain` is accepted as an alias; `domainId` takes precedence when both are given. */
    domainId?: string;
    domain?: string;
    description?: string;
    config?: Record<string, unknown>;
    participantPersonaIds?: string[];
  }): Promise<SimulationDetailResponse> {
    const domainId = options.domainId ?? options.domain;
    if (domainId == null) {
      throw new TypeError("create() requires 'domainId' (or its alias 'domain')");
    }
    const body: Record<string, unknown> = {
      name: options.name,
      domain_id: domainId,
    };
    if (options.description != null) body.description = options.description;
    if (options.config != null) body.config = options.config;
    if (options.participantPersonaIds != null) body.participant_persona_ids = options.participantPersonaIds;
    return this.client.post<SimulationDetailResponse>("/v1/simulations", body);
  }

  async get(simulationId: string): Promise<SimulationDetailResponse> {
    return this.client.get<SimulationDetailResponse>(`/v1/simulations/${simulationId}`);
  }

  async list(options?: {
    page?: number;
    perPage?: number;
  }): Promise<Page<Record<string, unknown>>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };

    const data = await this.client.get<PaginatedData>("/v1/simulations", params);

    const fetcher: PageFetcher<Record<string, unknown>> = async (p) => {
      const d = await this.client.get<PaginatedData>("/v1/simulations", p);
      return { items: d.items, total: d.total, page: d.page, perPage: d.per_page, pages: d.pages };
    };

    return new Page<Record<string, unknown>>({
      items: data.items, total: data.total, page: data.page,
      perPage: data.per_page, pages: data.pages, params, fetcher,
    });
  }

  async start(simulationId: string, options?: { ticks?: number }): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {};
    if (options?.ticks != null) body.ticks = options.ticks;
    return this.client.post(`/v1/simulations/${simulationId}/start`, body);
  }

  async pause(simulationId: string): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/simulations/${simulationId}/pause`, {});
  }

  async stream(simulationId: string): Promise<SSEStream> {
    const response = await this.client.streamSSE(`/v1/simulations/${simulationId}/stream`);
    return new SSEStream(response);
  }

  async getEvents(
    simulationId: string,
    options?: { page?: number; perPage?: number },
  ): Promise<Page<Record<string, unknown>>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };

    const data = await this.client.get<PaginatedData>(
      `/v1/simulations/${simulationId}/events`,
      params,
    );

    const fetcher: PageFetcher<Record<string, unknown>> = async (p) => {
      const d = await this.client.get<PaginatedData>(`/v1/simulations/${simulationId}/events`, p);
      return { items: d.items, total: d.total, page: d.page, perPage: d.per_page, pages: d.pages };
    };

    return new Page<Record<string, unknown>>({
      items: data.items, total: data.total, page: data.page,
      perPage: data.per_page, pages: data.pages, params, fetcher,
    });
  }

  async getHistory(simulationId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/simulations/${simulationId}/history`);
  }

  /** GET /v1/simulations/{simulationId}/participants */
  async listParticipants(
    simulationId: string,
    options?: { page?: number; perPage?: number },
  ): Promise<Record<string, unknown>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };
    return this.client.get(`/v1/simulations/${simulationId}/participants`, params);
  }

  /** POST /v1/simulations/{simulationId}/participants */
  async addParticipants(
    simulationId: string,
    personaIds: string[],
  ): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/simulations/${simulationId}/participants`, {
      persona_ids: personaIds,
    });
  }

  /** GET /v1/simulations/{simulationId}/events/ticks */
  async getEventTicks(simulationId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/simulations/${simulationId}/events/ticks`);
  }
}
