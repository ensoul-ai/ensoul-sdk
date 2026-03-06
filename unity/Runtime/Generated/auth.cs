// Generated models for the auth resource group.
// DO NOT EDIT — regenerate with: make sdk-regen
using System.Collections.Generic;
using Newtonsoft.Json;

namespace Ensoul
{
    /// <summary>JWT token response.</summary>
    public class TokenResponse
    {
        [JsonProperty("access_token")] public string AccessToken { get; set; } = "";
        [JsonProperty("token_type")] public string TokenType { get; set; } = "bearer";
        [JsonProperty("expires_in")] public int ExpiresIn { get; set; }
        [JsonProperty("refresh_token")] public string? RefreshToken { get; set; }
        [JsonProperty("scope")] public string? Scope { get; set; }
    }

    /// <summary>Refresh token request.</summary>
    public class RefreshTokenRequest
    {
        [JsonProperty("refresh_token")] public string RefreshToken { get; set; } = "";
        [JsonProperty("grant_type")] public string GrantType { get; set; } = "refresh_token";
    }

    /// <summary>Create API key request.</summary>
    public class APIKeyRequest
    {
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("expires_days")] public int? ExpiresDays { get; set; } = 365;
        [JsonProperty("scopes")] public List<string>? Scopes { get; set; }
    }

    /// <summary>API key response (masked for security).</summary>
    public class APIKeyResponse
    {
        [JsonProperty("key_id")] public string KeyId { get; set; } = "";
        [JsonProperty("name")] public string Name { get; set; } = "";
        [JsonProperty("key_preview")] public string KeyPreview { get; set; } = "";
        [JsonProperty("full_key")] public string? FullKey { get; set; }
        [JsonProperty("scopes")] public List<string>? Scopes { get; set; }
        [JsonProperty("created_at")] public string CreatedAt { get; set; } = "";
        [JsonProperty("expires_at")] public string ExpiresAt { get; set; } = "";
        [JsonProperty("last_used_at")] public string? LastUsedAt { get; set; }
        [JsonProperty("is_active")] public bool IsActive { get; set; } = true;
    }

    /// <summary>Current authenticated user information.</summary>
    public class UserResponse
    {
        [JsonProperty("consumer_id")] public string ConsumerId { get; set; } = "";
        [JsonProperty("username")] public string Username { get; set; } = "";
        [JsonProperty("email")] public string? Email { get; set; }
        [JsonProperty("access_tier")] public string AccessTier { get; set; } = "";
        [JsonProperty("permissions")] public List<string>? Permissions { get; set; }
        [JsonProperty("created_at")] public string CreatedAt { get; set; } = "";
        [JsonProperty("is_active")] public bool IsActive { get; set; } = true;
    }
}
