/**
 * Generated models for chat resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

/** Request to send a chat message to a persona. */
export interface ChatRequest {
  /** User message to send to the persona */
  message: string;
  /** Optional conversation ID to continue existing conversation */
  conversation_id?: string | null;
  /** User ID for user-specific memory isolation */
  user_id?: string | null;
  /** Maximum tokens in response (1-4096) */
  max_tokens?: number | null;
  /** Sampling temperature (0.0-2.0) */
  temperature?: number | null;
  /** Whether to include long-term memories in context */
  include_memories?: boolean;
  /** Whether to include RAG knowledge in context */
  include_knowledge?: boolean;
}

/** Response from chat message. */
export interface ChatResponse {
  /** Persona's response text */
  response: string;
  /** Conversation ID for this exchange */
  conversation_id: string;
  /** Token usage statistics. */
  token_usage: TokenUsage;
  /** Response latency in milliseconds */
  latency_ms: number;
  /** Model used for generation */
  model: string;
  /** Response timestamp */
  timestamp?: string;
}

/** Token usage statistics. */
export interface TokenUsage {
  /** Number of input tokens */
  input_tokens: number;
  /** Number of output tokens */
  output_tokens: number;
  /** Total tokens used */
  total_tokens: number;
}

/** A single message in a conversation. */
export interface ConversationMessage {
  /** Message role (user or assistant) */
  role: string;
  /** Message content */
  content: string;
  /** Message timestamp */
  timestamp: string;
}

/** Complete conversation history with messages. */
export interface ConversationResponse {
  /** Conversation ID */
  conversation_id: string;
  /** Persona ID */
  persona_id: string;
  /** List of messages in conversation */
  messages: ConversationMessage[];
  /** Conversation creation timestamp */
  created_at: string;
  /** Last update timestamp */
  updated_at: string;
  /** Total number of messages */
  message_count: number;
  /** Total tokens used in conversation */
  total_tokens?: number;
}

/** Summary item for conversation list. */
export interface ConversationListItem {
  /** Conversation ID */
  conversation_id: string;
  /** Persona ID */
  persona_id: string;
  /** Creation timestamp */
  created_at: string;
  /** Last update timestamp */
  updated_at: string;
  /** Number of messages */
  message_count: number;
  /** Preview of first user message */
  preview?: string | null;
}

/** Paginated list of conversations for a persona. */
export interface ConversationListResponse {
  /** List of conversations */
  items: ConversationListItem[];
  /** Total number of conversations */
  total: number;
  /** Current page */
  page?: number;
  /** Items per page */
  per_page?: number;
  /** Total number of pages */
  pages?: number;
  /** Persona ID */
  persona_id: string;
}

