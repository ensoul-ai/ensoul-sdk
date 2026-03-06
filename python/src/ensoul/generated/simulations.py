"""
Generated models for simulations resource group.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from enum import Enum

class SimulationStatus(str, Enum):
    """Simulation lifecycle status."""
    CREATED = "created"
    RUNNING = "running"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"


class SchedulerWeights(BaseModel):
    """Weights for the interaction scheduler's pair selection algorithm."""
    recency: float = Field(default=1.0, description="Weight for recency of last interaction")
    affinity: float = Field(default=1.0, description="Weight for connection affinity score")
    diversity: float = Field(default=1.0, description="Weight for demographic diversity")


class SimulationConfig(BaseModel):
    """Configuration embedded in the simulation's config JSONB column."""
    interactions_per_tick: int = Field(default=1, description="Number of interaction pairs per tick")
    turns_per_conversation: int = Field(default=6, description="Number of turns per conversation")
    allow_new_connections: bool = Field(default=True, description="Whether unconnected personas can be paired")
    new_connection_probability: float = Field(default=0.1, description="Probability of pairing unconnected personas")
    group_size_range: List[int] = Field(default=[2, 2], description="Min/max group size for conversations")
    group_formation_probability: float = Field(default=0.0, description="Probability of forming a group (3+) instead of pair")
    scheduler_weights: Optional[SchedulerWeights] = Field(default=None, description="Weights for the interaction scheduler's pair selection algorithm.")
    checkpoint_interval: int = Field(default=0, description="Auto-checkpoint every N ticks (0 = disabled)")
    max_concurrent_conversations: int = Field(default=5, description="Max parallel conversations per tick")
    use_batch_api: bool = Field(default=False, description="Use Anthropic Batch API for large simulations (higher latency, ~50% cost savings)")
    budget_limit: Optional[float] = Field(default=None, description="Budget limit in USD. Simulation auto-pauses when exceeded. None = no limit.")
    reinforcement_interval: int = Field(default=0, description="Re-inject persona traits every N ticks to prevent drift (0 = disabled)")


class SimulationCreate(BaseModel):
    """Request to create a new simulation."""
    name: str = Field(..., description="Simulation name")
    domain_id: str = Field(..., description="Domain ID to simulate within")
    description: Optional[str] = Field(default=None, description="Optional description")
    config: SimulationConfig = Field(default=None, description="Configuration embedded in the simulation's config JSONB column.")
    participant_persona_ids: List[str] = Field(default=None, description="Initial persona IDs to include")


class ParticipantResponse(BaseModel):
    """A persona participant in a simulation."""
    persona_id: str = Field(..., description="Persona identifier")
    joined_at: Optional[datetime] = Field(default=None, description="When participant joined")
    status: Optional[str] = Field(default=None, description="Participant status")


class SimulationSimulationResponse(BaseModel):
    """Summary simulation item for list responses."""
    id: str = Field(..., description="Simulation identifier")
    name: str = Field(..., description="Simulation name")
    domain_id: str = Field(..., description="Domain identifier")
    status: SimulationStatus = Field(..., description="Simulation lifecycle status.")
    current_tick: int = Field(default=0, description="Current tick number")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")


class SimulationDetailResponse(BaseModel):
    """Full simulation detail."""
    id: str = Field(..., description="")
    name: str = Field(..., description="")
    domain_id: str = Field(..., description="")
    team_id: str = Field(..., description="")
    is_public: bool = Field(default=False, description="")
    description: Optional[str] = Field(default=None, description="")
    config: Dict[str, Any] = Field(..., description="")
    status: SimulationStatus = Field(..., description="Simulation lifecycle status.")
    current_tick: int = Field(..., description="")
    simulated_time: float = Field(..., description="")
    time_speed: float = Field(..., description="")
    tick_target: Optional[int] = Field(default=None, description="")
    run_start_tick: Optional[int] = Field(default=None, description="")
    participants: List[ParticipantResponse] = Field(default=[], description="")
    created_at: datetime = Field(..., description="")
    updated_at: datetime = Field(..., description="")


class SimulationListResponse(BaseModel):
    """Paginated list of simulations."""
    items: List[SimulationSimulationResponse] = Field(..., description="")
    total: int = Field(..., description="")
    page: int = Field(..., description="")
    per_page: int = Field(..., description="")
    pages: int = Field(..., description="")


