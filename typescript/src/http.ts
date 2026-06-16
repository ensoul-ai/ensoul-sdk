import { APIKeyAuth, type AuthProvider, BearerAuth } from "./auth.js";
import { API_VERSION, type ClientConfig, SDK_VERSION } from "./config.js";
import { RateLimitError, raiseForStatus } from "./errors.js";
import { RateLimitTracker } from "./rate-limit.js";

const RETRYABLE_STATUS_CODES = new Set([429, 500, 502, 503]);
// Methods safe to replay without creating duplicate side effects. POST/PATCH are
// excluded: replaying a POST that already reached the server (e.g. a 120s domain
// generation that read-timed-out the client) re-runs the inference and double-bills
// the caller.
const IDEMPOTENT_METHODS = new Set(["GET", "HEAD", "OPTIONS", "PUT", "DELETE"]);
// Status codes safe to retry even for non-idempotent methods, because the server did
// not process the request: 429 (rate limited) and 503 (unavailable). 500/502 are
// ambiguous for POST, so they are only retried for idempotent methods.
const NONIDEMPOTENT_RETRY_STATUS_CODES = new Set([429, 503]);

function shouldRetryStatus(method: string, status: number): boolean {
  if (!RETRYABLE_STATUS_CODES.has(status)) return false;
  if (IDEMPOTENT_METHODS.has(method.toUpperCase())) return true;
  return NONIDEMPOTENT_RETRY_STATUS_CODES.has(status);
}

function shouldRetryNetwork(method: string): boolean {
  return IDEMPOTENT_METHODS.has(method.toUpperCase());
}

export class HTTPClient {
  private readonly config: ClientConfig;
  private readonly auth: AuthProvider;
  private readonly rateLimitTracker: RateLimitTracker;

  constructor(config: ClientConfig) {
    this.config = config;
    this.rateLimitTracker = new RateLimitTracker();

    if (config.apiKey) {
      this.auth = new APIKeyAuth(config.apiKey);
    } else if (config.bearerToken) {
      this.auth = new BearerAuth(config.bearerToken);
    } else {
      this.auth = new APIKeyAuth("");
    }
  }

  private _defaultHeaders(): Record<string, string> {
    return {
      "User-Agent": `ensoul-typescript/${SDK_VERSION}`,
      Accept: "application/json",
      "Content-Type": "application/json",
      ...this.config.customHeaders,
      ...this.auth.authHeaders(),
    };
  }

  _normalizePath(path: string): string {
    const prefix = `/${API_VERSION}/`;
    if (path.startsWith(prefix) || path.startsWith(`/${API_VERSION}`)) {
      return path;
    }
    const stripped = path.startsWith("/") ? path.slice(1) : path;
    return `/${API_VERSION}/${stripped}`;
  }

  private _buildUrl(path: string): string {
    const base = this.config.baseUrl.replace(/\/$/, "");
    return `${base}${path}`;
  }

  private async _retryWait(attempt: number, retryAfter?: number): Promise<void> {
    let waitSeconds: number;
    if (retryAfter !== undefined && retryAfter > 0) {
      waitSeconds = retryAfter;
    } else {
      const backoff = Math.min(0.5 * Math.pow(2, attempt), 30);
      const jitter = Math.random() * 0.5;
      waitSeconds = backoff + jitter;
    }
    await new Promise<void>((resolve) => setTimeout(resolve, waitSeconds * 1000));
  }

