/**
 * Generated HTTP method stubs from OpenAPI spec.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

export async function health_check_health_get(
): Promise<void> {
  // Health Check
  // GET /health
  throw new Error("Not implemented");
}

export async function readiness_check_health_ready_get(
): Promise<void> {
  // Readiness Check
  // GET /health/ready
  throw new Error("Not implemented");
}

export async function liveness_check_health_live_get(
): Promise<void> {
  // Liveness Check
  // GET /health/live
  throw new Error("Not implemented");
}

export async function login_v1_auth_token_post(
): Promise<TokenResponse> {
  // OAuth2 Password Flow
  // POST /v1/auth/token
  throw new Error("Not implemented");
}

export async function refresh_token_v1_auth_refresh_post(
  body: RefreshTokenRequest,
): Promise<TokenResponse> {
  // Refresh Access Token
  // POST /v1/auth/refresh
  throw new Error("Not implemented");
}

export async function get_me_v1_auth_me_get(
): Promise<UserResponse> {
  // Get Current User
  // GET /v1/auth/me
  throw new Error("Not implemented");
}

export async function create_api_key_v1_api_keys_post(
  body: APIKeyRequest,
): Promise<APIKeyResponse> {
  // Create API Key
  // POST /v1/api-keys
  throw new Error("Not implemented");
}

export async function list_api_keys_v1_api_keys_get(
): Promise<void> {
  // List API Keys
  // GET /v1/api-keys
  throw new Error("Not implemented");
}

export async function revoke_api_key_v1_api_keys__key_id__delete(
  key_id: string,
): Promise<void> {
  // Revoke API Key
  // DELETE /v1/api-keys/{key_id}
  throw new Error("Not implemented");
}

export async function create_persona_v1_personas_post(
  body: PersonaCreate,
): Promise<PersonasPersonaDetailResponse> {
  // Create Persona
  // POST /v1/personas
  throw new Error("Not implemented");
}

export async function list_personas_v1_personas_get(
  page?: number,
  per_page?: number,
  region?: string,
  archetype?: string,
  country?: string,
  city?: string,
): Promise<PersonaListResponse> {
  // List Personas
  // GET /v1/personas
  throw new Error("Not implemented");
}

export async function get_persona_filters_v1_personas_filters_get(
): Promise<PersonaFiltersResponse> {
  // Get Available Filters
  // GET /v1/personas/filters
  throw new Error("Not implemented");
}

export async function get_demo_personalities_v1_personas_demo_get(
): Promise<void> {
  // Get Demo Personalities
  // GET /v1/personas/demo
  throw new Error("Not implemented");
}

export async function select_demo_personalities_v1_personas_demo_select_post(
  body: PersonalitySelectRequest,
): Promise<void> {
  // Select Demo Personalities
  // POST /v1/personas/demo/select
  throw new Error("Not implemented");
}

export async function regenerate_demo_personalities_v1_personas_demo_regenerate_post(
): Promise<void> {
  // Regenerate Demo Personalities
  // POST /v1/personas/demo/regenerate
  throw new Error("Not implemented");
}

export async function get_persona_v1_personas__persona_id__get(
  persona_id: string,
): Promise<PersonasPersonaDetailResponse> {
  // Get Persona
  // GET /v1/personas/{persona_id}
  throw new Error("Not implemented");
}

export async function update_persona_v1_personas__persona_id__put(
  persona_id: string,
  body: PersonaUpdate,
): Promise<PersonasPersonaDetailResponse> {
  // Update Persona
  // PUT /v1/personas/{persona_id}
  throw new Error("Not implemented");
}

export async function delete_persona_v1_personas__persona_id__delete(
  persona_id: string,
): Promise<void> {
  // Delete Persona
  // DELETE /v1/personas/{persona_id}
  throw new Error("Not implemented");
}

export async function batch_create_personas_v1_personas_batch_post(
  body: PersonaBatchCreate,
): Promise<PersonaBatchResponse> {
  // Batch Create Personas
  // POST /v1/personas/batch
  throw new Error("Not implemented");
}

export async function get_personality_vector_v1_personas__persona_id__personality_get(
  persona_id: string,
): Promise<PersonalityVectorResponse> {
  // Get Personality Vector
  // GET /v1/personas/{persona_id}/personality
  throw new Error("Not implemented");
}

export async function get_api_persona_v1_personas_api__persona_id__get(
  persona_id: string,
): Promise<APIPersonaDetailResponse> {
  // Get Persona from API Database
  // GET /v1/personas/api/{persona_id}
  throw new Error("Not implemented");
}

export async function delete_api_persona_v1_personas_api__persona_id__delete(
  persona_id: string,
): Promise<void> {
  // Delete Persona from API Database
  // DELETE /v1/personas/api/{persona_id}
  throw new Error("Not implemented");
}

export async function batch_delete_personas_v1_personas_batch_delete_post(
  body: BatchDeleteRequest,
): Promise<BatchDeleteResponse> {
  // Batch Delete Personas
  // POST /v1/personas/batch-delete
  throw new Error("Not implemented");
}

export async function list_connections_v1_personas__persona_id__connections_get(
  persona_id: string,
  limit?: number,
  offset?: number,
): Promise<ConnectionListResponse> {
  // List Connections
  // GET /v1/personas/{persona_id}/connections
  throw new Error("Not implemented");
}

export async function create_connection_v1_personas__persona_id__connections_post(
  persona_id: string,
  body: CreateConnectionRequest,
): Promise<ConnectionResponse> {
  // Create Connection
  // POST /v1/personas/{persona_id}/connections
  throw new Error("Not implemented");
}

export async function get_connection_v1_personas__persona_id__connections__other_id__get(
  persona_id: string,
  other_id: string,
): Promise<ConnectionResponse> {
  // Get Connection
  // GET /v1/personas/{persona_id}/connections/{other_id}
  throw new Error("Not implemented");
}

export async function delete_connection_v1_personas__persona_id__connections__other_id__delete(
  persona_id: string,
  other_id: string,
): Promise<void> {
  // Delete Connection
  // DELETE /v1/personas/{persona_id}/connections/{other_id}
  throw new Error("Not implemented");
}

export async function get_network_v1_personas__persona_id__network_get(
  persona_id: string,
  depth?: number,
  max_nodes?: number,
): Promise<NetworkResponse> {
  // Get Network
  // GET /v1/personas/{persona_id}/network
  throw new Error("Not implemented");
}

export async function can_communicate_v1_personas__persona_id__can_communicate__other_id__get(
  persona_id: string,
  other_id: string,
  max_depth?: number,
): Promise<CanCommunicateResponse> {
  // Check Communication
  // GET /v1/personas/{persona_id}/can-communicate/{other_id}
  throw new Error("Not implemented");
}

export async function send_chat_message_v1_personas__persona_id__chat_post(
  persona_id: string,
  body: ChatRequest,
): Promise<ChatResponse> {
  // Send Chat Message
  // POST /v1/personas/{persona_id}/chat
  throw new Error("Not implemented");
}

// STREAMING: POST /v1/personas/{persona_id}/chat/stream
export async function stream_chat_message_v1_personas__persona_id__chat_stream_post(
  persona_id: string,
  body: ChatRequest,
): Promise<void> {
  // Stream Chat Message
  // POST /v1/personas/{persona_id}/chat/stream
  throw new Error("Not implemented");
}

export async function list_conversations_v1_personas__persona_id__conversations_get(
  persona_id: string,
  page?: number,
  per_page?: number,
): Promise<ConversationListResponse> {
  // List Conversations
  // GET /v1/personas/{persona_id}/conversations
  throw new Error("Not implemented");
}

export async function get_conversation_v1_personas__persona_id__conversations__conversation_id__get(
  persona_id: string,
  conversation_id: string,
): Promise<ConversationResponse> {
  // Get Conversation
  // GET /v1/personas/{persona_id}/conversations/{conversation_id}
  throw new Error("Not implemented");
}

export async function delete_conversation_v1_personas__persona_id__conversations__conversation_id__delete(
  persona_id: string,
  conversation_id: string,
): Promise<void> {
  // Delete Conversation
  // DELETE /v1/personas/{persona_id}/conversations/{conversation_id}
  throw new Error("Not implemented");
}

export async function create_session_v1_chat_sessions_post(
  body: CreateSessionRequest,
): Promise<Chat_sessionsSessionResponse> {
  // Create Session
  // POST /v1/chat/sessions
  throw new Error("Not implemented");
}

export async function list_sessions_v1_chat_sessions_get(
  user_id?: string,
  mode?: string,
  domain_id?: string,
  include_archived?: boolean,
  page?: number,
  per_page?: number,
): Promise<Chat_sessionsSessionListResponse> {
  // List Sessions
  // GET /v1/chat/sessions
  throw new Error("Not implemented");
}

export async function get_usage_stats_v1_chat_usage_stats_get(
  team_id?: string,
  start_date?: string,
  end_date?: string,
): Promise<TeamUsageStatsResponse> {
  // Get Usage Stats
  // GET /v1/chat/usage/stats
  throw new Error("Not implemented");
}

export async function get_session_stats_v1_chat_sessions_stats_get(
  team_id?: string,
  start_date?: string,
  end_date?: string,
): Promise<Chat_sessionsSessionStatsResponse> {
  // Get Session Stats
  // GET /v1/chat/sessions/stats
  throw new Error("Not implemented");
}

export async function get_session_v1_chat_sessions__session_id__get(
  session_id: string,
  user_id?: string,
): Promise<Chat_sessionsSessionDetailResponse> {
  // Get Session
  // GET /v1/chat/sessions/{session_id}
  throw new Error("Not implemented");
}

export async function update_session_v1_chat_sessions__session_id__patch(
  session_id: string,
  body: UpdateSessionRequest,
): Promise<Chat_sessionsSessionResponse> {
  // Update Session
  // PATCH /v1/chat/sessions/{session_id}
  throw new Error("Not implemented");
}

export async function delete_session_v1_chat_sessions__session_id__delete(
  session_id: string,
): Promise<void> {
  // Delete Session
  // DELETE /v1/chat/sessions/{session_id}
  throw new Error("Not implemented");
}

export async function archive_session_v1_chat_sessions__session_id__archive_post(
  session_id: string,
): Promise<Chat_sessionsSessionResponse> {
  // Archive Session
  // POST /v1/chat/sessions/{session_id}/archive
  throw new Error("Not implemented");
}

export async function add_message_v1_chat_sessions__session_id__messages_post(
  session_id: string,
  body: AddMessageRequest,
): Promise<MessageResponse> {
  // Add Message
  // POST /v1/chat/sessions/{session_id}/messages
  throw new Error("Not implemented");
}

export async function get_messages_v1_chat_sessions__session_id__messages_get(
  session_id: string,
  limit?: number,
  offset?: number,
): Promise<void> {
  // Get Messages
  // GET /v1/chat/sessions/{session_id}/messages
  throw new Error("Not implemented");
}

// STREAMING: POST /v1/aggregate/stream
export async function execute_streaming_query_v1_aggregate_stream_post(
  body: StreamingQueryRequest,
): Promise<void> {
  // Streaming Aggregate Query
  // POST /v1/aggregate/stream
  throw new Error("Not implemented");
}

export async function execute_grouped_streaming_query_v1_aggregate_stream_grouped_post(
  body: GroupedStreamingQueryRequest,
): Promise<void> {
  // Grouped Streaming Aggregate Query
  // POST /v1/aggregate/stream/grouped
  throw new Error("Not implemented");
}

export async function count_matching_personas_v1_aggregate_count_get(
  domain?: string,
  filters?: string,
  region?: string,
  archetype?: string,
  age_min?: number,
  age_max?: number,
): Promise<void> {
  // Count Matching Personas
  // GET /v1/aggregate/count
  throw new Error("Not implemented");
}

export async function run_simulation_v1_aggregate_simulation_post(
  body: SimulationRequest,
): Promise<AggregateSimulationResponse> {
  // Run Scenario Simulation
  // POST /v1/aggregate/simulation
  throw new Error("Not implemented");
}

export async function trace_influence_v1_aggregate_influence__persona_id__get(
  persona_id: string,
  influence_type?: InfluenceType,
  max_depth?: number,
  direction?: string,
): Promise<InfluenceQueryResponse> {
  // Trace Influence Paths
  // GET /v1/aggregate/influence/{persona_id}
  throw new Error("Not implemented");
}

export async function get_statistics_v1_aggregate_stats_get(
): Promise<AggregateStatsResponse> {
  // Query Statistics
  // GET /v1/aggregate/stats
  throw new Error("Not implemented");
}

export async function get_session_info_v1_sessions_info_get(
): Promise<SessionInfoResponse> {
  // Get Session System Info
  // GET /v1/sessions/info
  throw new Error("Not implemented");
}

export async function get_session_hierarchy_v1_sessions_hierarchy_get(
): Promise<HierarchyResponse> {
  // Get Session Hierarchy
  // GET /v1/sessions/hierarchy
  throw new Error("Not implemented");
}

export async function create_session_v1_sessions_post(
  body: SessionCreate,
): Promise<SessionsSessionDetailResponse> {
  // Create Session
  // POST /v1/sessions
  throw new Error("Not implemented");
}

export async function list_sessions_v1_sessions_get(
  tier?: number,
  status?: SessionStatus,
  parent_session_id?: string,
  page?: number,
  per_page?: number,
): Promise<SessionsSessionListResponse> {
  // List Sessions
  // GET /v1/sessions
  throw new Error("Not implemented");
}

export async function get_session_v1_sessions__session_id__get(
  session_id: string,
): Promise<SessionsSessionDetailResponse> {
  // Get Session
  // GET /v1/sessions/{session_id}
  throw new Error("Not implemented");
}

export async function cancel_session_v1_sessions__session_id__delete(
  session_id: string,
  cancel_children?: boolean,
): Promise<void> {
  // Cancel Session
  // DELETE /v1/sessions/{session_id}
  throw new Error("Not implemented");
}

export async function get_children_v1_sessions__session_id__children_get(
  session_id: string,
  page?: number,
  per_page?: number,
): Promise<SessionsSessionListResponse> {
  // Get Child Sessions
  // GET /v1/sessions/{session_id}/children
  throw new Error("Not implemented");
}

export async function aggregate_children_v1_sessions__session_id__aggregate_post(
  session_id: string,
  body: AggregateChildrenRequest,
): Promise<AggregateChildrenResponse> {
  // Aggregate Child Responses
  // POST /v1/sessions/{session_id}/aggregate
  throw new Error("Not implemented");
}

export async function get_stats_v1_sessions_stats_summary_get(
): Promise<SessionsSessionStatsResponse> {
  // Get Session Statistics
  // GET /v1/sessions/stats/summary
  throw new Error("Not implemented");
}

export async function list_domains_v1_domains__get(
  page?: number,
  per_page?: number,
  include_drafts?: boolean,
  registered_only?: boolean,
): Promise<DomainListResponse> {
  // List Domains
  // GET /v1/domains/
  throw new Error("Not implemented");
}

export async function create_domain_v1_domains__post(
  body: DomainConfigCreate_Input,
): Promise<DomainDetailResponse> {
  // Create Domain
  // POST /v1/domains/
  throw new Error("Not implemented");
}

export async function lookup_domain_v1_domains_lookup_get(
  slug?: string,
): Promise<void> {
  // Lookup Domain ID by Slug
  // GET /v1/domains/lookup
  throw new Error("Not implemented");
}

export async function get_domain_v1_domains__domain_name__get(
  domain_name: string,
): Promise<DomainDetailResponse> {
  // Get Domain
  // GET /v1/domains/{domain_name}
  throw new Error("Not implemented");
}

export async function update_domain_v1_domains__domain_name__put(
  domain_name: string,
  body: DomainConfigUpdate,
): Promise<DomainDetailResponse> {
  // Update Domain
  // PUT /v1/domains/{domain_name}
  throw new Error("Not implemented");
}

export async function patch_domain_v1_domains__domain_name__patch(
  domain_name: string,
  body: DomainConfigUpdate,
): Promise<DomainDetailResponse> {
  // Partially Update Domain
  // PATCH /v1/domains/{domain_name}
  throw new Error("Not implemented");
}

export async function delete_domain_v1_domains__domain_name__delete(
  domain_name: string,
): Promise<void> {
  // Delete Domain
  // DELETE /v1/domains/{domain_name}
  throw new Error("Not implemented");
}

export async function validate_domain_v1_domains_validate_post(
  body: DomainConfigCreate_Input,
): Promise<DomainValidationResponse> {
  // Validate Domain Configuration
  // POST /v1/domains/validate
  throw new Error("Not implemented");
}

export async function register_domain_v1_domains__domain_name__register_post(
  domain_name: string,
): Promise<DomainRegistrationResponse> {
  // Register Domain
  // POST /v1/domains/{domain_name}/register
  throw new Error("Not implemented");
}

export async function unregister_domain_v1_domains__domain_name__unregister_post(
  domain_name: string,
): Promise<DomainRegistrationResponse> {
  // Unregister Domain
  // POST /v1/domains/{domain_name}/unregister
  throw new Error("Not implemented");
}

export async function generate_domain_v1_domains_generate_post(
  body: ClaudeGenerateRequest,
): Promise<GeneratedConfigResponse> {
  // Generate Domain from Description
  // POST /v1/domains/generate
  throw new Error("Not implemented");
}

export async function refine_domain_v1_domains_generate_refine_post(
  body: ClaudeRefineRequest,
): Promise<GeneratedConfigResponse> {
  // Refine Generated Configuration
  // POST /v1/domains/generate/refine
  throw new Error("Not implemented");
}

export async function generate_domain_phased_v1_domains_generate_phased_post(
  body: PhasedGenerateRequest,
): Promise<void> {
  // Generate Domain with SSE Progress
  // POST /v1/domains/generate-phased
  throw new Error("Not implemented");
}

export async function get_domain_archetypes_v1_domains__domain_name__archetypes_get(
  domain_name: string,
  tier?: number,
  parent_id?: string,
): Promise<ArchetypeListResponse> {
  // Get Domain Archetypes
  // GET /v1/domains/{domain_name}/archetypes
  throw new Error("Not implemented");
}

export async function get_archetype_stats_v1_domains__domain_name__archetypes_stats_get(
  domain_name: string,
): Promise<ArchetypeStatsResponse> {
  // Get Archetype Statistics
  // GET /v1/domains/{domain_name}/archetypes/stats
  throw new Error("Not implemented");
}

export async function compose_identity_v1_domains__domain_name__archetypes_compose_post(
  domain_name: string,
  body: ComposeRequest,
): Promise<ComposedIdentityResponse> {
  // Compose Identity
  // POST /v1/domains/{domain_name}/archetypes/compose
  throw new Error("Not implemented");
}

export async function validate_personality_v1_domains__domain_name__schema_validate_post(
  domain_name: string,
  body: SchemaValidateRequest,
): Promise<SchemaValidateResponse> {
  // Validate Personality Values
  // POST /v1/domains/{domain_name}/schema/validate
  throw new Error("Not implemented");
}

export async function clamp_personality_v1_domains__domain_name__schema_clamp_post(
  domain_name: string,
  body: SchemaClampRequest,
): Promise<SchemaClampResponse> {
  // Clamp Personality Values
  // POST /v1/domains/{domain_name}/schema/clamp
  throw new Error("Not implemented");
}

export async function generate_prompt_v1_domains__domain_name__prompt_post(
  domain_name: string,
  body: PromptGenerateRequest,
): Promise<PromptGenerateResponse> {
  // Generate System Prompt
  // POST /v1/domains/{domain_name}/prompt
  throw new Error("Not implemented");
}

export async function list_domain_personas_v1_domains__domain_id__personas_get(
  domain_id: string,
  page?: number,
  per_page?: number,
  region?: string,
  archetype?: string,
  age_min?: number,
  age_max?: number,
  ids?: string,
  batch_id?: string,
  search?: string,
): Promise<DomainPersonaListResponse> {
  // List Domain Personas
  // GET /v1/domains/{domain_id}/personas
  throw new Error("Not implemented");
}

export async function create_domain_persona_v1_domains__domain_id__personas_post(
  domain_id: string,
  body: PersonaCreateRequest,
): Promise<DomainsPersonaDetailResponse> {
  // Create Persona
  // POST /v1/domains/{domain_id}/personas
  throw new Error("Not implemented");
}

export async function get_batch_summary_v1_domains__domain_id__personas_batch_summary_get(
  domain_id: string,
): Promise<BatchSummaryResponse> {
  // Get Batch Summary
  // GET /v1/domains/{domain_id}/personas/batch-summary
  throw new Error("Not implemented");
}

export async function get_domain_persona_filters_v1_domains__domain_id__personas_filters_get(
  domain_id: string,
): Promise<DomainPersonaFiltersResponse> {
  // Get Persona Filter Options
  // GET /v1/domains/{domain_id}/personas/filters
  throw new Error("Not implemented");
}

export async function get_domain_tier_filters_v1_domains__domain_id__tier_filters_get(
  domain_id: string,
): Promise<DomainTierFiltersResponse> {
  // Get Tier-Based Filter Options
  // GET /v1/domains/{domain_id}/tier-filters
  throw new Error("Not implemented");
}

export async function batch_delete_domain_personas_v1_domains__domain_id__personas_batch_delete_post(
  domain_id: string,
  body: BatchDeleteRequest,
): Promise<BatchDeleteResponse> {
  // Batch Delete Personas
  // POST /v1/domains/{domain_id}/personas/batch-delete
  throw new Error("Not implemented");
}

export async function get_domain_persona_v1_domains__domain_id__personas__persona_id__get(
  domain_id: string,
  persona_id: string,
): Promise<DomainsPersonaDetailResponse> {
  // Get Domain Persona
  // GET /v1/domains/{domain_id}/personas/{persona_id}
  throw new Error("Not implemented");
}

export async function update_domain_persona_v1_domains__domain_id__personas__persona_id__patch(
  domain_id: string,
  persona_id: string,
  body: PersonaUpdateRequest,
): Promise<DomainsPersonaDetailResponse> {
  // Update Domain Persona
  // PATCH /v1/domains/{domain_id}/personas/{persona_id}
  throw new Error("Not implemented");
}

export async function delete_domain_persona_v1_domains__domain_id__personas__persona_id__delete(
  domain_id: string,
  persona_id: string,
): Promise<void> {
  // Delete Domain Persona
  // DELETE /v1/domains/{domain_id}/personas/{persona_id}
  throw new Error("Not implemented");
}

export async function batch_domain_persona_operations_v1_domains__domain_id__personas_batch_post(
  domain_id: string,
  body: BatchOperationRequest,
): Promise<BatchOperationResponse> {
  // Batch Persona Operations
  // POST /v1/domains/{domain_id}/personas/batch
  throw new Error("Not implemented");
}

export async function batch_create_personas_stream_v1_domains__domain_id__personas_batch_stream_post(
  domain_id: string,
  body: BatchOperationRequest,
): Promise<void> {
  // Batch Create Personas with SSE Progress
  // POST /v1/domains/{domain_id}/personas/batch/stream
  throw new Error("Not implemented");
}

export async function create_single_persona_v1_domains__domain_id__personas_single_post(
  domain_id: string,
  body: SinglePersonaCreateRequest,
): Promise<DomainsPersonaDetailResponse> {
  // Create Single Crafted Persona
  // POST /v1/domains/{domain_id}/personas/single
  throw new Error("Not implemented");
}

export async function import_persona_v1_domains__domain_id__personas_import_post(
  domain_id: string,
  body: PersonaImportRequest,
): Promise<PersonaImportResponse> {
  // Import Persona from JSON
  // POST /v1/domains/{domain_id}/personas/import
  throw new Error("Not implemented");
}

export async function export_persona_v1_domains__domain_id__personas__persona_id__export_get(
  domain_id: string,
  persona_id: string,
  format?: PersonaExportFormat,
): Promise<void> {
  // Export Persona to JSON/YAML
  // GET /v1/domains/{domain_id}/personas/{persona_id}/export
  throw new Error("Not implemented");
}

export async function validate_persona_data_v1_domains__domain_id__personas_validate_post(
  domain_id: string,
  body: PersonaImportRequest,
): Promise<void> {
  // Validate Persona Data
  // POST /v1/domains/{domain_id}/personas/validate
  throw new Error("Not implemented");
}

export async function list_persona_versions_v1_domains__domain_id__personas__persona_id__versions_get(
  domain_id: string,
  persona_id: string,
  page?: number,
  per_page?: number,
): Promise<void> {
  // List Persona Versions
  // GET /v1/domains/{domain_id}/personas/{persona_id}/versions
  throw new Error("Not implemented");
}

export async function get_persona_version_v1_domains__domain_id__personas__persona_id__versions__version_number__get(
  domain_id: string,
  persona_id: string,
  version_number: number,
): Promise<VersionDetail> {
  // Get Specific Version
  // GET /v1/domains/{domain_id}/personas/{persona_id}/versions/{version_number}
  throw new Error("Not implemented");
}

export async function compare_persona_versions_v1_domains__domain_id__personas__persona_id__versions_compare_get(
  domain_id: string,
  persona_id: string,
  from_version?: number,
  to_version?: number,
): Promise<VersionDiffResponse> {
  // Compare Versions
  // GET /v1/domains/{domain_id}/personas/{persona_id}/versions/compare
  throw new Error("Not implemented");
}

export async function restore_persona_version_v1_domains__domain_id__personas__persona_id__versions__version_number__restore_post(
  domain_id: string,
  persona_id: string,
  version_number: number,
): Promise<DomainsPersonaDetailResponse> {
  // Restore to Version
  // POST /v1/domains/{domain_id}/personas/{persona_id}/versions/{version_number}/restore
  throw new Error("Not implemented");
}

export async function get_domain_network_v1_domains__domain_id__network_get(
  domain_id: string,
  cluster_by?: string,
  include_isolated?: boolean,
  max_nodes?: number,
  as_of?: string,
  filters?: string,
): Promise<DomainNetworkResponse> {
  // Get Domain Network
  // GET /v1/domains/{domain_id}/network
  throw new Error("Not implemented");
}

export async function generate_persona_ai_v1_domains__domain_id__personas_generate_ai_post(
  domain_id: string,
  body: AIGenerateRequest,
): Promise<void> {
  // AI-Assisted Persona Generation (SSE)
  // POST /v1/domains/{domain_id}/personas/generate-ai
  throw new Error("Not implemented");
}

export async function refine_persona_ai_v1_domains__domain_id__personas_refine_ai_post(
  domain_id: string,
  body: AIRefineRequest,
): Promise<void> {
  // Refine AI-Generated Persona (SSE)
  // POST /v1/domains/{domain_id}/personas/refine-ai
  throw new Error("Not implemented");
}

export async function accept_persona_ai_v1_domains__domain_id__personas_accept_ai_post(
  domain_id: string,
  body: AcceptPersonaRequest,
): Promise<void> {
  // Accept AI-Generated Persona
  // POST /v1/domains/{domain_id}/personas/accept-ai
  throw new Error("Not implemented");
}

export async function get_example_prompts_v1_domains__domain_id__personas_generate_ai_examples_get(
  domain_id: string,
): Promise<void> {
  // Get Example Prompts
  // GET /v1/domains/{domain_id}/personas/generate-ai/examples
  throw new Error("Not implemented");
}

export async function get_api_info_v1_api_info_get(
): Promise<APIInfoResponse> {
  // Get API Info
  // GET /v1/api/info
  throw new Error("Not implemented");
}

export async function get_memory_stats_v1_memory_stats_get(
): Promise<MemoryStatsResponse> {
  // Get Memory Statistics
  // GET /v1/memory/stats
  throw new Error("Not implemented");
}

export async function get_memories_v1_memory__persona_id__get(
  persona_id: string,
  limit?: number,
  offset?: number,
): Promise<MemoriesResponse> {
  // Get Persona Memories
  // GET /v1/memory/{persona_id}
  throw new Error("Not implemented");
}

export async function add_memory_v1_memory__persona_id__post(
  persona_id: string,
  body: MemoryCreate,
): Promise<void> {
  // Add Memory
  // POST /v1/memory/{persona_id}
  throw new Error("Not implemented");
}

export async function clear_memories_v1_memory__persona_id__delete(
  persona_id: string,
): Promise<void> {
  // Clear Memories
  // DELETE /v1/memory/{persona_id}
  throw new Error("Not implemented");
}

export async function delete_memory_v1_memory__persona_id___memory_id__delete(
  persona_id: string,
  memory_id: string,
): Promise<void> {
  // Delete Single Memory
  // DELETE /v1/memory/{persona_id}/{memory_id}
  throw new Error("Not implemented");
}

export async function record_memory_access_v1_memory__persona_id___memory_id__access_patch(
  persona_id: string,
  memory_id: string,
): Promise<void> {
  // Record Memory Access
  // PATCH /v1/memory/{persona_id}/{memory_id}/access
  throw new Error("Not implemented");
}

export async function add_knowledge_v1_memory__persona_id__knowledge_post(
  persona_id: string,
  body: KnowledgeCreate,
): Promise<void> {
  // Add Knowledge
  // POST /v1/memory/{persona_id}/knowledge
  throw new Error("Not implemented");
}

export async function get_knowledge_v1_memory__persona_id__knowledge_get(
  persona_id: string,
): Promise<void> {
  // Get Knowledge
  // GET /v1/memory/{persona_id}/knowledge
  throw new Error("Not implemented");
}

export async function generate_persona_memories_v1_memory__persona_id__generate_post(
  persona_id: string,
): Promise<MemoryGenerateResponse> {
  // Generate Memories
  // POST /v1/memory/{persona_id}/generate
  throw new Error("Not implemented");
}

export async function add_memories_batch_v1_memory__persona_id__batch_post(
  persona_id: string,
): Promise<void> {
  // Add Memories in Batch
  // POST /v1/memory/{persona_id}/batch
  throw new Error("Not implemented");
}

export async function consolidate_memories_v1_memory__persona_id__consolidate_post(
  persona_id: string,
): Promise<ConsolidationResponse> {
  // Consolidate Memories
  // POST /v1/memory/{persona_id}/consolidate
  throw new Error("Not implemented");
}

export async function get_working_memory_v1_memory__persona_id__working_get(
  persona_id: string,
): Promise<void> {
  // Get Working Memory
  // GET /v1/memory/{persona_id}/working
  throw new Error("Not implemented");
}

export async function generate_batch_memories_v1_domains__domain_id__memories_generate_batch_post(
  domain_id: string,
): Promise<void> {
  // Generate Memories for Multiple Personas
  // POST /v1/domains/{domain_id}/memories/generate-batch
  throw new Error("Not implemented");
}

export async function list_bloom_jobs_v1_domains__domain_id__memories_bloom_jobs_get(
  domain_id: string,
  status_filter?: string,
  page?: number,
  per_page?: number,
): Promise<void> {
  // List Batch Bloom Jobs
  // GET /v1/domains/{domain_id}/memories/bloom-jobs
  throw new Error("Not implemented");
}

export async function get_bloom_job_v1_domains__domain_id__memories_bloom_jobs__job_id__get(
  domain_id: string,
  job_id: string,
): Promise<BatchBloomJobResponse> {
  // Get Batch Bloom Job
  // GET /v1/domains/{domain_id}/memories/bloom-jobs/{job_id}
  throw new Error("Not implemented");
}

export async function cancel_bloom_job_v1_domains__domain_id__memories_bloom_jobs__job_id__cancel_post(
  domain_id: string,
  job_id: string,
): Promise<BatchBloomJobResponse> {
  // Cancel Batch Bloom Job
  // POST /v1/domains/{domain_id}/memories/bloom-jobs/{job_id}/cancel
  throw new Error("Not implemented");
}

export async function get_dashboard_metrics_v1_metrics_dashboard_get(
): Promise<DashboardMetrics> {
  // Get Dashboard Metrics
  // GET /v1/metrics/dashboard
  throw new Error("Not implemented");
}

export async function get_streaming_metrics_v1_metrics_streaming_get(
): Promise<StreamingMetrics> {
  // Get Streaming Metrics
  // GET /v1/metrics/streaming
  throw new Error("Not implemented");
}

export async function get_sampling_metrics_v1_metrics_sampling_get(
): Promise<SamplingMetrics> {
  // Get Sampling Metrics
  // GET /v1/metrics/sampling
  throw new Error("Not implemented");
}

export async function get_cache_metrics_v1_metrics_cache_get(
): Promise<PromptCacheMetrics> {
  // Get Cache Metrics
  // GET /v1/metrics/cache
  throw new Error("Not implemented");
}

export async function get_model_usage_v1_metrics_models_get(
): Promise<ModelUsageMetrics> {
  // Get Model Usage
  // GET /v1/metrics/models
  throw new Error("Not implemented");
}

export async function run_sampling_simulation_v1_sampling_simulate_post(
  body: SamplingRequest,
): Promise<SamplingResponse> {
  // Run Sampling Simulation
  // POST /v1/sampling/simulate
  throw new Error("Not implemented");
}

export async function get_sampling_info_v1_sampling_info_get(
): Promise<void> {
  // Get Sampling Info
  // GET /v1/sampling/info
  throw new Error("Not implemented");
}

export async function get_components_info_v1_components_info_get(
): Promise<ComponentsInfoResponse> {
  // Get Components Info
  // GET /v1/components/info
  throw new Error("Not implemented");
}

export async function list_bundles_v1_components_bundles_get(
  tag?: string,
  builtin_only?: boolean,
): Promise<BundleListResponse> {
  // List Bundles
  // GET /v1/components/bundles
  throw new Error("Not implemented");
}

export async function get_bundle_v1_components_bundles__name__get(
  name: string,
): Promise<ComponentBundle> {
  // Get Bundle
  // GET /v1/components/bundles/{name}
  throw new Error("Not implemented");
}

export async function list_tags_v1_components_tags_get(
): Promise<TagListResponse> {
  // List Tags
  // GET /v1/components/tags
  throw new Error("Not implemented");
}

export async function preview_schema_v1_components_preview_post(
  body: PreviewRequest,
): Promise<PreviewResponse> {
  // Preview Composed Schema
  // POST /v1/components/preview
  throw new Error("Not implemented");
}

export async function build_schema_v1_components_build_post(
  body: BuildRequest,
): Promise<BuildResponse> {
  // Build Schema
  // POST /v1/components/build
  throw new Error("Not implemented");
}

export async function register_bundle_v1_components_register_post(
  body: RegisterRequest,
): Promise<RegisterResponse> {
  // Register Custom Bundle
  // POST /v1/components/register
  throw new Error("Not implemented");
}

export async function get_ppv_info_v1_ppv__domain_name__info_get(
  domain_name: string,
): Promise<PPVInfoResponse> {
  // Get PPV Info
  // GET /v1/ppv/{domain_name}/info
  throw new Error("Not implemented");
}

export async function encode_personality_v1_ppv__domain_name__encode_post(
  domain_name: string,
  body: PPVEncodeRequest,
): Promise<PPVEncodeResponse> {
  // Encode Personality to PPV
  // POST /v1/ppv/{domain_name}/encode
  throw new Error("Not implemented");
}

export async function decode_personality_v1_ppv__domain_name__decode_post(
  domain_name: string,
  body: PPVDecodeRequest,
): Promise<PPVDecodeResponse> {
  // Decode PPV to Personality
  // POST /v1/ppv/{domain_name}/decode
  throw new Error("Not implemented");
}

export async function list_validations_v1_validations_get(
  page?: number,
  per_page?: number,
  status?: ValidationStatus,
  model?: string,
  framework?: string,
): Promise<ValidationListResponse> {
  // List Validation Jobs
  // GET /v1/validations
  throw new Error("Not implemented");
}

export async function create_validation_v1_validations_post(
  body: ValidationCreateRequest,
): Promise<ValidationResponse> {
  // Create Validation Job
  // POST /v1/validations
  throw new Error("Not implemented");
}

export async function delete_validations_bulk_v1_validations_delete(
  framework?: string,
  status?: string,
): Promise<ValidationDeleteResponse> {
  // Bulk Delete Validations
  // DELETE /v1/validations
  throw new Error("Not implemented");
}

export async function get_validation_config_v1_validations_config__framework_slug__get(
  framework_slug: string,
): Promise<void> {
  // Get Validation Config
  // GET /v1/validations/config/{framework_slug}
  throw new Error("Not implemented");
}

export async function compare_validations_v1_validations_compare_get(
  ids?: string,
): Promise<void> {
  // Compare Validations
  // GET /v1/validations/compare
  throw new Error("Not implemented");
}

export async function get_instrument_metadata_v1_validations_instruments__framework_slug__get(
  framework_slug: string,
): Promise<void> {
  // Get Instrument Metadata
  // GET /v1/validations/instruments/{framework_slug}
  throw new Error("Not implemented");
}

export async function get_validation_v1_validations__job_id__get(
  job_id: string,
): Promise<ValidationResponse> {
  // Get Validation Job
  // GET /v1/validations/{job_id}
  throw new Error("Not implemented");
}

export async function cancel_validation_v1_validations__job_id__cancel_post(
  job_id: string,
): Promise<ValidationCancelResponse> {
  // Cancel Validation Job
  // POST /v1/validations/{job_id}/cancel
  throw new Error("Not implemented");
}

export async function delete_validation_v1_validations__validation_id__delete(
  validation_id: string,
): Promise<ValidationDeleteResponse> {
  // Delete Validation
  // DELETE /v1/validations/{validation_id}
  throw new Error("Not implemented");
}

export async function get_raw_data_v1_validations__job_id__raw_data_get(
  job_id: string,
): Promise<void> {
  // Get Raw Validation Data
  // GET /v1/validations/{job_id}/raw-data
  throw new Error("Not implemented");
}

export async function get_tuning_report_v1_validations__job_id__tuning_report_get(
  job_id: string,
): Promise<void> {
  // Get Tuning Report
  // GET /v1/validations/{job_id}/tuning-report
  throw new Error("Not implemented");
}

export async function get_supported_models_v1_validations_supported_models_get(
): Promise<void> {
  // Get Supported Models
  // GET /v1/validations/supported/models
  throw new Error("Not implemented");
}

export async function get_supported_frameworks_v1_validations_supported_frameworks_get(
): Promise<void> {
  // Get Supported Frameworks
  // GET /v1/validations/supported/frameworks
  throw new Error("Not implemented");
}

export async function list_frameworks_v1_frameworks_get(
  page?: number,
  per_page?: number,
  category?: string,
  search?: string,
  builtin?: boolean,
): Promise<FrameworkListResponse> {
  // List Frameworks
  // GET /v1/frameworks
  throw new Error("Not implemented");
}

export async function create_framework_v1_frameworks_post(
  body: FrameworkCreateRequest,
): Promise<FrameworkDetailResponse> {
  // Create Framework
  // POST /v1/frameworks
  throw new Error("Not implemented");
}

export async function get_framework_v1_frameworks__framework_id__get(
  framework_id: string,
): Promise<FrameworkDetailResponse> {
  // Get Framework
  // GET /v1/frameworks/{framework_id}
  throw new Error("Not implemented");
}

export async function update_framework_v1_frameworks__framework_id__patch(
  framework_id: string,
  body: FrameworkUpdateRequest,
): Promise<FrameworkDetailResponse> {
  // Update Framework
  // PATCH /v1/frameworks/{framework_id}
  throw new Error("Not implemented");
}

export async function delete_framework_v1_frameworks__framework_id__delete(
  framework_id: string,
): Promise<void> {
  // Delete Framework
  // DELETE /v1/frameworks/{framework_id}
  throw new Error("Not implemented");
}

export async function update_trait_grounding_v1_frameworks__framework_id__traits__trait_name__grounding_patch(
  framework_id: string,
  trait_name: string,
  body: TraitGroundingUpdateRequest,
): Promise<FrameworkDetailResponse> {
  // Update Trait Grounding
  // PATCH /v1/frameworks/{framework_id}/traits/{trait_name}/grounding
  throw new Error("Not implemented");
}

export async function get_framework_validations_v1_frameworks__framework_id__validations_get(
  framework_id: string,
): Promise<FrameworkValidationsResponse> {
  // Get Framework Validations
  // GET /v1/frameworks/{framework_id}/validations
  throw new Error("Not implemented");
}

export async function add_instrument_v1_frameworks__framework_id__instruments_post(
  framework_id: string,
  body: InstrumentSchema,
): Promise<FrameworkDetailResponse> {
  // Add Instrument
  // POST /v1/frameworks/{framework_id}/instruments
  throw new Error("Not implemented");
}

export async function remove_instrument_v1_frameworks__framework_id__instruments__instrument_id__delete(
  framework_id: string,
  instrument_id: string,
): Promise<FrameworkDetailResponse> {
  // Remove Instrument
  // DELETE /v1/frameworks/{framework_id}/instruments/{instrument_id}
  throw new Error("Not implemented");
}

export async function auto_tune_grounding_v1_frameworks__framework_id__auto_tune_post(
  framework_id: string,
  body: AutoTuneRequest,
): Promise<AutoTuneResponse> {
  // Auto-Tune Trait Grounding
  // POST /v1/frameworks/{framework_id}/auto-tune
  throw new Error("Not implemented");
}

export async function create_template_v1_templates_post(
  body: CreateTemplateRequest,
): Promise<void> {
  // Create a persona template
  // POST /v1/templates
  throw new Error("Not implemented");
}

export async function list_templates_v1_templates_get(
  domain_id?: string,
  tags?: string,
  page?: number,
  per_page?: number,
): Promise<void> {
  // List persona templates
  // GET /v1/templates
  throw new Error("Not implemented");
}

export async function get_template_v1_templates__template_id__get(
  template_id: string,
): Promise<void> {
  // Get a template
  // GET /v1/templates/{template_id}
  throw new Error("Not implemented");
}

export async function update_template_v1_templates__template_id__patch(
  template_id: string,
  body: UpdateTemplateRequest,
): Promise<void> {
  // Update a template
  // PATCH /v1/templates/{template_id}
  throw new Error("Not implemented");
}

export async function delete_template_v1_templates__template_id__delete(
  template_id: string,
): Promise<void> {
  // Delete a template
  // DELETE /v1/templates/{template_id}
  throw new Error("Not implemented");
}

export async function preview_from_template_v1_templates__template_id__preview_post(
  template_id: string,
  body: CreateFromTemplateRequest,
): Promise<void> {
  // Preview persona from template
  // POST /v1/templates/{template_id}/preview
  throw new Error("Not implemented");
}

export async function save_persona_as_template_v1_templates_from_persona_post(
  body: SaveAsTemplateRequest,
): Promise<void> {
  // Save persona as template
  // POST /v1/templates/from-persona
  throw new Error("Not implemented");
}

export async function create_simulation_v1_simulations_post(
  body: SimulationCreate,
): Promise<SimulationDetailResponse> {
  // Create Simulation
  // POST /v1/simulations
  throw new Error("Not implemented");
}

export async function list_simulations_v1_simulations_get(
  domain_id?: string,
  status?: string,
  page?: number,
  per_page?: number,
): Promise<SimulationListResponse> {
  // List Simulations
  // GET /v1/simulations
  throw new Error("Not implemented");
}

export async function get_simulation_v1_simulations__simulation_id__get(
  simulation_id: string,
): Promise<SimulationDetailResponse> {
  // Get Simulation
  // GET /v1/simulations/{simulation_id}
  throw new Error("Not implemented");
}

export async function delete_simulation_v1_simulations__simulation_id__delete(
  simulation_id: string,
): Promise<void> {
  // Delete Simulation
  // DELETE /v1/simulations/{simulation_id}
  throw new Error("Not implemented");
}

export async function add_participants_v1_simulations__simulation_id__participants_post(
  simulation_id: string,
  body: AddParticipantsRequest,
): Promise<SimulationDetailResponse> {
  // Add Participants
  // POST /v1/simulations/{simulation_id}/participants
  throw new Error("Not implemented");
}

export async function update_config_v1_simulations__simulation_id__config_patch(
  simulation_id: string,
  body: SimulationConfigUpdate,
): Promise<SimulationDetailResponse> {
  // Update Simulation Config
  // PATCH /v1/simulations/{simulation_id}/config
  throw new Error("Not implemented");
}

export async function update_visibility_v1_simulations__simulation_id__visibility_patch(
  simulation_id: string,
  body: VisibilityUpdate,
): Promise<SimulationDetailResponse> {
  // Update Simulation Visibility
  // PATCH /v1/simulations/{simulation_id}/visibility
  throw new Error("Not implemented");
}

export async function start_simulation_v1_simulations__simulation_id__start_post(
  simulation_id: string,
  body: StartRequest,
): Promise<SimulationDetailResponse> {
  // Start/Resume Simulation
  // POST /v1/simulations/{simulation_id}/start
  throw new Error("Not implemented");
}

export async function pause_simulation_v1_simulations__simulation_id__pause_post(
  simulation_id: string,
): Promise<SimulationDetailResponse> {
  // Pause Simulation
  // POST /v1/simulations/{simulation_id}/pause
  throw new Error("Not implemented");
}

export async function set_speed_v1_simulations__simulation_id__speed_patch(
  simulation_id: string,
  body: SpeedUpdate,
): Promise<SimulationDetailResponse> {
  // Set Simulation Speed
  // PATCH /v1/simulations/{simulation_id}/speed
  throw new Error("Not implemented");
}

export async function get_events_v1_simulations__simulation_id__events_get(
  simulation_id: string,
  event_type?: string,
  page?: number,
  per_page?: number,
): Promise<SimulationEventListResponse> {
  // Get Simulation Events
  // GET /v1/simulations/{simulation_id}/events
  throw new Error("Not implemented");
}

export async function broadcast_message_v1_simulations__simulation_id__broadcast_post(
  simulation_id: string,
  body: BroadcastRequest,
): Promise<BroadcastResponse> {
  // Broadcast Message
  // POST /v1/simulations/{simulation_id}/broadcast
  throw new Error("Not implemented");
}

export async function get_persona_trait_history_v1_simulations__simulation_id__history__persona_id__get(
  simulation_id: string,
  persona_id: string,
  page?: number,
  per_page?: number,
): Promise<TraitHistoryResponse> {
  // Get Persona Trait History
  // GET /v1/simulations/{simulation_id}/history/{persona_id}
  throw new Error("Not implemented");
}

export async function get_trait_history_v1_simulations__simulation_id__history_get(
  simulation_id: string,
  page?: number,
  per_page?: number,
): Promise<TraitHistoryResponse> {
  // Get Aggregated Trait History
  // GET /v1/simulations/{simulation_id}/history
  throw new Error("Not implemented");
}

export async function create_checkpoint_v1_simulations__simulation_id__checkpoints_post(
  simulation_id: string,
  body: CheckpointCreate,
): Promise<CheckpointResponse> {
  // Create Checkpoint
  // POST /v1/simulations/{simulation_id}/checkpoints
  throw new Error("Not implemented");
}

export async function list_checkpoints_v1_simulations__simulation_id__checkpoints_get(
  simulation_id: string,
  page?: number,
  per_page?: number,
): Promise<CheckpointListResponse> {
  // List Checkpoints
  // GET /v1/simulations/{simulation_id}/checkpoints
  throw new Error("Not implemented");
}

export async function restore_checkpoint_v1_simulations__simulation_id__checkpoints__checkpoint_id__restore_post(
  simulation_id: string,
  checkpoint_id: string,
): Promise<CheckpointRestoreResponse> {
  // Restore Checkpoint
  // POST /v1/simulations/{simulation_id}/checkpoints/{checkpoint_id}/restore
  throw new Error("Not implemented");
}

export async function compare_checkpoints_v1_simulations__simulation_id__checkpoints_compare_get(
  simulation_id: string,
  a?: string,
  b?: string,
): Promise<CheckpointCompareResponse> {
  // Compare Checkpoints
  // GET /v1/simulations/{simulation_id}/checkpoints/compare
  throw new Error("Not implemented");
}

export async function delete_checkpoint_v1_simulations__simulation_id__checkpoints__checkpoint_id__delete(
  simulation_id: string,
  checkpoint_id: string,
): Promise<void> {
  // Delete Checkpoint
  // DELETE /v1/simulations/{simulation_id}/checkpoints/{checkpoint_id}
  throw new Error("Not implemented");
}

export async function update_checkpoint_v1_simulations__simulation_id__checkpoints__checkpoint_id__patch(
  simulation_id: string,
  checkpoint_id: string,
  body: CheckpointUpdate,
): Promise<CheckpointResponse> {
  // Update Checkpoint
  // PATCH /v1/simulations/{simulation_id}/checkpoints/{checkpoint_id}
  throw new Error("Not implemented");
}

export async function get_simulation_usage_v1_simulations__simulation_id__usage_get(
  simulation_id: string,
): Promise<SimulationUsageResponse> {
  // Get Simulation Usage
  // GET /v1/simulations/{simulation_id}/usage
  throw new Error("Not implemented");
}

export async function export_simulation_v1_simulations__simulation_id__export_get(
  simulation_id: string,
  format?: string,
): Promise<void> {
  // Export Simulation Data
  // GET /v1/simulations/{simulation_id}/export
  throw new Error("Not implemented");
}

export async function get_network_v1_simulations__simulation_id__network_get(
  simulation_id: string,
  tick?: number,
  max_nodes?: number,
  max_edges?: number,
  cluster_by?: string,
  filters?: string,
): Promise<SimNetworkResponse> {
  // Get Simulation Network Graph
  // GET /v1/simulations/{simulation_id}/network
  throw new Error("Not implemented");
}

export async function stream_events_v1_simulations__simulation_id__stream_get(
  simulation_id: string,
): Promise<void> {
  // Stream Simulation Events (SSE)
  // GET /v1/simulations/{simulation_id}/stream
  throw new Error("Not implemented");
}

export async function get_drift_report_v1_simulations__simulation_id__personas__persona_id__drift_report_get(
  simulation_id: string,
  persona_id: string,
): Promise<void> {
  // Get Drift Report
  // GET /v1/simulations/{simulation_id}/personas/{persona_id}/drift-report
  throw new Error("Not implemented");
}

export async function get_evaluation_summary_v1_simulations__simulation_id__evaluation_summary_get(
  simulation_id: string,
): Promise<void> {
  // Get Evaluation Summary
  // GET /v1/simulations/{simulation_id}/evaluation-summary
  throw new Error("Not implemented");
}

export async function image_status_v1_images_status_get(
): Promise<void> {
  // Check image generation availability
  // GET /v1/images/status
  throw new Error("Not implemented");
}

export async function generate_avatar_v1_images_generate__persona_id__post(
  persona_id: string,
  style?: string,
): Promise<void> {
  // Generate avatar for a persona
  // POST /v1/images/generate/{persona_id}
  throw new Error("Not implemented");
}

export async function get_avatar_v1_images__persona_id__avatar_get(
  persona_id: string,
): Promise<void> {
  // Serve generated avatar image
  // GET /v1/images/{persona_id}/avatar
  throw new Error("Not implemented");
}

