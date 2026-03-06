import type { HTTPClient } from "../http.js";

export class Health {
  constructor(private readonly client: HTTPClient) {}

  async check(): Promise<Record<string, unknown>> {
    return this.client.getRaw("/health");
  }

  async ready(): Promise<Record<string, unknown>> {
    return this.client.getRaw("/health/ready");
  }

  async live(): Promise<Record<string, unknown>> {
    return this.client.getRaw("/health/live");
  }
}
