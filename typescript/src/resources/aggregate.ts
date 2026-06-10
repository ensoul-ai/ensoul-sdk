import type { HTTPClient } from "../http.js";
import { SSEStream } from "../streaming.js";

export class Aggregate {
  constructor(private readonly client: HTTPClient) {}

  /** GET /v1/aggregate/count — count personas matching a filter. */
  async count(
    options: {
      domain?: string;
      filters?: string;
      region?: string;
      archetype?: string;
      ageMin?: number;
      ageMax?: number;
    } = {},
  ): Promise<Record<string, unknown>> {
    const params: Record<string, unknown> = {};
    if (options.domain != null) params.domain = options.domain;
    if (options.filters != null) params.filters = options.filters;
    if (options.region != null) params.region = options.region;
    if (options.archetype != null) params.archetype = options.archetype;
    if (options.ageMin != null) params.age_min = options.ageMin;
    if (options.ageMax != null) params.age_max = options.ageMax;
    return this.client.get("/v1/aggregate/count", params);
  }

  /** GET /v1/aggregate/stats — aggregate query statistics. */
  async stats(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/aggregate/stats");
  }

  async stream(
    query: string,
    options: {
      filters?: Record<string, unknown>;
      aggregationMode?: string;
      targetConfidence?: number;
      minSamples?: number;
      maxSamples?: number;
    } = {},
  ): Promise<SSEStream> {
    const body: Record<string, unknown> = {
      query,
      target_confidence: options.targetConfidence ?? 0.95,
      min_samples: options.minSamples ?? 100,
    };
    if (options.filters != null) body.filters = options.filters;
    if (options.aggregationMode != null) body.aggregation_mode = options.aggregationMode;
    if (options.maxSamples != null) body.max_samples = options.maxSamples;
    const response = await this.client.streamSSE("/v1/aggregate/stream", body);
    return new SSEStream(response);
  }

  async groupedStream(
    query: string,
    options: { groupBy: string; filters?: Record<string, unknown> },
  ): Promise<SSEStream> {
    const body: Record<string, unknown> = { query, group_by: options.groupBy };
    if (options.filters != null) body.filters = options.filters;
    const response = await this.client.streamSSE("/v1/aggregate/stream/grouped", body);
    return new SSEStream(response);
  }

  async simulate(options: {
    scenario: string;
    targetCohort?: Record<string, unknown>;
    durationDays?: number;
    parameters?: Record<string, unknown>;
  }): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {
      scenario: options.scenario,
      duration_days: options.durationDays ?? 30,
    };
    if (options.targetCohort != null) body.target_cohort = options.targetCohort;
    if (options.parameters != null) body.parameters = options.parameters;
    return this.client.post("/v1/aggregate/simulation", body);
  }

  async traceInfluence(
    personaId: string,
    options: {
      influenceType?: string;
      direction?: string;
      maxDepth?: number;
    } = {},
  ): Promise<Record<string, unknown>> {
    const params: Record<string, unknown> = {
      direction: options.direction ?? "downstream",
      max_depth: options.maxDepth ?? 3,
    };
    if (options.influenceType != null) params.influence_type = options.influenceType;
    return this.client.get(`/v1/aggregate/influence/${personaId}`, params);
  }
}
