/**
 * Authentication strategies for the Ensoul TypeScript SDK.
 */

export interface AuthProvider {
  authHeaders(): Record<string, string>;
}

export class APIKeyAuth implements AuthProvider {
  private readonly apiKey: string;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  authHeaders(): Record<string, string> {
    return { "X-API-Key": this.apiKey };
  }
}

export class BearerAuth implements AuthProvider {
  accessToken: string;
  refreshToken: string | undefined;
  expiresAt: number | undefined;

  private static readonly REFRESH_BUFFER_SECONDS = 60;

  constructor(
    accessToken: string,
    refreshToken?: string,
    expiresAt?: number,
  ) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.expiresAt = expiresAt;
  }

  authHeaders(): Record<string, string> {
    return { Authorization: `Bearer ${this.accessToken}` };
  }

  isExpired(): boolean {
    if (this.expiresAt == null) return false;
    return Date.now() / 1000 >= this.expiresAt;
  }

  needsRefresh(): boolean {
    if (this.expiresAt == null) return false;
    return Date.now() / 1000 >= this.expiresAt - BearerAuth.REFRESH_BUFFER_SECONDS;
  }
}
