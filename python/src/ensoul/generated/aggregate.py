"""
Generated models for aggregate resource group.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from enum import Enum

class SimulationRequest(BaseModel):
    """Request to run a scenario simulation."""
    scenario: str = Field(..., description="Scenario description")
    target_cohort: Dict[str, Any] = Field(default=None, description="Target cohort filters (region, archetype, demographics)")
    duration_days: int = Field(default=30, description="Simulation duration in days")
    parameters: Dict[str, Any] = Field(default=None, description="Additional simulation parameters")


class InfluenceQueryResponse(BaseModel):
    """Response from influence tracing."""
    persona_id: str = Field(..., description="Starting persona ID")
    influence_type: Optional[str] = Field(default=None, description="Influence type filter used")
    direction: str = Field(..., description="Direction traced")
    max_depth: int = Field(..., description="Maximum depth traced")
    paths: List[InfluencePath] = Field(default=None, description="Found influence paths")
    influenced_personas: List[str] = Field(default=None, description="List of persona IDs influenced")
    total_paths: int = Field(..., description="Total number of paths found")
    strongest_path: Optional[InfluencePath] = Field(default=None, description="Path with highest total weight")
    network_metrics: Optional[Dict[str, Any]] = Field(default=None, description="Network analysis metrics")
    timestamp: datetime = Field(default=None, description="Query timestamp")


class StreamingQueryRequest(BaseModel):
    """Request for streaming aggregate query with progressive results.

Sprint 21: Streaming Aggregation (5s time-to-first-result)
Sprint 42: Added aggregation_mode for synthesis support"""
    query: str = Field(..., description="The question to ask across personas")
    filters: Dict[str, Any] = Field(default=None, description="Filters for persona selection (region, archetype, demographics)")
    aggregation_mode: AggregateAggregationMode = Field(default=None, description="How to aggregate responses.")
    target_confidence: float = Field(default=0.95, description="Target confidence level for early termination (0.80-0.99)")
    min_samples: int = Field(default=100, description="Minimum samples before allowing early termination")
    max_samples: Optional[int] = Field(default=None, description="Maximum samples to collect (None for unlimited)")
    ci_width_threshold: float = Field(default=0.05, description="Maximum confidence interval width for early termination")
    privacy_budget: float = Field(default=1.0, description="Epsilon for differential privacy")


