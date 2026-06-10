import type { HTTPClient } from "../http.js";

/**
 * Info resource.
 *
 * As of API 0.2.0 the four `/v1/info/*` routes were replaced by a single
 * `GET /v1/api/info` returning an `APIInfoResponse` blob. The convenience
 * methods below each fetch that blob and return their relevant sub-section, so
 * existing call sites keep working without four separate round-trips becoming
 * four copies of the same payload. See
 * `sdks/openapi/namespace-migration-contract.md`.
 */
export class Info {
  constructor(private readonly client: HTTPClient) {}

  /** GET /v1/api/info — full server info (`APIInfoResponse`). */
  async get(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/api/info");
  }

  /** Full server configuration blob (alias for {@link get}). */
  async config(): Promise<Record<string, unknown>> {
    return this.get();
  }

  /** Rate-limiting configuration sub-section. */
  async rateLimits(): Promise<Record<string, unknown>> {
    return ((await this.get()).rate_limiting as Record<string, unknown>) ?? {};
  }

  /** Access-tier definitions sub-section. */
  async tiers(): Promise<unknown[]> {
    return ((await this.get()).access_tiers as unknown[]) ?? [];
  }

  /** Feature-flags sub-section. */
  async features(): Promise<Record<string, unknown>> {
    return ((await this.get()).features as Record<string, unknown>) ?? {};
  }
}
