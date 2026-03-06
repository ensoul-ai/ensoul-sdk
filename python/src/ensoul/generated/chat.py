"""
Generated models for chat resource group.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from enum import Enum

class TokenUsage(BaseModel):
    """Token usage statistics."""
    input_tokens: int = Field(..., description="Number of input tokens")
    output_tokens: int = Field(..., description="Number of output tokens")
    total_tokens: int = Field(..., description="Total tokens used")


class ChatRequest(BaseModel):
    """Request to send a chat message to a persona."""
    message: str = Field(..., description="User message to send to the persona")
    conversation_id: Optional[str] = Field(default=None, description="Optional conversation ID to continue existing conversation")
    user_id: Optional[str] = Field(default=None, description="User ID for user-specific memory isolation")
    max_tokens: Optional[int] = Field(default=1024, description="Maximum tokens in response (1-4096)")
    temperature: Optional[float] = Field(default=1.0, description="Sampling temperature (0.0-2.0)")
    include_memories: bool = Field(default=True, description="Whether to include long-term memories in context")
    include_knowledge: bool = Field(default=True, description="Whether to include RAG knowledge in context")


class ChatResponse(BaseModel):
    """Response from chat message."""
    response: str = Field(..., description="Persona's response text")
    conversation_id: str = Field(..., description="Conversation ID for this exchange")
    token_usage: TokenUsage = Field(..., description="Token usage statistics.")
    latency_ms: int = Field(..., description="Response latency in milliseconds")
    model: str = Field(..., description="Model used for generation")
    timestamp: datetime = Field(default=None, description="Response timestamp")


class ConversationMessage(BaseModel):
    """A single message in a conversation."""
    role: str = Field(..., description="Message role (user or assistant)")
    content: str = Field(..., description="Message content")
    timestamp: datetime = Field(..., description="Message timestamp")


class ConversationResponse(BaseModel):
    """Complete conversation history with messages."""
    conversation_id: str = Field(..., description="Conversation ID")
    persona_id: str = Field(..., description="Persona ID")
    messages: List[ConversationMessage] = Field(..., description="List of messages in conversation")
    created_at: datetime = Field(..., description="Conversation creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    message_count: int = Field(..., description="Total number of messages")
    total_tokens: int = Field(default=0, description="Total tokens used in conversation")


class ConversationListItem(BaseModel):
    """Summary item for conversation list."""
    conversation_id: str = Field(..., description="Conversation ID")
    persona_id: str = Field(..., description="Persona ID")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    message_count: int = Field(..., description="Number of messages")
    preview: Optional[str] = Field(default=None, description="Preview of first user message")


class ConversationListResponse(BaseModel):
    """Paginated list of conversations for a persona."""
    items: List[ConversationListItem] = Field(..., description="List of conversations")
    total: int = Field(..., description="Total number of conversations")
    page: int = Field(default=1, description="Current page")
    per_page: int = Field(default=20, description="Items per page")
    pages: int = Field(default=1, description="Total number of pages")
    persona_id: str = Field(..., description="Persona ID")


