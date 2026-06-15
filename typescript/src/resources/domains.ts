import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";
import type {
  TierDefinitionCreate,
  PersonalitySchemaCreate_Input,
  ArchetypeCreate,
  NamePatternCreate,
  MemoryTemplateCreate,
  FilterableField,
  TierValuesConfig,
  ImageGenerationConfig,
} from "../generated/domains.js";

interface PaginatedData {
  items: Record<string, unknown>[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

/**
 * Request body for `POST /v1/domains`, shaped to the `DomainConfigCreate`
 * Pydantic model (the API source of truth). Compose it from the generated
 * building-block types and pass it straight to {@link Domains.create}.
 */
export interface DomainConfigCreateInput {
  /** Domain identifier (lowercase, alphanumeric, underscores). */
  name: string;
  /** Human-readable domain name. */
  display_name: string;
  /** Semantic version, e.g. `"1.0.0"`. Defaults to `"1.0.0"`. */
  version?: string;
  description?: string;
  /** Tier definitions; must include a root tier at level 0. */
  tiers: TierDefinitionCreate[];
  personality_schema: PersonalitySchemaCreate_Input;
  archetypes?: ArchetypeCreate[];
  name_patterns?: NamePatternCreate[];
  memory_templates?: MemoryTemplateCreate[];
  filterable_fields?: FilterableField[];
  tier_values?: TierValuesConfig[];
  image_generation?: ImageGenerationConfig | null;
  /** Domain-wide behavioral rules added to every persona's system prompt. */
  behavioral_guidelines?: string[] | null;
  /** Short directives re-injected into every chat turn (re-anchor capsule). */
  chat_guardrails?: string[] | null;
  /** Per-domain chat sampling temperature (0.0-2.0). */
  chat_temperature?: number | null;
  /** Identity framing: what each persona IS (e.g. `"person"`, `"pet"`, `"character"`). */
  entity_noun?: string;
  is_draft?: boolean;
  tags?: string[];
  frameworks?: string[];
}

/** Options for the AI domain wizard (`POST /v1/domains/generate`). */
export interface GenerateDomainOptions {
  /** Natural-language description of the domain (10-5000 chars). */
  description: string;
  /** Additional context for the generator (example personas, inspiration, etc.). */
  context?: Record<string, unknown>;
  /** Which sections to generate. Defaults to `["all"]`. */
  targetSections?: string[];
}

/** Response from `POST /v1/domains/generate`. */
export interface GeneratedConfigResponse {
  /** Generated configuration - ready to pass to {@link Domains.create}. */
  config: DomainConfigCreateInput;
  /** Explanation of the generated config. */
  explanation: string;
  /** Suggestions for improvement. */
  suggestions: string[];
  /** Confidence score (0.0-1.0). */
  confidence: number;
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

  /**
   * POST /v1/domains — create a domain from a full {@link DomainConfigCreateInput}.
   *
   * This is step 1 of the dev workflow. To build the config with the AI wizard
   * instead of by hand, call {@link Domains.generate} first and pass its
   * `.config` here.
   */
  async create(config: DomainConfigCreateInput): Promise<Record<string, unknown>> {
    return this.client.post("/v1/domains", config);
  }

  /**
   * POST /v1/domains/generate — generate a domain configuration from a
   * natural-language description using the Claude AI wizard (requires PRO tier).
   *
   * The returned `config` is a ready-to-use {@link DomainConfigCreateInput} that
   * can be passed straight to {@link Domains.create}.
   */
  async generate(options: GenerateDomainOptions): Promise<GeneratedConfigResponse> {
    const body: Record<string, unknown> = { description: options.description };
    if (options.context != null) body.context = options.context;
    if (options.targetSections != null) body.target_sections = options.targetSections;
    return this.client.post<GeneratedConfigResponse>("/v1/domains/generate", body);
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
