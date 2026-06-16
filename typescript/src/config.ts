/**
 * Client configuration for the Ensoul TypeScript SDK.
 */

export const DEFAULT_BASE_URL = "https://api.ensoul-ai.com";
// Inference endpoints (domain generation, chat, aggregate streaming) run real-time
// LLM calls that routinely take 30-120s+ — domain generation alone measures ~123s.
// A 30s default made the documented "easy path" (domains.generate) time out on a
// new developer's first call.
export const DEFAULT_TIMEOUT = 300_000; // milliseconds
export const DEFAULT_MAX_RETRIES = 2;
export const API_VERSION = "v1";
export const SDK_VERSION = "0.2.3";

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
