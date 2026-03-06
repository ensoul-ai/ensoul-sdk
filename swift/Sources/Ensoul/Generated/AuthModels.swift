/// Generated models for the auth resource group.
/// DO NOT EDIT — regenerate with: make sdk-regen
import Foundation

// MARK: - Token exchange

/// JWT token response from the auth server.
public struct TokenResponse: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    /// Seconds until the access token expires.
    public let expiresIn: Int
    public let refreshToken: String?
    public let scope: String?

    public init(
        accessToken: String,
        tokenType: String = "bearer",
        expiresIn: Int,
        refreshToken: String? = nil,
        scope: String? = nil
    ) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.scope = scope
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

/// Request to exchange a refresh token for a new access token.
public struct RefreshTokenRequest: Codable, Sendable {
    public let refreshToken: String
    public let grantType: String

    public init(refreshToken: String, grantType: String = "refresh_token") {
        self.refreshToken = refreshToken
        self.grantType = grantType
    }

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case grantType = "grant_type"
    }
}

// MARK: - API keys

/// Request to create a new API key.
public struct APIKeyRequest: Codable, Sendable {
    /// Human-readable label for the key.
    public let name: String
    /// Days until expiration (1–3650).
    public let expiresDays: Int?
    /// Scopes granted to this key.
    public let scopes: [String]?

    public init(name: String, expiresDays: Int? = 365, scopes: [String]? = nil) {
        self.name = name
        self.expiresDays = expiresDays
        self.scopes = scopes
    }

    enum CodingKeys: String, CodingKey {
        case name
        case expiresDays = "expires_days"
        case scopes
    }
}

/// API key resource (full key only shown once at creation).
public struct APIKeyResponse: Codable, Sendable {
    public let keyId: String
    public let name: String
    /// First 8 characters; used for display / identification.
    public let keyPreview: String
    /// Full key value; present only on the creation response.
    public let fullKey: String?
    public let scopes: [String]?
    public let createdAt: String
    public let expiresAt: String
    public let lastUsedAt: String?
    public let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case keyId = "key_id"
        case name
        case keyPreview = "key_preview"
        case fullKey = "full_key"
        case scopes
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case lastUsedAt = "last_used_at"
        case isActive = "is_active"
    }
}

// MARK: - User info

/// Current authenticated user information.
public struct UserResponse: Codable, Sendable {
    public let consumerId: String
    public let username: String
    public let email: String?
    /// Access tier: `FREE`, `STARTER`, `PRO`, or `ENTERPRISE`.
    public let accessTier: String
    public let permissions: [String]?
    public let createdAt: String
    public let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case consumerId = "consumer_id"
        case username
        case email
        case accessTier = "access_tier"
        case permissions
        case createdAt = "created_at"
        case isActive = "is_active"
    }
}
