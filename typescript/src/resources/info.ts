import type { HTTPClient } from "../http.js";

export class Info {
  constructor(private readonly client: HTTPClient) {}

  async config(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/info/config");
  }

  async rateLimits(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/info/rate-limits");
  }

  async tiers(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/info/tiers");
  }

  async features(): Promise<Record<string, unknown>> {
    return this.client.get("/v1/info/features");
  }
}
