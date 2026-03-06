"""Ensoul SDK for Python."""

from __future__ import annotations

from ensoul.client import AsyncEnsoul, Ensoul
from ensoul.config import ClientConfig
from ensoul.errors import (
    APIError,
    AuthenticationError,
    AuthorizationError,
    ConflictError,
    EnsoulError,
    NotFoundError,
    RateLimitError,
    ServerError,
    ValidationError,
)
from ensoul.generated.auth import APIKeyResponse, TokenResponse, UserResponse
from ensoul.generated.chat import ChatRequest, ChatResponse, ConversationResponse
from ensoul.generated.enums import SessionStatus, SimulationStatus
from ensoul.generated.personas import (
    PersonaBatchCreate,
    PersonaBatchResponse,
    PersonaCreate,
    PersonaResponse,
    PersonalityVectorResponse,
)

__version__ = "0.1.0"

__all__ = [
    "Ensoul",
    "AsyncEnsoul",
    "ClientConfig",
    # Errors
    "EnsoulError",
    "APIError",
    "AuthenticationError",
    "AuthorizationError",
    "NotFoundError",
    "RateLimitError",
    "ValidationError",
    "ConflictError",
    "ServerError",
    # Types
    "PersonaCreate",
    "PersonaResponse",
    "PersonaBatchCreate",
    "PersonaBatchResponse",
    "PersonalityVectorResponse",
    "ChatRequest",
    "ChatResponse",
    "ConversationResponse",
    "TokenResponse",
    "APIKeyResponse",
    "UserResponse",
    "SimulationStatus",
    "SessionStatus",
    "__version__",
]
