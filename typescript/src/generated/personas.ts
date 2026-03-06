/**
 * Generated models for personas resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

/** Create persona request.

Domain-agnostic: Requires `domain` and `personality_data`. */
export interface PersonaCreate {
  /** Persona name */
  name: string;
  /** Archetype template ID */
  archetype?: string | null;
  /** Geographic region */
  region?: string | null;
  /** Domain identifier. Required to ensure explicit domain selection. Use the /domains endpoint to list available domains. */
  domain: string;
  /** Domain-specific personality data as a dictionary. Structure depends on the domain's personality schema. */
  personality_data?: Record<string, unknown>;
  /** Age in years */
  age?: number | null;
  /** Country */
  country?: string | null;
  /** City */
  city?: string | null;
  /** Background story */
  backstory?: string | null;
  /** List of core values */
  core_values?: string[] | null;
  /** Communication style parameters */
  communication_style?: Record<string, unknown> | null;
}

/** Update persona request (partial updates).

Domain-agnostic: Updates flow through personality_data. */
export interface PersonaUpdate {
  /** Persona name */
  name?: string | null;
  /** Domain-specific personality data to update (partial) */
  personality_data?: Record<string, unknown> | null;
  /** Age in years */
  age?: number | null;
  /** Country */
  country?: string | null;
  /** Region */
  region?: string | null;
  /** City */
  city?: string | null;
  /** Background story */
  backstory?: string | null;
  /** List of core values */
  core_values?: string[] | null;
  /** Communication style parameters */
  communication_style?: Record<string, unknown> | null;
}

/** Batch create personas request. */
export interface PersonaBatchCreate {
  /** List of personas to create */
  personas: PersonaCreate[];
  /** Optional batch identifier */
  batch_id?: string | null;
  /** Default domain for all personas in batch (optional). Each persona must still specify its domain. */
  domain?: string | null;
}

/** Persona response with core information.

Domain-agnostic: All personality data in personality_data field. */
export interface PersonaResponse {
  /** Unique persona identifier */
  id: string;
  /** Persona name */
  name: string;
  /** Domain identifier */
  domain: string;
  /** Full personality data in domain-specific format */
  personality_data?: Record<string, unknown>;
  /** Avatar image URL */
  avatar_url?: string | null;
  /** Archetype template ID */
  archetype?: string | null;
  /** Age in years */
  age?: number | null;
  /** Country */
  country?: string | null;
  /** Region */
  region?: string | null;
  /** City */
  city?: string | null;
  /** Generation batch ID */
  batch_id?: string | null;
  /** Creation timestamp */
  created_at: string;
}

/** Paginated list of personas. */
export interface PersonaListResponse {
  /** Total number of matching personas */
  total: number;
  /** Persona items for current page */
  items: PersonaResponse[];
  /** Current page number */
  page: number;
  /** Items per page */
  per_page: number;
  /** Total number of pages */
  pages: number;
}

/** Full personality vector response.

Domain-agnostic: Returns personality_data in domain-specific format. */
export interface PersonalityVectorResponse {
  /** Persona identifier */
  persona_id: string;
  /** Domain identifier */
  domain: string;
  /** Full personality data in domain-specific format */
  personality_data?: Record<string, unknown>;
  /** Communication style */
  communication_style?: Record<string, unknown>;
  /** Core values */
  core_values?: string[];
}

/** Batch operation response. */
export interface PersonaBatchResponse {
  /** Number of personas created */
  created: number;
  /** List of created persona IDs */
  persona_ids: string[];
  /** Batch identifier */
  batch_id?: string | null;
  /** Domain used for batch */
  domain?: string | null;
}

/** A filter option with ID, name, and count. */
export interface FilterOption {
  /** Filter value ID */
  id: string;
  /** Display name */
  name: string;
  /** Number of personas with this value */
  count: number;
}

/** Available filter options for persona browsing. */
export interface PersonaFiltersResponse {
  /** Available domains */
  domains?: FilterOption[];
  /** Available regions */
  regions?: FilterOption[];
  /** Available archetypes/templates */
  archetypes?: FilterOption[];
  /** Available countries */
  countries?: FilterOption[];
  /** Age range buckets */
  age_ranges?: FilterOption[];
  /** Total persona count */
  total_personas: number;
}

