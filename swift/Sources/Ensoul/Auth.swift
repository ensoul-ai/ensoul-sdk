/// Authentication strategies for the Ensoul Swift SDK.
import Foundation

// MARK: - Protocol

/// An object that can produce HTTP authentication headers for a request.
public protocol AuthProvider {
    /// Returns the headers required to authenticate a single request.
    func authHeaders() -> [String: String]
}

// MARK: - API key auth

/// Authenticates via the `X-API-Key` request header.
public struct APIKeyAuth: AuthProvider {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func authHeaders() -> [String: String] {
        ["X-API-Key": apiKey]
    }
}

// MARK: - Bearer / JWT auth

/// Authenticates via an `Authorization: Bearer <token>` request header.
///
/// Token state (expiry, refresh need) is tracked here; the actual HTTP
/// refresh call is the responsibility of the HTTP transport layer.
public struct BearerAuth: AuthProvider {
    /// Buffer before `expiresAt` at which `needsRefresh` returns `true`.
    private static let refreshBuffer: TimeInterval = 60

    /// The current access token.
    public var accessToken: String

    /// Refresh token (if provided by the server).
    public var refreshToken: String?

    /// Unix timestamp (seconds since 1970) at which `accessToken` expires,
    /// or `nil` if the expiry is unknown.
    public var expiresAt: Date?

    public init(
        accessToken: String,
        refreshToken: String? = nil,
        expiresAt: Date? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    public func authHeaders() -> [String: String] {
        ["Authorization": "Bearer \(accessToken)"]
    }

    /// `true` if the access token has already passed its expiry timestamp.
    public var isExpired: Bool {
        guard let exp = expiresAt else { return false }
        return Date() >= exp
    }

    /// `true` if the token expires within 60 seconds (or is already expired).
    ///
    /// Callers should proactively refresh when this returns `true`.
    public var needsRefresh: Bool {
        guard let exp = expiresAt else { return false }
        return Date() >= exp.addingTimeInterval(-BearerAuth.refreshBuffer)
    }
}
