/**
 * Client configuration for the Ensoul TypeScript SDK.
 */

export const DEFAULT_BASE_URL = "https://api.ensoul-ai.com";
export const DEFAULT_TIMEOUT = 30_000; // milliseconds
export const DEFAULT_MAX_RETRIES = 2;
export const API_VERSION = "v1";
export const SDK_VERSION = "0.1.0";

export interface ClientConfig {
  baseUrl: string;
  apiKey?: string;
  bearerToken?: string;
  timeout: number;
  maxRetries: number;
  customHeaders: Record<string, string>;
}

export function buildConfig(options: {
  apiKey?: string;
  baseUrl?: string;
  bearerToken?: string;
  timeout?: number;
  maxRetries?: number;
  customHeaders?: Record<string, string>;
}): ClientConfig {
  const apiKey =
    options.apiKey ??
    (typeof process !== "undefined" ? process.env?.ENSOUL_API_KEY : undefined);

  const baseUrl =
    options.baseUrl ??
    (typeof process !== "undefined" ? process.env?.ENSOUL_BASE_URL : undefined) ??
    DEFAULT_BASE_URL;

  return {
    baseUrl,
    apiKey: apiKey ?? undefined,
    bearerToken: options.bearerToken,
    timeout: options.timeout ?? DEFAULT_TIMEOUT,
    maxRetries: options.maxRetries ?? DEFAULT_MAX_RETRIES,
    customHeaders: options.customHeaders ?? {},
  };
}
