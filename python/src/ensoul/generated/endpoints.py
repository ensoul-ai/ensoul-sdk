"""
Generated HTTP method stubs from OpenAPI spec.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from typing import Any, Dict, List, Optional


def health_check_health_get(
) -> None:
    """Health Check

    GET /health
    """
    ...


def readiness_check_health_ready_get(
) -> None:
    """Readiness Check

    GET /health/ready
    """
    ...


def liveness_check_health_live_get(
) -> None:
    """Liveness Check

    GET /health/live
    """
    ...


def login_v1_auth_token_post(
) -> "TokenResponse":
    """OAuth2 Password Flow

    POST /v1/auth/token
    """
    ...


def refresh_token_v1_auth_refresh_post(
    body: "RefreshTokenRequest",
) -> "TokenResponse":
    """Refresh Access Token

    POST /v1/auth/refresh
    """
    ...


def get_me_v1_auth_me_get(
) -> "UserResponse":
    """Get Current User

    GET /v1/auth/me
    """
    ...


def create_api_key_v1_api_keys_post(
    body: "APIKeyRequest",
) -> "APIKeyResponse":
    """Create API Key

    POST /v1/api-keys
    """
    ...


def list_api_keys_v1_api_keys_get(
) -> None:
    """List API Keys

    GET /v1/api-keys
    """
    ...


def revoke_api_key_v1_api_keys__key_id__delete(
    key_id: str,
) -> None:
    """Revoke API Key

    DELETE /v1/api-keys/{key_id}
    """
    ...


def create_persona_v1_personas_post(
    body: "PersonaCreate",
) -> "PersonasPersonaDetailResponse":
    """Create Persona

    POST /v1/personas
    """
    ...


def list_personas_v1_personas_get(
    page: Optional[int] = None,
    per_page: Optional[int] = None,
    region: Optional[str] = None,
    archetype: Optional[str] = None,
    country: Optional[str] = None,
    city: Optional[str] = None,
) -> "PersonaListResponse":
    """List Personas

    GET /v1/personas
    """
    ...


def get_persona_filters_v1_personas_filters_get(
) -> "PersonaFiltersResponse":
    """Get Available Filters

    GET /v1/personas/filters
    """
    ...


def get_demo_personalities_v1_personas_demo_get(
) -> None:
    """Get Demo Personalities

    GET /v1/personas/demo
    """
    ...


def select_demo_personalities_v1_personas_demo_select_post(
    body: "PersonalitySelectRequest",
) -> None:
    """Select Demo Personalities

    POST /v1/personas/demo/select
    """
    ...


def regenerate_demo_personalities_v1_personas_demo_regenerate_post(
) -> None:
    """Regenerate Demo Personalities

    POST /v1/personas/demo/regenerate
    """
    ...


def get_persona_v1_personas__persona_id__get(
    persona_id: str,
) -> "PersonasPersonaDetailResponse":
    """Get Persona

    GET /v1/personas/{persona_id}
    """
    ...


def update_persona_v1_personas__persona_id__put(
    persona_id: str,
    body: "PersonaUpdate",
) -> "PersonasPersonaDetailResponse":
    """Update Persona

    PUT /v1/personas/{persona_id}
    """
    ...


def delete_persona_v1_personas__persona_id__delete(
    persona_id: str,
) -> None:
    """Delete Persona

    DELETE /v1/personas/{persona_id}
    """
    ...


def batch_create_personas_v1_personas_batch_post(
    body: "PersonaBatchCreate",
) -> "PersonaBatchResponse":
    """Batch Create Personas

    POST /v1/personas/batch
    """
    ...


def get_personality_vector_v1_personas__persona_id__personality_get(
    persona_id: str,
) -> "PersonalityVectorResponse":
    """Get Personality Vector

    GET /v1/personas/{persona_id}/personality
    """
    ...


def get_api_persona_v1_personas_api__persona_id__get(
    persona_id: str,
) -> "APIPersonaDetailResponse":
    """Get Persona from API Database

    GET /v1/personas/api/{persona_id}
    """
    ...


def delete_api_persona_v1_personas_api__persona_id__delete(
    persona_id: str,
) -> None:
    """Delete Persona from API Database

    DELETE /v1/personas/api/{persona_id}
    """
    ...


def batch_delete_personas_v1_personas_batch_delete_post(
    body: "BatchDeleteRequest",
) -> "BatchDeleteResponse":
    """Batch Delete Personas

    POST /v1/personas/batch-delete
    """
    ...


def list_connections_v1_personas__persona_id__connections_get(
    persona_id: str,
    limit: Optional[int] = None,
    offset: Optional[int] = None,
) -> "ConnectionListResponse":
    """List Connections

    GET /v1/personas/{persona_id}/connections
    """
    ...


def create_connection_v1_personas__persona_id__connections_post(
    persona_id: str,
    body: "CreateConnectionRequest",
) -> "ConnectionResponse":
    """Create Connection

    POST /v1/personas/{persona_id}/connections
    """
    ...


def get_connection_v1_personas__persona_id__connections__other_id__get(
    persona_id: str,
    other_id: str,
) -> "ConnectionResponse":
    """Get Connection

    GET /v1/personas/{persona_id}/connections/{other_id}
    """
    ...


def delete_connection_v1_personas__persona_id__connections__other_id__delete(
    persona_id: str,
    other_id: str,
) -> None:
    """Delete Connection

    DELETE /v1/personas/{persona_id}/connections/{other_id}
    """
    ...


def get_network_v1_personas__persona_id__network_get(
    persona_id: str,
    depth: Optional[int] = None,
    max_nodes: Optional[int] = None,
) -> "NetworkResponse":
    """Get Network

    GET /v1/personas/{persona_id}/network
    """
    ...


def can_communicate_v1_personas__persona_id__can_communicate__other_id__get(
    persona_id: str,
    other_id: str,
    max_depth: Optional[int] = None,
) -> "CanCommunicateResponse":
    """Check Communication

    GET /v1/personas/{persona_id}/can-communicate/{other_id}
    """
    ...


def send_chat_message_v1_personas__persona_id__chat_post(
    persona_id: str,
    body: "ChatRequest",
) -> "ChatResponse":
    """Send Chat Message

    POST /v1/personas/{persona_id}/chat
    """
    ...


# STREAMING: POST /v1/personas/{persona_id}/chat/stream
def stream_chat_message_v1_personas__persona_id__chat_stream_post(
    persona_id: str,
    body: "ChatRequest",
) -> None:
    """Stream Chat Message

    POST /v1/personas/{persona_id}/chat/stream
    Returns: SSE event stream
    """
    ...


def list_conversations_v1_personas__persona_id__conversations_get(
    persona_id: str,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "ConversationListResponse":
    """List Conversations

    GET /v1/personas/{persona_id}/conversations
    """
    ...


def get_conversation_v1_personas__persona_id__conversations__conversation_id__get(
    persona_id: str,
    conversation_id: str,
) -> "ConversationResponse":
    """Get Conversation

    GET /v1/personas/{persona_id}/conversations/{conversation_id}
    """
    ...


def delete_conversation_v1_personas__persona_id__conversations__conversation_id__delete(
    persona_id: str,
    conversation_id: str,
) -> None:
    """Delete Conversation

    DELETE /v1/personas/{persona_id}/conversations/{conversation_id}
    """
    ...


def create_session_v1_chat_sessions_post(
    body: "CreateSessionRequest",
) -> "Chat_sessionsSessionResponse":
    """Create Session

    POST /v1/chat/sessions
    """
    ...


def list_sessions_v1_chat_sessions_get(
    user_id: Optional[str] = None,
    mode: Optional[str] = None,
    domain_id: Optional[str] = None,
    include_archived: Optional[bool] = None,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "Chat_sessionsSessionListResponse":
    """List Sessions

    GET /v1/chat/sessions
    """
    ...


def get_usage_stats_v1_chat_usage_stats_get(
    team_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
) -> "TeamUsageStatsResponse":
    """Get Usage Stats

    GET /v1/chat/usage/stats
    """
    ...


def get_session_stats_v1_chat_sessions_stats_get(
    team_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
) -> "Chat_sessionsSessionStatsResponse":
    """Get Session Stats

    GET /v1/chat/sessions/stats
    """
    ...


def get_session_v1_chat_sessions__session_id__get(
    session_id: str,
    user_id: Optional[str] = None,
) -> "Chat_sessionsSessionDetailResponse":
    """Get Session

    GET /v1/chat/sessions/{session_id}
    """
    ...


def update_session_v1_chat_sessions__session_id__patch(
    session_id: str,
    body: "UpdateSessionRequest",
) -> "Chat_sessionsSessionResponse":
    """Update Session

    PATCH /v1/chat/sessions/{session_id}
    """
    ...


def delete_session_v1_chat_sessions__session_id__delete(
    session_id: str,
) -> None:
    """Delete Session

    DELETE /v1/chat/sessions/{session_id}
    """
    ...


def archive_session_v1_chat_sessions__session_id__archive_post(
    session_id: str,
) -> "Chat_sessionsSessionResponse":
    """Archive Session

    POST /v1/chat/sessions/{session_id}/archive
    """
    ...


def add_message_v1_chat_sessions__session_id__messages_post(
    session_id: str,
    body: "AddMessageRequest",
) -> "MessageResponse":
    """Add Message

    POST /v1/chat/sessions/{session_id}/messages
    """
    ...


def get_messages_v1_chat_sessions__session_id__messages_get(
    session_id: str,
    limit: Optional[int] = None,
    offset: Optional[int] = None,
) -> None:
    """Get Messages

    GET /v1/chat/sessions/{session_id}/messages
    """
    ...


# STREAMING: POST /v1/aggregate/stream
def execute_streaming_query_v1_aggregate_stream_post(
    body: "StreamingQueryRequest",
) -> None:
    """Streaming Aggregate Query

    POST /v1/aggregate/stream
    Returns: SSE event stream
    """
    ...


def execute_grouped_streaming_query_v1_aggregate_stream_grouped_post(
    body: "GroupedStreamingQueryRequest",
) -> None:
    """Grouped Streaming Aggregate Query

    POST /v1/aggregate/stream/grouped
    """
    ...


def count_matching_personas_v1_aggregate_count_get(
    domain: Optional[str] = None,
    filters: Optional[str] = None,
    region: Optional[str] = None,
    archetype: Optional[str] = None,
    age_min: Optional[int] = None,
    age_max: Optional[int] = None,
) -> None:
    """Count Matching Personas

    GET /v1/aggregate/count
    """
    ...


def run_simulation_v1_aggregate_simulation_post(
    body: "SimulationRequest",
) -> "AggregateSimulationResponse":
    """Run Scenario Simulation

    POST /v1/aggregate/simulation
    """
    ...


def trace_influence_v1_aggregate_influence__persona_id__get(
    persona_id: str,
    influence_type: Optional[InfluenceType] = None,
    max_depth: Optional[int] = None,
    direction: Optional[str] = None,
) -> "InfluenceQueryResponse":
    """Trace Influence Paths

    GET /v1/aggregate/influence/{persona_id}
    """
    ...


def get_statistics_v1_aggregate_stats_get(
) -> "AggregateStatsResponse":
    """Query Statistics

    GET /v1/aggregate/stats
    """
    ...


def get_session_info_v1_sessions_info_get(
) -> "SessionInfoResponse":
    """Get Session System Info

    GET /v1/sessions/info
    """
    ...


def get_session_hierarchy_v1_sessions_hierarchy_get(
) -> "HierarchyResponse":
    """Get Session Hierarchy

    GET /v1/sessions/hierarchy
    """
    ...


def create_session_v1_sessions_post(
    body: "SessionCreate",
) -> "SessionsSessionDetailResponse":
    """Create Session

    POST /v1/sessions
    """
    ...


def list_sessions_v1_sessions_get(
    tier: Optional[int] = None,
    status: Optional[SessionStatus] = None,
    parent_session_id: Optional[str] = None,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "SessionsSessionListResponse":
    """List Sessions

    GET /v1/sessions
    """
    ...


def get_session_v1_sessions__session_id__get(
    session_id: str,
) -> "SessionsSessionDetailResponse":
    """Get Session

    GET /v1/sessions/{session_id}
    """
    ...


def cancel_session_v1_sessions__session_id__delete(
    session_id: str,
    cancel_children: Optional[bool] = None,
) -> None:
    """Cancel Session

    DELETE /v1/sessions/{session_id}
    """
    ...


def get_children_v1_sessions__session_id__children_get(
    session_id: str,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "SessionsSessionListResponse":
    """Get Child Sessions

    GET /v1/sessions/{session_id}/children
    """
    ...


def aggregate_children_v1_sessions__session_id__aggregate_post(
    session_id: str,
    body: "AggregateChildrenRequest",
) -> "AggregateChildrenResponse":
    """Aggregate Child Responses

    POST /v1/sessions/{session_id}/aggregate
    """
    ...


def get_stats_v1_sessions_stats_summary_get(
) -> "SessionsSessionStatsResponse":
    """Get Session Statistics

    GET /v1/sessions/stats/summary
    """
    ...


def list_domains_v1_domains__get(
    page: Optional[int] = None,
    per_page: Optional[int] = None,
    include_drafts: Optional[bool] = None,
    registered_only: Optional[bool] = None,
) -> "DomainListResponse":
    """List Domains

    GET /v1/domains/
    """
    ...


def create_domain_v1_domains__post(
    body: "DomainConfigCreate_Input",
) -> "DomainDetailResponse":
    """Create Domain

    POST /v1/domains/
    """
    ...


def lookup_domain_v1_domains_lookup_get(
    slug: Optional[str] = None,
) -> None:
    """Lookup Domain ID by Slug

    GET /v1/domains/lookup
    """
    ...


def get_domain_v1_domains__domain_name__get(
    domain_name: str,
) -> "DomainDetailResponse":
    """Get Domain

    GET /v1/domains/{domain_name}
    """
    ...


def update_domain_v1_domains__domain_name__put(
    domain_name: str,
    body: "DomainConfigUpdate",
) -> "DomainDetailResponse":
    """Update Domain

    PUT /v1/domains/{domain_name}
    """
    ...


def patch_domain_v1_domains__domain_name__patch(
    domain_name: str,
    body: "DomainConfigUpdate",
) -> "DomainDetailResponse":
    """Partially Update Domain

    PATCH /v1/domains/{domain_name}
    """
    ...


def delete_domain_v1_domains__domain_name__delete(
    domain_name: str,
) -> None:
    """Delete Domain

    DELETE /v1/domains/{domain_name}
    """
    ...


def validate_domain_v1_domains_validate_post(
    body: "DomainConfigCreate_Input",
) -> "DomainValidationResponse":
    """Validate Domain Configuration

    POST /v1/domains/validate
    """
    ...


def register_domain_v1_domains__domain_name__register_post(
    domain_name: str,
) -> "DomainRegistrationResponse":
    """Register Domain

    POST /v1/domains/{domain_name}/register
    """
    ...


def unregister_domain_v1_domains__domain_name__unregister_post(
    domain_name: str,
) -> "DomainRegistrationResponse":
    """Unregister Domain

    POST /v1/domains/{domain_name}/unregister
    """
    ...


def generate_domain_v1_domains_generate_post(
    body: "ClaudeGenerateRequest",
) -> "GeneratedConfigResponse":
    """Generate Domain from Description

    POST /v1/domains/generate
    """
    ...


def refine_domain_v1_domains_generate_refine_post(
    body: "ClaudeRefineRequest",
) -> "GeneratedConfigResponse":
    """Refine Generated Configuration

    POST /v1/domains/generate/refine
    """
    ...


def generate_domain_phased_v1_domains_generate_phased_post(
    body: "PhasedGenerateRequest",
) -> None:
    """Generate Domain with SSE Progress

    POST /v1/domains/generate-phased
    """
    ...


def get_domain_archetypes_v1_domains__domain_name__archetypes_get(
    domain_name: str,
    tier: Optional[int] = None,
    parent_id: Optional[str] = None,
) -> "ArchetypeListResponse":
    """Get Domain Archetypes

    GET /v1/domains/{domain_name}/archetypes
    """
    ...


def get_archetype_stats_v1_domains__domain_name__archetypes_stats_get(
    domain_name: str,
) -> "ArchetypeStatsResponse":
    """Get Archetype Statistics

    GET /v1/domains/{domain_name}/archetypes/stats
    """
    ...


def compose_identity_v1_domains__domain_name__archetypes_compose_post(
    domain_name: str,
    body: "ComposeRequest",
) -> "ComposedIdentityResponse":
    """Compose Identity

    POST /v1/domains/{domain_name}/archetypes/compose
    """
    ...


def validate_personality_v1_domains__domain_name__schema_validate_post(
    domain_name: str,
    body: "SchemaValidateRequest",
) -> "SchemaValidateResponse":
    """Validate Personality Values

    POST /v1/domains/{domain_name}/schema/validate
    """
    ...


def clamp_personality_v1_domains__domain_name__schema_clamp_post(
    domain_name: str,
    body: "SchemaClampRequest",
) -> "SchemaClampResponse":
    """Clamp Personality Values

    POST /v1/domains/{domain_name}/schema/clamp
    """
    ...


def generate_prompt_v1_domains__domain_name__prompt_post(
    domain_name: str,
    body: "PromptGenerateRequest",
) -> "PromptGenerateResponse":
    """Generate System Prompt

    POST /v1/domains/{domain_name}/prompt
    """
    ...


def list_domain_personas_v1_domains__domain_id__personas_get(
    domain_id: str,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
    region: Optional[str] = None,
    archetype: Optional[str] = None,
    age_min: Optional[int] = None,
    age_max: Optional[int] = None,
    ids: Optional[str] = None,
    batch_id: Optional[str] = None,
    search: Optional[str] = None,
) -> "DomainPersonaListResponse":
    """List Domain Personas

    GET /v1/domains/{domain_id}/personas
    """
    ...


def create_domain_persona_v1_domains__domain_id__personas_post(
    domain_id: str,
    body: "PersonaCreateRequest",
) -> "DomainsPersonaDetailResponse":
    """Create Persona

    POST /v1/domains/{domain_id}/personas
    """
    ...


def get_batch_summary_v1_domains__domain_id__personas_batch_summary_get(
    domain_id: str,
) -> "BatchSummaryResponse":
    """Get Batch Summary

    GET /v1/domains/{domain_id}/personas/batch-summary
    """
    ...


def get_domain_persona_filters_v1_domains__domain_id__personas_filters_get(
    domain_id: str,
) -> "DomainPersonaFiltersResponse":
    """Get Persona Filter Options

    GET /v1/domains/{domain_id}/personas/filters
    """
    ...


def get_domain_tier_filters_v1_domains__domain_id__tier_filters_get(
    domain_id: str,
) -> "DomainTierFiltersResponse":
    """Get Tier-Based Filter Options

    GET /v1/domains/{domain_id}/tier-filters
    """
    ...


def batch_delete_domain_personas_v1_domains__domain_id__personas_batch_delete_post(
    domain_id: str,
    body: "BatchDeleteRequest",
) -> "BatchDeleteResponse":
    """Batch Delete Personas

    POST /v1/domains/{domain_id}/personas/batch-delete
    """
    ...


def get_domain_persona_v1_domains__domain_id__personas__persona_id__get(
    domain_id: str,
    persona_id: str,
) -> "DomainsPersonaDetailResponse":
    """Get Domain Persona

    GET /v1/domains/{domain_id}/personas/{persona_id}
    """
    ...


def update_domain_persona_v1_domains__domain_id__personas__persona_id__patch(
    domain_id: str,
    persona_id: str,
    body: "PersonaUpdateRequest",
) -> "DomainsPersonaDetailResponse":
    """Update Domain Persona

    PATCH /v1/domains/{domain_id}/personas/{persona_id}
    """
    ...


def delete_domain_persona_v1_domains__domain_id__personas__persona_id__delete(
    domain_id: str,
    persona_id: str,
) -> None:
    """Delete Domain Persona

    DELETE /v1/domains/{domain_id}/personas/{persona_id}
    """
    ...


def batch_domain_persona_operations_v1_domains__domain_id__personas_batch_post(
    domain_id: str,
    body: "BatchOperationRequest",
) -> "BatchOperationResponse":
    """Batch Persona Operations

    POST /v1/domains/{domain_id}/personas/batch
    """
    ...


def batch_create_personas_stream_v1_domains__domain_id__personas_batch_stream_post(
    domain_id: str,
    body: "BatchOperationRequest",
) -> None:
    """Batch Create Personas with SSE Progress

    POST /v1/domains/{domain_id}/personas/batch/stream
    """
    ...


def create_single_persona_v1_domains__domain_id__personas_single_post(
    domain_id: str,
    body: "SinglePersonaCreateRequest",
) -> "DomainsPersonaDetailResponse":
    """Create Single Crafted Persona

    POST /v1/domains/{domain_id}/personas/single
    """
    ...


def import_persona_v1_domains__domain_id__personas_import_post(
    domain_id: str,
    body: "PersonaImportRequest",
) -> "PersonaImportResponse":
    """Import Persona from JSON

    POST /v1/domains/{domain_id}/personas/import
    """
    ...


def export_persona_v1_domains__domain_id__personas__persona_id__export_get(
    domain_id: str,
    persona_id: str,
    format: Optional[PersonaExportFormat] = None,
) -> None:
    """Export Persona to JSON/YAML

    GET /v1/domains/{domain_id}/personas/{persona_id}/export
    """
    ...


def validate_persona_data_v1_domains__domain_id__personas_validate_post(
    domain_id: str,
    body: "PersonaImportRequest",
) -> None:
    """Validate Persona Data

    POST /v1/domains/{domain_id}/personas/validate
    """
    ...


def list_persona_versions_v1_domains__domain_id__personas__persona_id__versions_get(
    domain_id: str,
    persona_id: str,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> None:
    """List Persona Versions

    GET /v1/domains/{domain_id}/personas/{persona_id}/versions
    """
    ...


def get_persona_version_v1_domains__domain_id__personas__persona_id__versions__version_number__get(
    domain_id: str,
    persona_id: str,
    version_number: int,
) -> "VersionDetail":
    """Get Specific Version

    GET /v1/domains/{domain_id}/personas/{persona_id}/versions/{version_number}
    """
    ...


def compare_persona_versions_v1_domains__domain_id__personas__persona_id__versions_compare_get(
    domain_id: str,
    persona_id: str,
    from_version: Optional[int] = None,
    to_version: Optional[int] = None,
) -> "VersionDiffResponse":
    """Compare Versions

    GET /v1/domains/{domain_id}/personas/{persona_id}/versions/compare
    """
    ...


def restore_persona_version_v1_domains__domain_id__personas__persona_id__versions__version_number__restore_post(
    domain_id: str,
    persona_id: str,
    version_number: int,
) -> "DomainsPersonaDetailResponse":
    """Restore to Version

    POST /v1/domains/{domain_id}/personas/{persona_id}/versions/{version_number}/restore
    """
    ...


def get_domain_network_v1_domains__domain_id__network_get(
    domain_id: str,
    cluster_by: Optional[str] = None,
    include_isolated: Optional[bool] = None,
    max_nodes: Optional[int] = None,
    as_of: Optional[str] = None,
    filters: Optional[str] = None,
) -> "DomainNetworkResponse":
    """Get Domain Network

    GET /v1/domains/{domain_id}/network
    """
    ...


def generate_persona_ai_v1_domains__domain_id__personas_generate_ai_post(
    domain_id: str,
    body: "AIGenerateRequest",
) -> None:
    """AI-Assisted Persona Generation (SSE)

    POST /v1/domains/{domain_id}/personas/generate-ai
    """
    ...


def refine_persona_ai_v1_domains__domain_id__personas_refine_ai_post(
    domain_id: str,
    body: "AIRefineRequest",
) -> None:
    """Refine AI-Generated Persona (SSE)

    POST /v1/domains/{domain_id}/personas/refine-ai
    """
    ...


def accept_persona_ai_v1_domains__domain_id__personas_accept_ai_post(
    domain_id: str,
    body: "AcceptPersonaRequest",
) -> None:
    """Accept AI-Generated Persona

    POST /v1/domains/{domain_id}/personas/accept-ai
    """
    ...


def get_example_prompts_v1_domains__domain_id__personas_generate_ai_examples_get(
    domain_id: str,
) -> None:
    """Get Example Prompts

    GET /v1/domains/{domain_id}/personas/generate-ai/examples
    """
    ...


def get_api_info_v1_api_info_get(
) -> "APIInfoResponse":
    """Get API Info

    GET /v1/api/info
    """
    ...


def get_memory_stats_v1_memory_stats_get(
) -> "MemoryStatsResponse":
    """Get Memory Statistics

    GET /v1/memory/stats
    """
    ...


def get_memories_v1_memory__persona_id__get(
    persona_id: str,
    limit: Optional[int] = None,
    offset: Optional[int] = None,
) -> "MemoriesResponse":
    """Get Persona Memories

    GET /v1/memory/{persona_id}
    """
    ...


def add_memory_v1_memory__persona_id__post(
    persona_id: str,
    body: "MemoryCreate",
) -> None:
    """Add Memory

    POST /v1/memory/{persona_id}
    """
    ...


def clear_memories_v1_memory__persona_id__delete(
    persona_id: str,
) -> None:
    """Clear Memories

    DELETE /v1/memory/{persona_id}
    """
    ...


def delete_memory_v1_memory__persona_id___memory_id__delete(
    persona_id: str,
    memory_id: str,
) -> None:
    """Delete Single Memory

    DELETE /v1/memory/{persona_id}/{memory_id}
    """
    ...


def record_memory_access_v1_memory__persona_id___memory_id__access_patch(
    persona_id: str,
    memory_id: str,
) -> None:
    """Record Memory Access

    PATCH /v1/memory/{persona_id}/{memory_id}/access
    """
    ...


def add_knowledge_v1_memory__persona_id__knowledge_post(
    persona_id: str,
    body: "KnowledgeCreate",
) -> None:
    """Add Knowledge

    POST /v1/memory/{persona_id}/knowledge
    """
    ...


def get_knowledge_v1_memory__persona_id__knowledge_get(
    persona_id: str,
) -> None:
    """Get Knowledge

    GET /v1/memory/{persona_id}/knowledge
    """
    ...


def generate_persona_memories_v1_memory__persona_id__generate_post(
    persona_id: str,
) -> "MemoryGenerateResponse":
    """Generate Memories

    POST /v1/memory/{persona_id}/generate
    """
    ...


def add_memories_batch_v1_memory__persona_id__batch_post(
    persona_id: str,
) -> None:
    """Add Memories in Batch

    POST /v1/memory/{persona_id}/batch
    """
    ...


def consolidate_memories_v1_memory__persona_id__consolidate_post(
    persona_id: str,
) -> "ConsolidationResponse":
    """Consolidate Memories

    POST /v1/memory/{persona_id}/consolidate
    """
    ...


def get_working_memory_v1_memory__persona_id__working_get(
    persona_id: str,
) -> None:
    """Get Working Memory

    GET /v1/memory/{persona_id}/working
    """
    ...


def generate_batch_memories_v1_domains__domain_id__memories_generate_batch_post(
    domain_id: str,
) -> None:
    """Generate Memories for Multiple Personas

    POST /v1/domains/{domain_id}/memories/generate-batch
    """
    ...


def list_bloom_jobs_v1_domains__domain_id__memories_bloom_jobs_get(
    domain_id: str,
    status_filter: Optional[str] = None,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> None:
    """List Batch Bloom Jobs

    GET /v1/domains/{domain_id}/memories/bloom-jobs
    """
    ...


def get_bloom_job_v1_domains__domain_id__memories_bloom_jobs__job_id__get(
    domain_id: str,
    job_id: str,
) -> "BatchBloomJobResponse":
    """Get Batch Bloom Job

    GET /v1/domains/{domain_id}/memories/bloom-jobs/{job_id}
    """
    ...


def cancel_bloom_job_v1_domains__domain_id__memories_bloom_jobs__job_id__cancel_post(
    domain_id: str,
    job_id: str,
) -> "BatchBloomJobResponse":
    """Cancel Batch Bloom Job

    POST /v1/domains/{domain_id}/memories/bloom-jobs/{job_id}/cancel
    """
    ...


def get_dashboard_metrics_v1_metrics_dashboard_get(
) -> "DashboardMetrics":
    """Get Dashboard Metrics

    GET /v1/metrics/dashboard
    """
    ...


def get_streaming_metrics_v1_metrics_streaming_get(
) -> "StreamingMetrics":
    """Get Streaming Metrics

    GET /v1/metrics/streaming
    """
    ...


def get_sampling_metrics_v1_metrics_sampling_get(
) -> "SamplingMetrics":
    """Get Sampling Metrics

    GET /v1/metrics/sampling
    """
    ...


def get_cache_metrics_v1_metrics_cache_get(
) -> "PromptCacheMetrics":
    """Get Cache Metrics

    GET /v1/metrics/cache
    """
    ...


def get_model_usage_v1_metrics_models_get(
) -> "ModelUsageMetrics":
    """Get Model Usage

    GET /v1/metrics/models
    """
    ...


def run_sampling_simulation_v1_sampling_simulate_post(
    body: "SamplingRequest",
) -> "SamplingResponse":
    """Run Sampling Simulation

    POST /v1/sampling/simulate
    """
    ...


def get_sampling_info_v1_sampling_info_get(
) -> None:
    """Get Sampling Info

    GET /v1/sampling/info
    """
    ...


def get_components_info_v1_components_info_get(
) -> "ComponentsInfoResponse":
    """Get Components Info

    GET /v1/components/info
    """
    ...


def list_bundles_v1_components_bundles_get(
    tag: Optional[str] = None,
    builtin_only: Optional[bool] = None,
) -> "BundleListResponse":
    """List Bundles

    GET /v1/components/bundles
    """
    ...


def get_bundle_v1_components_bundles__name__get(
    name: str,
) -> "ComponentBundle":
    """Get Bundle

    GET /v1/components/bundles/{name}
    """
    ...


def list_tags_v1_components_tags_get(
) -> "TagListResponse":
    """List Tags

    GET /v1/components/tags
    """
    ...


def preview_schema_v1_components_preview_post(
    body: "PreviewRequest",
) -> "PreviewResponse":
    """Preview Composed Schema

    POST /v1/components/preview
    """
    ...


def build_schema_v1_components_build_post(
    body: "BuildRequest",
) -> "BuildResponse":
    """Build Schema

    POST /v1/components/build
    """
    ...


def register_bundle_v1_components_register_post(
    body: "RegisterRequest",
) -> "RegisterResponse":
    """Register Custom Bundle

    POST /v1/components/register
    """
    ...


def get_ppv_info_v1_ppv__domain_name__info_get(
    domain_name: str,
) -> "PPVInfoResponse":
    """Get PPV Info

    GET /v1/ppv/{domain_name}/info
    """
    ...


def encode_personality_v1_ppv__domain_name__encode_post(
    domain_name: str,
    body: "PPVEncodeRequest",
) -> "PPVEncodeResponse":
    """Encode Personality to PPV

    POST /v1/ppv/{domain_name}/encode
    """
    ...


def decode_personality_v1_ppv__domain_name__decode_post(
    domain_name: str,
    body: "PPVDecodeRequest",
) -> "PPVDecodeResponse":
    """Decode PPV to Personality

    POST /v1/ppv/{domain_name}/decode
    """
    ...


def list_validations_v1_validations_get(
    page: Optional[int] = None,
    per_page: Optional[int] = None,
    status: Optional[ValidationStatus] = None,
    model: Optional[str] = None,
    framework: Optional[str] = None,
) -> "ValidationListResponse":
    """List Validation Jobs

    GET /v1/validations
    """
    ...


def create_validation_v1_validations_post(
    body: "ValidationCreateRequest",
) -> "ValidationResponse":
    """Create Validation Job

    POST /v1/validations
    """
    ...


def delete_validations_bulk_v1_validations_delete(
    framework: Optional[str] = None,
    status: Optional[str] = None,
) -> "ValidationDeleteResponse":
    """Bulk Delete Validations

    DELETE /v1/validations
    """
    ...


def get_validation_config_v1_validations_config__framework_slug__get(
    framework_slug: str,
) -> None:
    """Get Validation Config

    GET /v1/validations/config/{framework_slug}
    """
    ...


def compare_validations_v1_validations_compare_get(
    ids: Optional[str] = None,
) -> None:
    """Compare Validations

    GET /v1/validations/compare
    """
    ...


def get_instrument_metadata_v1_validations_instruments__framework_slug__get(
    framework_slug: str,
) -> None:
    """Get Instrument Metadata

    GET /v1/validations/instruments/{framework_slug}
    """
    ...


def get_validation_v1_validations__job_id__get(
    job_id: str,
) -> "ValidationResponse":
    """Get Validation Job

    GET /v1/validations/{job_id}
    """
    ...


def cancel_validation_v1_validations__job_id__cancel_post(
    job_id: str,
) -> "ValidationCancelResponse":
    """Cancel Validation Job

    POST /v1/validations/{job_id}/cancel
    """
    ...


def delete_validation_v1_validations__validation_id__delete(
    validation_id: str,
) -> "ValidationDeleteResponse":
    """Delete Validation

    DELETE /v1/validations/{validation_id}
    """
    ...


def get_raw_data_v1_validations__job_id__raw_data_get(
    job_id: str,
) -> None:
    """Get Raw Validation Data

    GET /v1/validations/{job_id}/raw-data
    """
    ...


def get_tuning_report_v1_validations__job_id__tuning_report_get(
    job_id: str,
) -> None:
    """Get Tuning Report

    GET /v1/validations/{job_id}/tuning-report
    """
    ...


def get_supported_models_v1_validations_supported_models_get(
) -> None:
    """Get Supported Models

    GET /v1/validations/supported/models
    """
    ...


def get_supported_frameworks_v1_validations_supported_frameworks_get(
) -> None:
    """Get Supported Frameworks

    GET /v1/validations/supported/frameworks
    """
    ...


def list_frameworks_v1_frameworks_get(
    page: Optional[int] = None,
    per_page: Optional[int] = None,
    category: Optional[str] = None,
    search: Optional[str] = None,
    builtin: Optional[bool] = None,
) -> "FrameworkListResponse":
    """List Frameworks

    GET /v1/frameworks
    """
    ...


def create_framework_v1_frameworks_post(
    body: "FrameworkCreateRequest",
) -> "FrameworkDetailResponse":
    """Create Framework

    POST /v1/frameworks
    """
    ...


def get_framework_v1_frameworks__framework_id__get(
    framework_id: str,
) -> "FrameworkDetailResponse":
    """Get Framework

    GET /v1/frameworks/{framework_id}
    """
    ...


def update_framework_v1_frameworks__framework_id__patch(
    framework_id: str,
    body: "FrameworkUpdateRequest",
) -> "FrameworkDetailResponse":
    """Update Framework

    PATCH /v1/frameworks/{framework_id}
    """
    ...


def delete_framework_v1_frameworks__framework_id__delete(
    framework_id: str,
) -> None:
    """Delete Framework

    DELETE /v1/frameworks/{framework_id}
    """
    ...


def update_trait_grounding_v1_frameworks__framework_id__traits__trait_name__grounding_patch(
    framework_id: str,
    trait_name: str,
    body: "TraitGroundingUpdateRequest",
) -> "FrameworkDetailResponse":
    """Update Trait Grounding

    PATCH /v1/frameworks/{framework_id}/traits/{trait_name}/grounding
    """
    ...


def get_framework_validations_v1_frameworks__framework_id__validations_get(
    framework_id: str,
) -> "FrameworkValidationsResponse":
    """Get Framework Validations

    GET /v1/frameworks/{framework_id}/validations
    """
    ...


def add_instrument_v1_frameworks__framework_id__instruments_post(
    framework_id: str,
    body: "InstrumentSchema",
) -> "FrameworkDetailResponse":
    """Add Instrument

    POST /v1/frameworks/{framework_id}/instruments
    """
    ...


def remove_instrument_v1_frameworks__framework_id__instruments__instrument_id__delete(
    framework_id: str,
    instrument_id: str,
) -> "FrameworkDetailResponse":
    """Remove Instrument

    DELETE /v1/frameworks/{framework_id}/instruments/{instrument_id}
    """
    ...


def auto_tune_grounding_v1_frameworks__framework_id__auto_tune_post(
    framework_id: str,
    body: "AutoTuneRequest",
) -> "AutoTuneResponse":
    """Auto-Tune Trait Grounding

    POST /v1/frameworks/{framework_id}/auto-tune
    """
    ...


def create_template_v1_templates_post(
    body: "CreateTemplateRequest",
) -> None:
    """Create a persona template

    POST /v1/templates
    """
    ...


def list_templates_v1_templates_get(
    domain_id: Optional[str] = None,
    tags: Optional[str] = None,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> None:
    """List persona templates

    GET /v1/templates
    """
    ...


def get_template_v1_templates__template_id__get(
    template_id: str,
) -> None:
    """Get a template

    GET /v1/templates/{template_id}
    """
    ...


def update_template_v1_templates__template_id__patch(
    template_id: str,
    body: "UpdateTemplateRequest",
) -> None:
    """Update a template

    PATCH /v1/templates/{template_id}
    """
    ...


def delete_template_v1_templates__template_id__delete(
    template_id: str,
) -> None:
    """Delete a template

    DELETE /v1/templates/{template_id}
    """
    ...


def preview_from_template_v1_templates__template_id__preview_post(
    template_id: str,
    body: "CreateFromTemplateRequest",
) -> None:
    """Preview persona from template

    POST /v1/templates/{template_id}/preview
    """
    ...


def save_persona_as_template_v1_templates_from_persona_post(
    body: "SaveAsTemplateRequest",
) -> None:
    """Save persona as template

    POST /v1/templates/from-persona
    """
    ...


def create_simulation_v1_simulations_post(
    body: "SimulationCreate",
) -> "SimulationDetailResponse":
    """Create Simulation

    POST /v1/simulations
    """
    ...


def list_simulations_v1_simulations_get(
    domain_id: Optional[str] = None,
    status: Optional[str] = None,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "SimulationListResponse":
    """List Simulations

    GET /v1/simulations
    """
    ...


def get_simulation_v1_simulations__simulation_id__get(
    simulation_id: str,
) -> "SimulationDetailResponse":
    """Get Simulation

    GET /v1/simulations/{simulation_id}
    """
    ...


def delete_simulation_v1_simulations__simulation_id__delete(
    simulation_id: str,
) -> None:
    """Delete Simulation

    DELETE /v1/simulations/{simulation_id}
    """
    ...


def add_participants_v1_simulations__simulation_id__participants_post(
    simulation_id: str,
    body: "AddParticipantsRequest",
) -> "SimulationDetailResponse":
    """Add Participants

    POST /v1/simulations/{simulation_id}/participants
    """
    ...


def update_config_v1_simulations__simulation_id__config_patch(
    simulation_id: str,
    body: "SimulationConfigUpdate",
) -> "SimulationDetailResponse":
    """Update Simulation Config

    PATCH /v1/simulations/{simulation_id}/config
    """
    ...


def update_visibility_v1_simulations__simulation_id__visibility_patch(
    simulation_id: str,
    body: "VisibilityUpdate",
) -> "SimulationDetailResponse":
    """Update Simulation Visibility

    PATCH /v1/simulations/{simulation_id}/visibility
    """
    ...


def start_simulation_v1_simulations__simulation_id__start_post(
    simulation_id: str,
    body: "StartRequest",
) -> "SimulationDetailResponse":
    """Start/Resume Simulation

    POST /v1/simulations/{simulation_id}/start
    """
    ...


def pause_simulation_v1_simulations__simulation_id__pause_post(
    simulation_id: str,
) -> "SimulationDetailResponse":
    """Pause Simulation

    POST /v1/simulations/{simulation_id}/pause
    """
    ...


def set_speed_v1_simulations__simulation_id__speed_patch(
    simulation_id: str,
    body: "SpeedUpdate",
) -> "SimulationDetailResponse":
    """Set Simulation Speed

    PATCH /v1/simulations/{simulation_id}/speed
    """
    ...


def get_events_v1_simulations__simulation_id__events_get(
    simulation_id: str,
    event_type: Optional[str] = None,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "SimulationEventListResponse":
    """Get Simulation Events

    GET /v1/simulations/{simulation_id}/events
    """
    ...


def broadcast_message_v1_simulations__simulation_id__broadcast_post(
    simulation_id: str,
    body: "BroadcastRequest",
) -> "BroadcastResponse":
    """Broadcast Message

    POST /v1/simulations/{simulation_id}/broadcast
    """
    ...


def get_persona_trait_history_v1_simulations__simulation_id__history__persona_id__get(
    simulation_id: str,
    persona_id: str,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "TraitHistoryResponse":
    """Get Persona Trait History

    GET /v1/simulations/{simulation_id}/history/{persona_id}
    """
    ...


def get_trait_history_v1_simulations__simulation_id__history_get(
    simulation_id: str,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "TraitHistoryResponse":
    """Get Aggregated Trait History

    GET /v1/simulations/{simulation_id}/history
    """
    ...


def create_checkpoint_v1_simulations__simulation_id__checkpoints_post(
    simulation_id: str,
    body: "CheckpointCreate",
) -> "CheckpointResponse":
    """Create Checkpoint

    POST /v1/simulations/{simulation_id}/checkpoints
    """
    ...


def list_checkpoints_v1_simulations__simulation_id__checkpoints_get(
    simulation_id: str,
    page: Optional[int] = None,
    per_page: Optional[int] = None,
) -> "CheckpointListResponse":
    """List Checkpoints

    GET /v1/simulations/{simulation_id}/checkpoints
    """
    ...


def restore_checkpoint_v1_simulations__simulation_id__checkpoints__checkpoint_id__restore_post(
    simulation_id: str,
    checkpoint_id: str,
) -> "CheckpointRestoreResponse":
    """Restore Checkpoint

    POST /v1/simulations/{simulation_id}/checkpoints/{checkpoint_id}/restore
    """
    ...


def compare_checkpoints_v1_simulations__simulation_id__checkpoints_compare_get(
    simulation_id: str,
    a: Optional[str] = None,
    b: Optional[str] = None,
) -> "CheckpointCompareResponse":
    """Compare Checkpoints

    GET /v1/simulations/{simulation_id}/checkpoints/compare
    """
    ...


def delete_checkpoint_v1_simulations__simulation_id__checkpoints__checkpoint_id__delete(
    simulation_id: str,
    checkpoint_id: str,
) -> None:
    """Delete Checkpoint

    DELETE /v1/simulations/{simulation_id}/checkpoints/{checkpoint_id}
    """
    ...


def update_checkpoint_v1_simulations__simulation_id__checkpoints__checkpoint_id__patch(
    simulation_id: str,
    checkpoint_id: str,
    body: "CheckpointUpdate",
) -> "CheckpointResponse":
    """Update Checkpoint

    PATCH /v1/simulations/{simulation_id}/checkpoints/{checkpoint_id}
    """
    ...


def get_simulation_usage_v1_simulations__simulation_id__usage_get(
    simulation_id: str,
) -> "SimulationUsageResponse":
    """Get Simulation Usage

    GET /v1/simulations/{simulation_id}/usage
    """
    ...


def export_simulation_v1_simulations__simulation_id__export_get(
    simulation_id: str,
    format: Optional[str] = None,
) -> None:
    """Export Simulation Data

    GET /v1/simulations/{simulation_id}/export
    """
    ...


def get_network_v1_simulations__simulation_id__network_get(
    simulation_id: str,
    tick: Optional[int] = None,
    max_nodes: Optional[int] = None,
    max_edges: Optional[int] = None,
    cluster_by: Optional[str] = None,
    filters: Optional[str] = None,
) -> "SimNetworkResponse":
    """Get Simulation Network Graph

    GET /v1/simulations/{simulation_id}/network
    """
    ...


def stream_events_v1_simulations__simulation_id__stream_get(
    simulation_id: str,
) -> None:
    """Stream Simulation Events (SSE)

    GET /v1/simulations/{simulation_id}/stream
    """
    ...


def get_drift_report_v1_simulations__simulation_id__personas__persona_id__drift_report_get(
    simulation_id: str,
    persona_id: str,
) -> None:
    """Get Drift Report

    GET /v1/simulations/{simulation_id}/personas/{persona_id}/drift-report
    """
    ...


def get_evaluation_summary_v1_simulations__simulation_id__evaluation_summary_get(
    simulation_id: str,
) -> None:
    """Get Evaluation Summary

    GET /v1/simulations/{simulation_id}/evaluation-summary
    """
    ...


def image_status_v1_images_status_get(
) -> None:
    """Check image generation availability

    GET /v1/images/status
    """
    ...


def generate_avatar_v1_images_generate__persona_id__post(
    persona_id: str,
    style: Optional[str] = None,
) -> None:
    """Generate avatar for a persona

    POST /v1/images/generate/{persona_id}
    """
    ...


def get_avatar_v1_images__persona_id__avatar_get(
    persona_id: str,
) -> None:
    """Serve generated avatar image

    GET /v1/images/{persona_id}/avatar
    """
    ...


