"""
Generated enums from OpenAPI spec.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from enum import Enum


class FieldType(str, Enum):
    """Supported field types for personality schema fields."""
    FLOAT = "float"
    INT = "int"
    STR = "str"
    ENUM = "enum"
    BOOL = "bool"

class FilterableFieldType(str, Enum):
    """Supported filter types for persona queries."""
    RANGE = "range"
    SELECT = "select"
    MULTISELECT = "multiselect"

class GenderHandling(str, Enum):
    """How name generation handles gender."""
    NEUTRAL = "neutral"
    SEPARATE = "separate"
    NONE = "none"

class InfluenceType(str, Enum):
    """Types of cross-level influence."""
    GOVERNANCE = "governance"
    MEDIA = "media"
    INSTITUTION = "institution"
    INFLUENCE = "influence"
    ECONOMIC = "economic"

class PersonaExportFormat(str, Enum):
    """Export format options."""
    JSON = "json"
    YAML = "yaml"

class SessionStatus(str, Enum):
    """Session state enumeration."""
    INITIALIZING = "initializing"
    READY = "ready"
    RUNNING = "running"
    WAITING_CHILDREN = "waiting_children"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

class SimulationStatus(str, Enum):
    """Simulation lifecycle status."""
    CREATED = "created"
    RUNNING = "running"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"

class ValidationStatus(str, Enum):
    """Status of a validation job."""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

class AggregateAggregationMode(str, Enum):
    """How to aggregate responses."""
    SUMMARY = "summary"
    VOTE = "vote"
    DISTRIBUTION = "distribution"
    CONSENSUS = "consensus"

class SessionsAggregationMode(str, Enum):
    """How to aggregate child responses."""
    NONE = "none"
    SUMMARY = "summary"
    VOTE = "vote"
    DISTRIBUTION = "distribution"
    CONSENSUS = "consensus"

