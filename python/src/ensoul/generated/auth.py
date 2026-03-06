"""
Generated models for auth resource group.
DO NOT EDIT — regenerate with: make sdk-regen
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from enum import Enum

class TokenResponse(BaseModel):
    """JWT token response."""
    access_token: str = Field(..., description="JWT access token")
    token_type: str = Field(default='bearer', description="Token type")
    expires_in: int = Field(..., description="Token expiration time in seconds")
    refresh_token: Optional[str] = Field(default=None, description="Optional refresh token")
    scope: Optional[str] = Field(default=None, description="Granted scope")


class RefreshTokenRequest(BaseModel):
    """Refresh token request."""
    refresh_token: str = Field(..., description="Refresh token to exchange")
    grant_type: str = Field(default='refresh_token', description="OAuth2 grant type")


class APIKeyRequest(BaseModel):
    """Create API key request."""
    name: str = Field(..., description="Human-readable name for the API key")
    expires_days: Optional[int] = Field(default=365, description="Days until expiration (1-3650)")
    scopes: List[str] = Field(default=None, description="Scopes granted to this API key")


class APIKeyResponse(BaseModel):
    """API key response (masked for security)."""
    key_id: str = Field(..., description="Unique key identifier")
    name: str = Field(..., description="Human-readable name")
    key_preview: str = Field(..., description="First 8 characters of key")
    full_key: Optional[str] = Field(default=None, description="Full API key (only shown once at creation)")
    scopes: List[str] = Field(default=None, description="Granted scopes")
    created_at: datetime = Field(..., description="Creation timestamp")
    expires_at: datetime = Field(..., description="Expiration timestamp")
    last_used_at: Optional[datetime] = Field(default=None, description="Last usage timestamp")
    is_active: bool = Field(default=True, description="Whether key is active")


class UserResponse(BaseModel):
    """Current authenticated user information."""
    consumer_id: str = Field(..., description="Unique consumer/user identifier")
    username: str = Field(..., description="Username")
    email: Optional[str] = Field(default=None, description="Email address")
    access_tier: str = Field(..., description="Access tier (FREE, STARTER, PRO, ENTERPRISE)")
    permissions: List[str] = Field(default=None, description="List of granted permissions")
    created_at: datetime = Field(..., description="Account creation timestamp")
    is_active: bool = Field(default=True, description="Whether account is active")


