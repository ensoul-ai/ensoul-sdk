"""
Generated models for sessions resource group.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from enum import Enum

class SessionStatus(str, Enum):
    """Session state enumeration."""
    INITIALIZING = "initializing"
    READY = "ready"
    RUNNING = "running"
    WAITING_CHILDREN = "waiting_children"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class SessionCreate(BaseModel):
    """Request to create a new session."""
    tier: int = Field(..., description="Session tier level (0-4)")
    parent_session_id: Optional[str] = Field(default=None, description="Parent session ID for hierarchical sessions")
    system_instructions: Optional[str] = Field(default=None, description="Custom system instructions for the session")
    trait_modifiers: Optional[Dict[str, Any]] = Field(default=None, description="OCEAN trait modifiers from baseline")
    core_values: Optional[List[str]] = Field(default=None, description="Core values for the session context")
    communication_style: Optional[Dict[str, Any]] = Field(default=None, description="Communication style parameters")
    metadata: Optional[Dict[str, Any]] = Field(default=None, description="Additional metadata")


class AggregateChildrenRequest(BaseModel):
    """Request to aggregate responses from child sessions."""
    aggregation_mode: SessionsAggregationMode = Field(default=None, description="How to aggregate child responses.")
    filters: Optional[Dict[str, Any]] = Field(default=None, description="Optional filters for selecting children")
    timeout_ms: Optional[int] = Field(default=None, description="Timeout in milliseconds (1s - 5min)")


class AggregateChildrenResponse(BaseModel):
    """Response from aggregating child sessions."""
    session_id: str = Field(..., description="Parent session ID")
    aggregation_mode: SessionsAggregationMode = Field(..., description="How to aggregate child responses.")
    child_count: int = Field(..., description="Number of child responses")
    is_complete: bool = Field(..., description="Whether all children responded")
    is_partial: bool = Field(..., description="Whether result is partial")
    aggregated_content: Dict[str, Any] = Field(default=None, description="Aggregated content based on mode")
    child_responses: List[Dict[str, Any]] = Field(default=None, description="Raw child responses")
    total_tokens: int = Field(default=0, description="Total tokens used across children")
    total_time_ms: int = Field(default=0, description="Total time across children")
    missing_count: int = Field(default=0, description="Number of missing responses")
    timestamp: datetime = Field(default=None, description="Aggregation timestamp")


