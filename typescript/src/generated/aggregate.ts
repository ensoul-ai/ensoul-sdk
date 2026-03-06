/**
 * Generated models for aggregate resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

import { AggregateAggregationMode } from "./enums.js";
export { AggregateAggregationMode };

/** Stub — regenerate with: make sdk-regen */
export interface InfluencePath {
  personas: string[];
  total_weight: number;
  [key: string]: unknown;
}

/** Request to run a scenario simulation. */
export interface SimulationRequest {
  /** Scenario description */
  scenario: string;
  /** Target cohort filters (region, archetype, demographics) */
  target_cohort?: Record<string, unknown>;
  /** Simulation duration in days */
  duration_days?: number;
  /** Additional simulation parameters */
  parameters?: Record<string, unknown>;
}

/** Response from influence tracing. */
export interface InfluenceQueryResponse {
  /** Starting persona ID */
  persona_id: string;
  /** Influence type filter used */
  influence_type?: string | null;
  /** Direction traced */
  direction: string;
  /** Maximum depth traced */
  max_depth: number;
  /** Found influence paths */
  paths?: InfluencePath[];
  /** List of persona IDs influenced */
  influenced_personas?: string[];
  /** Total number of paths found */
  total_paths: number;
  /** Path with highest total weight */
  strongest_path?: InfluencePath | null;
  /** Network analysis metrics */
  network_metrics?: Record<string, unknown> | null;
  /** Query timestamp */
  timestamp?: string;
}

/** Request for streaming aggregate query with progressive results.

Sprint 21: Streaming Aggregation (5s time-to-first-result)
Sprint 42: Added aggregation_mode for synthesis support */
export interface StreamingQueryRequest {
  /** The question to ask across personas */
  query: string;
  /** Filters for persona selection (region, archetype, demographics) */
  filters?: Record<string, unknown>;
  /** How to aggregate responses. */
  aggregation_mode?: AggregateAggregationMode;
  /** Target confidence level for early termination (0.80-0.99) */
  target_confidence?: number;
  /** Minimum samples before allowing early termination */
  min_samples?: number;
  /** Maximum samples to collect (None for unlimited) */
  max_samples?: number | null;
  /** Maximum confidence interval width for early termination */
  ci_width_threshold?: number;
  /** Epsilon for differential privacy */
  privacy_budget?: number;
}

