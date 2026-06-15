/**
 * Ensoul SDK for TypeScript/JavaScript.
 * @module @ensoul-ai/sdk
 */

export { SDK_VERSION as VERSION } from "./config.js";

// Client
export { Ensoul, type EnsoulOptions } from "./client.js";

// Errors
export {
  EnsoulError,
  APIError,
  AuthenticationError,
  AuthorizationError,
  NotFoundError,
  RateLimitError,
  ValidationError,
  ConflictError,
  ServerError,
  raiseForStatus,
  type ErrorDetail,
} from "./errors.js";

// Pagination
export { Page, type PageFetcher } from "./pagination.js";

// Streaming
export {
  SSEStream,
  parseChatEvent,
  parseAggregateEvent,
  type SSEEvent,
  type ChatStreamEvent,
  type AggregateStreamEvent,
} from "./streaming.js";

// Resources (for advanced users who want to instantiate individually)
export { Personas } from "./resources/personas.js";
export { Chat } from "./resources/chat.js";
export { Domains } from "./resources/domains.js";
export type {
  DomainConfigCreateInput,
  GenerateDomainOptions,
  GeneratedConfigResponse,
} from "./resources/domains.js";
export { Simulations } from "./resources/simulations.js";
export { Aggregate } from "./resources/aggregate.js";
export { Audit } from "./resources/audit.js";
export { Memory } from "./resources/memory.js";
export { Sessions } from "./resources/sessions.js";
export { Frameworks } from "./resources/frameworks.js";
export { AuthResource } from "./resources/auth-resource.js";
export { Health } from "./resources/health.js";
export { Info } from "./resources/info.js";

// Re-export generated types
export * from "./generated/auth.js";
export * from "./generated/personas.js";
export * from "./generated/chat.js";
export * from "./generated/domains.js";
export * from "./generated/sessions.js";
export * from "./generated/aggregate.js";
export * from "./generated/simulations.js";

// Re-export enums not already in resource group modules
export {
  FilterableFieldType,
  InfluenceType,
  PersonaExportFormat,
  ValidationStatus,
  AggregateAggregationMode,
  SessionsAggregationMode,
} from "./generated/enums.js";
