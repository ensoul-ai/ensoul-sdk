"""
Generated models for domains resource group.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from enum import Enum

class FieldType(str, Enum):
    """Supported field types for personality schema fields."""
    FLOAT = "float"
    INT = "int"
    STR = "str"
    ENUM = "enum"
    BOOL = "bool"


class GenderHandling(str, Enum):
    """How name generation handles gender."""
    NEUTRAL = "neutral"
    SEPARATE = "separate"
    NONE = "none"


class FieldDefinitionCreate(BaseModel):
    """Schema for creating a personality field.

Matches the FieldDefinition dataclass in protocols.py."""
    path: str = Field(..., description="Dot-notation path (e.g., 'traits.courage', 'big_five.openness')")
    field_type: FieldType = Field(..., description="Supported field types for personality schema fields.")
    range_min: Optional[float] = Field(default=None, description="Minimum value for numeric fields")
    range_max: Optional[float] = Field(default=None, description="Maximum value for numeric fields")
    default: Optional[Dict[str, Any]] = Field(default=None, description="Default value")
    required: bool = Field(default=True, description="Whether this field is required")
    heritability: float = Field(default=0.5, description="Trait heritability for inheritance (0=random, 1=pure)")
    description: str = Field(default='', description="Human-readable description")
    enum_values: Optional[List[str]] = Field(default=None, description="Valid values for enum type fields")


class DomainConfigUpdate(BaseModel):
    """Partial update for domain configuration."""
    display_name: Optional[str] = Field(default=None, description="")
    version: Optional[str] = Field(default=None, description="")
    description: Optional[str] = Field(default=None, description="")
    tiers: Optional[List[TierDefinitionCreate]] = Field(default=None, description="")
    personality_schema: Optional[PersonalitySchemaCreate_Input] = Field(default=None, description="")
    archetypes: Optional[List[ArchetypeCreate]] = Field(default=None, description="")
    name_patterns: Optional[List[NamePatternCreate]] = Field(default=None, description="")
    memory_templates: Optional[List[MemoryTemplateCreate]] = Field(default=None, description="")
    filterable_fields: Optional[List[FilterableField]] = Field(default=None, description="")
    is_draft: Optional[bool] = Field(default=None, description="")
    is_public: Optional[bool] = Field(default=None, description="")
    tags: Optional[List[str]] = Field(default=None, description="")
    frameworks: Optional[List[str]] = Field(default=None, description="")
    tier_values: Optional[List[TierValuesConfig]] = Field(default=None, description="")
    image_generation: Optional[ImageGenerationConfig] = Field(default=None, description="Image generation settings for persona avatars")


class DomainListResponse(BaseModel):
    """Paginated list of domains."""
    total: int = Field(..., description="Total number of domains")
    items: List[DomainResponse] = Field(..., description="Domain items")
    page: int = Field(..., description="Current page number")
    per_page: int = Field(..., description="Items per page")
    pages: int = Field(..., description="Total number of pages")


