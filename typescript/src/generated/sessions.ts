/**
 * Generated models for sessions resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

import { SessionsAggregationMode } from "./enums.js";
export { SessionsAggregationMode };

/** Session state enumeration. */
export enum SessionStatus {
  INITIALIZING = "initializing",
  READY = "ready",
  RUNNING = "running",
  WAITING_CHILDREN = "waiting_children",
  COMPLETED = "completed",
  FAILED = "failed",
  CANCELLED = "cancelled",
}

/** Request to create a new session. */
export interface SessionCreate {
  /** Session tier level (0-4) */
  tier: number;
  /** Parent session ID for hierarchical sessions */
  parent_session_id?: string | null;
  /** Custom system instructions for the session */
  system_instructions?: string | null;
  /** OCEAN trait modifiers from baseline */
  trait_modifiers?: Record<string, unknown> | null;
  /** Core values for the session context */
  core_values?: string[] | null;
  /** Communication style parameters */
  communication_style?: Record<string, unknown> | null;
  /** Additional metadata */
  metadata?: Record<string, unknown> | null;
}

/** Request to aggregate responses from child sessions. */
export interface AggregateChildrenRequest {
  /** How to aggregate child responses. */
  aggregation_mode?: SessionsAggregationMode;
  /** Optional filters for selecting children */
  filters?: Record<string, unknown> | null;
  /** Timeout in milliseconds (1s - 5min) */
  timeout_ms?: number | null;
}

/** Response from aggregating child sessions. */
export interface AggregateChildrenResponse {
  /** Parent session ID */
  session_id: string;
  /** How to aggregate child responses. */
  aggregation_mode: SessionsAggregationMode;
  /** Number of child responses */
  child_count: number;
  /** Whether all children responded */
  is_complete: boolean;
  /** Whether result is partial */
  is_partial: boolean;
  /** Aggregated content based on mode */
  aggregated_content?: Record<string, unknown>;
  /** Raw child responses */
  child_responses?: Record<string, unknown>[];
  /** Total tokens used across children */
  total_tokens?: number;
  /** Total time across children */
  total_time_ms?: number;
  /** Number of missing responses */
  missing_count?: number;
  /** Aggregation timestamp */
  timestamp?: string;
}

