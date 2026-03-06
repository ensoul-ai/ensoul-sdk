/**
 * Generated models for domains resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

/** Supported field types for personality schema fields. */
export enum FieldType {
  FLOAT = "float",
  INT = "int",
  STR = "str",
  ENUM = "enum",
  BOOL = "bool",
}

/** How name generation handles gender. */
export enum GenderHandling {
  NEUTRAL = "neutral",
  SEPARATE = "separate",
  NONE = "none",
}

/** Schema for creating a personality field.

Matches the FieldDefinition dataclass in protocols.py. */
export interface FieldDefinitionCreate {
  /** Dot-notation path (e.g., 'traits.courage', 'big_five.openness') */
  path: string;
  /** Supported field types for personality schema fields. */
  field_type: FieldType;
  /** Minimum value for numeric fields */
  range_min?: number | null;
  /** Maximum value for numeric fields */
  range_max?: number | null;
  /** Default value */
  default?: Record<string, unknown> | null;
  /** Whether this field is required */
  required?: boolean;
  /** Trait heritability for inheritance (0=random, 1=pure) */
  heritability?: number;
  /** Human-readable description */
  description?: string;
  /** Valid values for enum type fields */
  enum_values?: string[] | null;
}

/** Schema for tier in hierarchy. */
export interface TierDefinitionCreate {
  /** Tier level (0=root, 1=first level, etc.) */
  level: number;
  /** Tier name */
  name: string;
  /** Tier description */
  description?: string;
}

/** Correlation between two personality traits. */
export interface TraitCorrelation {
  trait_a: string;
  trait_b: string;
  /** Correlation coefficient (-1.0 to 1.0) */
  correlation: number;
  description?: string | null;
}

/** Complete personality schema configuration. */
export interface PersonalitySchemaCreate_Input {
  version?: string;
  fields: FieldDefinitionCreate[];
  trait_correlations?: TraitCorrelation[] | null;
}

/** Schema for creating an archetype in the hierarchy. */
export interface ArchetypeCreate {
  id: string;
  name: string;
  /** Tier level (>= 0) */
  tier: number;
  parent_id?: string | null;
  /** Personality modifier deltas (-50 to 50) */
  personality_modifiers?: Record<string, unknown>;
  description?: string;
  metadata?: Record<string, unknown>;
  /** Selection probability (0.0 to 1.0) */
  probability?: number;
}

/** Schema for name generation patterns. */
export interface NamePatternCreate {
  tier_id: string;
  tier_value: string;
  first_names?: string[];
  last_names?: string[];
  /** e.g., ['{first} of {location}'] */
  patterns?: string[];
  gender_handling?: GenderHandling;
  prefixes?: string[];
  suffixes?: string[];
}

/** Schema for memory template definition. */
export interface MemoryTemplateCreate {
  template_id: string;
  template_type: 'universal' | 'contextual';
  template_string: string;
  /** e.g., 'archetype', 'tier' */
  context_type?: string | null;
  context_id?: string | null;
  /** Generation probability (0.0 to 1.0) */
  probability?: number;
  /** Memory importance (0.0 to 10.0) */
  importance?: number;
  tags?: string[];
}

/** Supported filter types for persona queries. */
export enum FilterableFieldType {
  RANGE = "range",
  SELECT = "select",
  MULTISELECT = "multiselect",
}

/** Single option for select/multiselect filters. */
export interface FilterableFieldOption {
  value: string;
  label: string;
}

/** Definition of a filterable field for aggregate queries. */
export interface FilterableField {
  path: string;
  type: FilterableFieldType;
  label: string;
  description?: string;
  /** Range type options */
  min?: number | null;
  max?: number | null;
  step?: number | null;
  /** Source for select options (e.g., 'archetypes') */
  options_from?: string | null;
  options?: FilterableFieldOption[] | null;
}

/** Single option for a tier value with probability weighting. */
export interface TierValueOption {
  /** Lowercase snake_case value */
  value: string;
  /** Human-readable label */
  label: string;
  /** Selection probability, auto-normalized (0.0 to 1.0) */
  probability?: number;
}

/** Configuration for generating values for a specific tier. */
export interface TierValuesConfig {
  tier_id: string;
  options: TierValueOption[];
  /** For hierarchical filtering */
  parent_tier_id?: string | null;
  parent_value_mapping?: Record<string, string[]> | null;
}

/** Visual style template for persona avatar generation. */
export interface StyleTemplate {
  /** Lowercase snake_case name */
  name: string;
  description?: string;
  /** Controls visual aesthetic */
  style_prompt: string;
  negative_prompt?: string;
}

/** Domain-level configuration for persona avatar image generation. */
export interface ImageGenerationConfig {
  default_style?: string;
  styles?: StyleTemplate[];
  prompt_prefix?: string;
  prompt_suffix?: string;
}

/** Domain summary response. */
export interface DomainResponse {
  id?: string | null;
  /** Domain identifier (slug) */
  name: string;
  display_name: string;
  version: string;
  description: string;
  tier_count: number;
  field_count: number;
  archetype_count: number;
  is_builtin?: boolean;
  is_registered: boolean;
  is_draft: boolean;
  is_public?: boolean;
  created_at: string;
  updated_at: string;
}

/** Partial update for domain configuration. */
export interface DomainConfigUpdate {
  display_name?: string | null;
  version?: string | null;
  description?: string | null;
  tiers?: TierDefinitionCreate[] | null;
  personality_schema?: PersonalitySchemaCreate_Input | null;
  archetypes?: ArchetypeCreate[] | null;
  name_patterns?: NamePatternCreate[] | null;
  memory_templates?: MemoryTemplateCreate[] | null;
  filterable_fields?: FilterableField[] | null;
  is_draft?: boolean | null;
  is_public?: boolean | null;
  tags?: string[] | null;
  frameworks?: string[] | null;
  tier_values?: TierValuesConfig[] | null;
  /** Image generation settings for persona avatars */
  image_generation?: ImageGenerationConfig | null;
}

/** Paginated list of domains. */
export interface DomainListResponse {
  /** Total number of domains */
  total: number;
  /** Domain items */
  items: DomainResponse[];
  /** Current page number */
  page: number;
  /** Items per page */
  per_page: number;
  /** Total number of pages */
  pages: number;
}

