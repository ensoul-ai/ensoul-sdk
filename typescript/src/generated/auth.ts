/**
 * Generated models for auth resource group.
 * DO NOT EDIT — regenerate with: make sdk-regen
 */

/** JWT token response. */
export interface TokenResponse {
  /** JWT access token */
  access_token: string;
  /** Token type */
  token_type?: string;
  /** Token expiration time in seconds */
  expires_in: number;
  /** Optional refresh token */
  refresh_token?: string | null;
  /** Granted scope */
  scope?: string | null;
}

/** Refresh token request. */
export interface RefreshTokenRequest {
  /** Refresh token to exchange */
  refresh_token: string;
  /** OAuth2 grant type */
  grant_type?: string;
}

/** Create API key request. */
export interface APIKeyRequest {
  /** Human-readable name for the API key */
  name: string;
  /** Days until expiration (1-3650) */
  expires_days?: number | null;
  /** Scopes granted to this API key */
  scopes?: string[];
}

/** API key response (masked for security). */
export interface APIKeyResponse {
  /** Unique key identifier */
  key_id: string;
  /** Human-readable name */
  name: string;
  /** First 8 characters of key */
  key_preview: string;
  /** Full API key (only shown once at creation) */
  full_key?: string | null;
  /** Granted scopes */
  scopes?: string[];
  /** Creation timestamp */
  created_at: string;
  /** Expiration timestamp */
  expires_at: string;
  /** Last usage timestamp */
  last_used_at?: string | null;
  /** Whether key is active */
  is_active?: boolean;
}

/** Current authenticated user information. */
export interface UserResponse {
  /** Unique consumer/user identifier */
  consumer_id: string;
  /** Username */
  username: string;
  /** Email address */
  email?: string | null;
  /** Access tier (FREE, STARTER, PRO, ENTERPRISE) */
  access_tier: string;
  /** List of granted permissions */
  permissions?: string[];
  /** Account creation timestamp */
  created_at: string;
  /** Whether account is active */
  is_active?: boolean;
}