  private async _request(
    method: string,
    path: string,
    options: {
      body?: unknown;
      query?: Record<string, unknown>;
      skipNormalize?: boolean;
    } = {}
  ): Promise<{ status: number; headers: Headers; json: () => Promise<Record<string, unknown>>; text: () => Promise<string> }> {
    const normalizedPath = options.skipNormalize ? path : this._normalizePath(path);
    let url = this._buildUrl(normalizedPath);

    if (options.query && Object.keys(options.query).length > 0) {
      const params = new URLSearchParams();
      for (const [key, value] of Object.entries(options.query)) {
        if (value !== undefined && value !== null) {
          params.set(key, String(value));
        }
      }
      const queryString = params.toString();
      if (queryString) {
        url = `${url}?${queryString}`;
      }
    }

    const headers = this._defaultHeaders();
    const requestInit: RequestInit = {
      method,
      headers,
    };

    if (options.body !== undefined) {
      requestInit.body = JSON.stringify(options.body);
    }

    let lastError: unknown;

    for (let attempt = 0; attempt <= this.config.maxRetries; attempt++) {
      const { wait, seconds } = this.rateLimitTracker.shouldWait();
      if (wait) {
        await this._retryWait(0, seconds);
      }

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);
      requestInit.signal = controller.signal;

      try {
        const response = await fetch(url, requestInit);
        clearTimeout(timeoutId);

        this.rateLimitTracker.update(response.headers);

        if (shouldRetryStatus(method, response.status) && attempt < this.config.maxRetries) {
          let retryAfter: number | undefined;
          const retryAfterHeader = response.headers.get("Retry-After");
          if (retryAfterHeader) {
            retryAfter = parseInt(retryAfterHeader, 10);
            if (isNaN(retryAfter)) retryAfter = undefined;
          }
          await this._retryWait(attempt, retryAfter);
          continue;
        }

        if (!response.ok) {
          const body = (await response.json().catch(() => ({}))) as Record<string, unknown>;
          raiseForStatus(response.status, body, response.headers);
        }

        return {
          status: response.status,
          headers: response.headers,
          json: () => response.json() as Promise<Record<string, unknown>>,
          text: () => response.text(),
        };
      } catch (err) {
        clearTimeout(timeoutId);

        if (err instanceof RateLimitError) {
          if (attempt < this.config.maxRetries) {
            await this._retryWait(attempt, err.retryAfter);
            lastError = err;
            continue;
          }
          throw err;
        }

        if (err instanceof Error && err.name === "AbortError") {
          lastError = new Error(`Request timed out after ${this.config.timeout}ms`);
          if (shouldRetryNetwork(method) && attempt < this.config.maxRetries) {
            await this._retryWait(attempt);
            continue;
          }
          throw lastError;
        }

        // Network errors
        if (err instanceof TypeError && shouldRetryNetwork(method) && attempt < this.config.maxRetries) {
          lastError = err;
          await this._retryWait(attempt);
          continue;
        }

        throw err;
      }
    }

    throw lastError ?? new Error("Request failed after retries");
  }

  async get<T = Record<string, unknown>>(
    path: string,
    query?: Record<string, unknown>
  ): Promise<T> {
    const res = await this._request("GET", path, { query });
    return res.json() as Promise<T>;
  }

  async post<T = Record<string, unknown>>(
    path: string,
    body?: unknown,
    query?: Record<string, unknown>
  ): Promise<T> {
    const res = await this._request("POST", path, { body, query });
    return res.json() as Promise<T>;
  }

  async put<T = Record<string, unknown>>(
    path: string,
    body?: unknown,
    query?: Record<string, unknown>
  ): Promise<T> {
    const res = await this._request("PUT", path, { body, query });
    return res.json() as Promise<T>;
  }

  async patch<T = Record<string, unknown>>(
    path: string,
    body?: unknown,
    query?: Record<string, unknown>
  ): Promise<T> {
    const res = await this._request("PATCH", path, { body, query });
    return res.json() as Promise<T>;
  }

  async delete<T = Record<string, unknown>>(
    path: string,
    query?: Record<string, unknown>
  ): Promise<T> {
    const res = await this._request("DELETE", path, { query });
    if (res.status === 204) {
      return undefined as unknown as T;
    }
    return res.json() as Promise<T>;
  }

  async postForm<T = Record<string, unknown>>(
    path: string,
    data: Record<string, string>,
  ): Promise<T> {
    const normalizedPath = this._normalizePath(path);
    const url = this._buildUrl(normalizedPath);
    const headers = {
      ...this._defaultHeaders(),
      "Content-Type": "application/x-www-form-urlencoded",
    };
    const body = new URLSearchParams(data).toString();

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);

    try {
      const response = await fetch(url, {
        method: "POST",
        headers,
        body,
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      this.rateLimitTracker.update(response.headers);

      if (!response.ok) {
        const responseBody = (await response.json().catch(() => ({}))) as Record<string, unknown>;
        raiseForStatus(response.status, responseBody, response.headers);
      }

      return response.json() as Promise<T>;
    } catch (err) {
      clearTimeout(timeoutId);
      throw err;
    }
  }

  async getRaw(path: string, query?: Record<string, unknown>): Promise<Record<string, unknown>> {
    const res = await this._request("GET", path, { query, skipNormalize: true });
    return res.json();
  }

  /** GET an unversioned path returning the raw response body as text (e.g. a PEM key). */
  async getText(path: string, query?: Record<string, unknown>): Promise<string> {
    const res = await this._request("GET", path, { query, skipNormalize: true });
    return res.text();
  }

  async streamSSE(path: string, body?: unknown): Promise<Response> {
    const normalizedPath = this._normalizePath(path);
    const url = this._buildUrl(normalizedPath);

    const headers: Record<string, string> = {
      ...this._defaultHeaders(),
      Accept: "text/event-stream",
    };

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);

    try {
      const response = await fetch(url, {
        method: "POST",
        headers,
        body: body !== undefined ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      if (!response.ok) {
        const responseBody = (await response.json().catch(() => ({}))) as Record<string, unknown>;
        raiseForStatus(response.status, responseBody, response.headers);
      }

      return response;
    } catch (err) {
      clearTimeout(timeoutId);
      throw err;
    }
  }

  close(): void {
    // No-op for fetch-based client; present for API parity with other SDK implementations
  }
}
