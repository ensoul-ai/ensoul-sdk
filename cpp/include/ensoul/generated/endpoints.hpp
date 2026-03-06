#pragma once

namespace ensoul {
namespace endpoints {

// Personas
inline constexpr const char* PERSONAS = "/v1/personas";
inline constexpr const char* PERSONAS_BATCH = "/v1/personas/batch";
inline constexpr const char* PERSONAS_FILTERS = "/v1/personas/filters";

// Chat
// Uses: /v1/personas/{id}/chat, /v1/personas/{id}/chat/stream

// Domains
inline constexpr const char* DOMAINS = "/v1/domains";

// Simulations
inline constexpr const char* SIMULATIONS = "/v1/simulations";

// Aggregate
inline constexpr const char* AGGREGATE_QUERY = "/v1/aggregate/query";
inline constexpr const char* AGGREGATE_STREAM = "/v1/aggregate/stream";
inline constexpr const char* AGGREGATE_STREAM_GROUPED = "/v1/aggregate/stream/grouped";
inline constexpr const char* AGGREGATE_SIMULATE = "/v1/aggregate/simulate";

// Frameworks
inline constexpr const char* FRAMEWORKS = "/v1/frameworks";

// Auth
inline constexpr const char* AUTH_TOKEN = "/v1/auth/token";
inline constexpr const char* AUTH_REFRESH = "/v1/auth/refresh";
inline constexpr const char* AUTH_ME = "/v1/auth/me";
inline constexpr const char* API_KEYS = "/v1/api-keys";

// Health
inline constexpr const char* HEALTH = "/health";
inline constexpr const char* HEALTH_READY = "/health/ready";
inline constexpr const char* HEALTH_LIVE = "/health/live";

// Info
inline constexpr const char* INFO_CONFIG = "/v1/info/config";
inline constexpr const char* INFO_RATE_LIMITS = "/v1/info/rate-limits";
inline constexpr const char* INFO_TIERS = "/v1/info/tiers";
inline constexpr const char* INFO_FEATURES = "/v1/info/features";

} // namespace endpoints
} // namespace ensoul
