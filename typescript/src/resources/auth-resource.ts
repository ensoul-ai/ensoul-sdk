import type { HTTPClient } from "../http.js";
import type { TokenResponse, APIKeyResponse, UserResponse } from "../generated/auth.js";

export class AuthResource {
  constructor(private readonly client: HTTPClient) {}

  async token(username: string, password: string): Promise<TokenResponse> {
    return this.client.postForm<TokenResponse>("/v1/auth/token", {
      username,
      password,
      grant_type: "password",
    });
  }

  async refresh(refreshToken: string): Promise<TokenResponse> {
    return this.client.post<TokenResponse>("/v1/auth/refresh", {
      refresh_token: refreshToken,
      grant_type: "refresh_token",
    });
  }

  async me(): Promise<UserResponse> {
    return this.client.get<UserResponse>("/v1/auth/me");
  }

  async createApiKey(
    name: string,
    options: { expiresDays?: number; scopes?: string[] } = {},
  ): Promise<APIKeyResponse> {
    const body: Record<string, unknown> = { name, expires_days: options.expiresDays ?? 365 };
    if (options.scopes != null) body.scopes = options.scopes;
    return this.client.post<APIKeyResponse>("/v1/api-keys", body);
  }

  async listApiKeys(): Promise<APIKeyResponse[]> {
    const data = await this.client.get<unknown>("/v1/api-keys");
    const items = Array.isArray(data) ? data : ((data as Record<string, unknown>).items as unknown[]) ?? [];
    return items as APIKeyResponse[];
  }

  async revokeApiKey(keyId: string): Promise<void> {
    await this.client.delete(`/v1/api-keys/${keyId}`);
  }
}
