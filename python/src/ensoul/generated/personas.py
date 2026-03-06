"""
Generated models for personas resource group.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from enum import Enum

class PersonaCreate(BaseModel):
    """Create persona request.

Domain-agnostic: Requires `domain` and `personality_data`."""
    name: str = Field(..., description="Persona name")
    archetype: Optional[str] = Field(default=None, description="Archetype template ID")
    region: Optional[str] = Field(default=None, description="Geographic region")
    domain: str = Field(..., description="Domain identifier. Required to ensure explicit domain selection. Use the /domains endpoint to list available domains.")
    personality_data: Dict[str, Any] = Field(default=None, description="Domain-specific personality data as a dictionary. Structure depends on the domain's personality schema.")
    age: Optional[int] = Field(default=None, description="Age in years")
    country: Optional[str] = Field(default=None, description="Country")
    city: Optional[str] = Field(default=None, description="City")
    backstory: Optional[str] = Field(default=None, description="Background story")
    core_values: Optional[List[str]] = Field(default=None, description="List of core values")
    communication_style: Optional[Dict[str, Any]] = Field(default=None, description="Communication style parameters")


class PersonaUpdate(BaseModel):
    """Update persona request (partial updates).

Domain-agnostic: Updates flow through personality_data."""
    name: Optional[str] = Field(default=None, description="Persona name")
    personality_data: Optional[Dict[str, Any]] = Field(default=None, description="Domain-specific personality data to update (partial)")
    age: Optional[int] = Field(default=None, description="Age in years")
    country: Optional[str] = Field(default=None, description="Country")
    region: Optional[str] = Field(default=None, description="Region")
    city: Optional[str] = Field(default=None, description="City")
    backstory: Optional[str] = Field(default=None, description="Background story")
    core_values: Optional[List[str]] = Field(default=None, description="List of core values")
    communication_style: Optional[Dict[str, Any]] = Field(default=None, description="Communication style parameters")


class PersonaBatchCreate(BaseModel):
    """Batch create personas request."""
    personas: List[PersonaCreate] = Field(..., description="List of personas to create")
    batch_id: Optional[str] = Field(default=None, description="Optional batch identifier")
    domain: Optional[str] = Field(default=None, description="Default domain for all personas in batch (optional). Each persona must still specify its domain.")


class PersonaResponse(BaseModel):
    """Persona response with core information.

Domain-agnostic: All personality data in personality_data field."""
    id: str = Field(..., description="Unique persona identifier")
    name: str = Field(..., description="Persona name")
    domain: str = Field(..., description="Domain identifier")
    personality_data: Dict[str, Any] = Field(default=None, description="Full personality data in domain-specific format")
    avatar_url: Optional[str] = Field(default=None, description="Avatar image URL")
    archetype: Optional[str] = Field(default=None, description="Archetype template ID")
    age: Optional[int] = Field(default=None, description="Age in years")
    country: Optional[str] = Field(default=None, description="Country")
    region: Optional[str] = Field(default=None, description="Region")
    city: Optional[str] = Field(default=None, description="City")
    batch_id: Optional[str] = Field(default=None, description="Generation batch ID")
    created_at: datetime = Field(..., description="Creation timestamp")


class PersonaListResponse(BaseModel):
    """Paginated list of personas."""
    total: int = Field(..., description="Total number of matching personas")
    items: List[PersonaResponse] = Field(..., description="Persona items for current page")
    page: int = Field(..., description="Current page number")
    per_page: int = Field(..., description="Items per page")
    pages: int = Field(..., description="Total number of pages")


class PersonalityVectorResponse(BaseModel):
    """Full personality vector response.

Domain-agnostic: Returns personality_data in domain-specific format."""
    persona_id: str = Field(..., description="Persona identifier")
    domain: str = Field(..., description="Domain identifier")
    personality_data: Dict[str, Any] = Field(default=None, description="Full personality data in domain-specific format")
    communication_style: Dict[str, Any] = Field(default=None, description="Communication style")
    core_values: List[str] = Field(default=None, description="Core values")


class PersonaBatchResponse(BaseModel):
    """Batch operation response."""
    created: int = Field(..., description="Number of personas created")
    persona_ids: List[str] = Field(..., description="List of created persona IDs")
    batch_id: Optional[str] = Field(default=None, description="Batch identifier")
    domain: Optional[str] = Field(default=None, description="Domain used for batch")


class FilterOption(BaseModel):
    """A filter option with ID, name, and count."""
    id: str = Field(..., description="Filter value ID")
    name: str = Field(..., description="Display name")
    count: int = Field(..., description="Number of personas with this value")


class PersonaFiltersResponse(BaseModel):
    """Available filter options for persona browsing."""
    domains: List[FilterOption] = Field(default=None, description="Available domains")
    regions: List[FilterOption] = Field(default=None, description="Available regions")
    archetypes: List[FilterOption] = Field(default=None, description="Available archetypes/templates")
    countries: List[FilterOption] = Field(default=None, description="Available countries")
    age_ranges: List[FilterOption] = Field(default=None, description="Age range buckets")
    total_personas: int = Field(..., description="Total persona count")


