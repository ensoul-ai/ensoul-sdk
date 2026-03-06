/**
 * Generated models for simulations resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

/** Stub — regenerate with: make sdk-regen */
export interface SchedulerWeights {
  [key: string]: number;
}

/** Stub — regenerate with: make sdk-regen */
export interface ParticipantResponse {
  persona_id: string;
  [key: string]: unknown;
}

/** Stub — regenerate with: make sdk-regen */
export type SimulationSimulationResponse = Record<string, unknown>;

/** Simulation lifecycle status. */
export enum SimulationStatus {
  CREATED = "created",
  RUNNING = "running",
  PAUSED = "paused",
  COMPLETED = "completed",
  FAILED = "failed",
}

/** Configuration embedded in the simulation's config JSONB column. */
export interface SimulationConfig {
  /** Number of interaction pairs per tick */
  interactions_per_tick?: number;
  /** Number of turns per conversation */
  turns_per_conversation?: number;
  /** Whether unconnected personas can be paired */
  allow_new_connections?: boolean;
  /** Probability of pairing unconnected personas */
  new_connection_probability?: number;
  /** Min/max group size for conversations */
  group_size_range?: number[];
  /** Probability of forming a group (3+) instead of pair */
  group_formation_probability?: number;
  /** Weights for the interaction scheduler's pair selection algorithm. */
  scheduler_weights?: SchedulerWeights;
  /** Auto-checkpoint every N ticks (0 = disabled) */
  checkpoint_interval?: number;
  /** Max parallel conversations per tick */
  max_concurrent_conversations?: number;
  /** Use Anthropic Batch API for large simulations (higher latency, ~50% cost savings) */
  use_batch_api?: boolean;
  /** Budget limit in USD. Simulation auto-pauses when exceeded. None = no limit. */
  budget_limit?: number | null;
  /** Re-inject persona traits every N ticks to prevent drift (0 = disabled) */
  reinforcement_interval?: number;
}

/** Request to create a new simulation. */
export interface SimulationCreate {
  /** Simulation name */
  name: string;
  /** Domain ID to simulate within */
  domain_id: string;
  /** Optional description */
  description?: string | null;
  /** Configuration embedded in the simulation's config JSONB column. */
  config?: SimulationConfig;
  /** Initial persona IDs to include */
  participant_persona_ids?: string[];
}

/** Full simulation detail. */
export interface SimulationDetailResponse {
  id: string;
  name: string;
  domain_id: string;
  team_id: string;
  is_public?: boolean;
  description?: string | null;
  config: Record<string, unknown>;
  /** Simulation lifecycle status. */
  status: SimulationStatus;
  current_tick: number;
  simulated_time: number;
  time_speed: number;
  tick_target?: number | null;
  run_start_tick?: number | null;
  participants?: ParticipantResponse[];
  created_at: string;
  updated_at: string;
}

/** Paginated list of simulations. */
export interface SimulationListResponse {
  items: SimulationSimulationResponse[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
}

