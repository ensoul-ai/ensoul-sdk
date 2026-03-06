import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";
import type {
  PersonaResponse,
  PersonaBatchResponse,
  PersonalityVectorResponse,
  PersonaFiltersResponse,
  PersonaListResponse,
} from "../generated/personas.js";

export class Personas {
  constructor(private readonly client: HTTPClient) {}

  async create(options: {
    name: string;
    domain: string;
    personalityData?: Record<string, unknown>;
    [key: string]: unknown;
  }): Promise<PersonaResponse> {
    const { name, domain, personalityData, ...rest } = options;
    const body: Record<string, unknown> = { name, domain, ...rest };
    if (personalityData != null) body.personality_data = personalityData;
    return this.client.post<PersonaResponse>("/v1/personas", body);
  }

  async get(personaId: string): Promise<PersonaResponse> {
    return this.client.get<PersonaResponse>(`/v1/personas/${personaId}`);
  }

  async update(personaId: string, updates: Record<string, unknown>): Promise<PersonaResponse> {
    return this.client.put<PersonaResponse>(`/v1/personas/${personaId}`, updates);
  }

  async delete(personaId: string): Promise<void> {
    await this.client.delete(`/v1/personas/${personaId}`);
  }

  async list(options?: {
    page?: number;
    perPage?: number;
    region?: string;
    archetype?: string;
    country?: string;
    city?: string;
  }): Promise<Page<PersonaResponse>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };
    if (options?.region != null) params.region = options.region;
    if (options?.archetype != null) params.archetype = options.archetype;
    if (options?.country != null) params.country = options.country;
    if (options?.city != null) params.city = options.city;

    const data = await this.client.get<PersonaListResponse>("/v1/personas", params);

    const fetcher: PageFetcher<PersonaResponse> = async (p) => {
      const d = await this.client.get<PersonaListResponse>("/v1/personas", p);
      return { items: d.items, total: d.total, page: d.page, perPage: d.per_page, pages: d.pages };
    };

    return new Page<PersonaResponse>({
      items: data.items,
      total: data.total,
      page: data.page,
      perPage: data.per_page,
      pages: data.pages,
      params,
      fetcher,
    });
  }

  async batchCreate(
    personas: Array<Record<string, unknown>>,
    options?: { batchId?: string; domain?: string },
  ): Promise<PersonaBatchResponse> {
    const body: Record<string, unknown> = { personas };
    if (options?.batchId != null) body.batch_id = options.batchId;
    if (options?.domain != null) body.domain = options.domain;
    return this.client.post<PersonaBatchResponse>("/v1/personas/batch", body);
  }

  async getPersonality(personaId: string): Promise<PersonalityVectorResponse> {
    return this.client.get<PersonalityVectorResponse>(`/v1/personas/${personaId}/personality`);
  }

  async getFilters(): Promise<PersonaFiltersResponse> {
    return this.client.get<PersonaFiltersResponse>("/v1/personas/filters");
  }

  async getConnections(personaId: string): Promise<unknown[]> {
    return this.client.get<unknown[]>(`/v1/personas/${personaId}/connections`);
  }
}
