/// Auth resource for the Ensoul Swift SDK.
///
/// Named `AuthResource` (not `Auth`) to avoid a naming conflict with the
/// transport-layer `Auth.swift` module.
///
/// Wraps token exchange, user introspection, and API key management endpoints.
///
/// Example — OAuth2 password flow:
/// ```swift
/// let tokens = try await client.auth.token(username: "alice", password: "s3cr3t")
/// // tokens.accessToken is now available
/// ```
///
/// Example — create an API key:
/// ```swift
/// let key = try await client.auth.createAPIKey(name: "CI bot", expiresDays: 90)
/// print(key.fullKey ?? "Key already shown once.")
/// ```
import Foundation

// MARK: - AuthResource

@available(iOS 15.0, macOS 12.0, *)
public class AuthResource {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Token (OAuth2 password flow)

    /// POST /v1/auth/token
    ///
    /// Exchanges username + password for a JWT token pair using the OAuth2
    /// resource-owner password grant.
    ///
    /// - Important: This endpoint requires `application/x-www-form-urlencoded`
    ///   encoding, not JSON. The SDK handles this automatically via `postForm`.
    public func token(username: String, password: String) async throws -> TokenResponse {
        let (data, _) = try await client.postForm(
            "/v1/auth/token",
            formData: [
                "username": username,
                "password": password,
                "grant_type": "password",
            ]
        )
        let decoder = JSONDecoder()
        return try decoder.decode(TokenResponse.self, from: data)
    }

    // MARK: - Refresh

    /// POST /v1/auth/refresh
    ///
    /// Exchanges a refresh token for a new JWT token pair.
    public func refresh(refreshToken: String) async throws -> TokenResponse {
        let body: [String: Any] = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token",
        ]
        let (data, _) = try await client.post("/v1/auth/refresh", body: body)
        let decoder = JSONDecoder()
        return try decoder.decode(TokenResponse.self, from: data)
    }

    // MARK: - Me

    /// GET /v1/auth/me
    ///
    /// Returns information about the currently authenticated user / API key.
    public func me() async throws -> UserResponse {
        let (data, _) = try await client.get("/v1/auth/me")
        let decoder = JSONDecoder()
        return try decoder.decode(UserResponse.self, from: data)
    }

    // MARK: - Create API Key

    /// POST /v1/api-keys
    ///
    /// Creates a new API key for the authenticated account.
    /// The `fullKey` field in the response is only populated at creation time.
    public func createAPIKey(
        name: String,
        expiresDays: Int = 365,
        scopes: [String]? = nil
    ) async throws -> APIKeyResponse {
        var body: [String: Any] = [
            "name": name,
            "expires_days": expiresDays,
        ]
        if let scopes { body["scopes"] = scopes }

        let (data, _) = try await client.post("/v1/api-keys", body: body)
        let decoder = JSONDecoder()
        return try decoder.decode(APIKeyResponse.self, from: data)
    }

    // MARK: - List API Keys

    /// GET /v1/api-keys
    ///
    /// Returns all API keys for the authenticated account.
    public func listAPIKeys() async throws -> [APIKeyResponse] {
        let (data, _) = try await client.get("/v1/api-keys")
        let decoder = JSONDecoder()

        // The server may return a bare array or a wrapped `{ "items": [...] }` object.
        if let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return try array.map { item in
                let itemData = try JSONSerialization.data(withJSONObject: item)
                return try decoder.decode(APIKeyResponse.self, from: itemData)
            }
        }
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let items = dict["items"] as? [[String: Any]] {
            return try items.map { item in
                let itemData = try JSONSerialization.data(withJSONObject: item)
                return try decoder.decode(APIKeyResponse.self, from: itemData)
            }
        }
        // Fall back to treating the whole body as a JSON array via Codable
        return try decoder.decode([APIKeyResponse].self, from: data)
    }

    // MARK: - Revoke API Key

    /// DELETE /v1/api-keys/{keyId}
    ///
    /// Permanently revokes an API key. This action cannot be undone.
    public func revokeAPIKey(_ keyId: String) async throws {
        _ = try await client.delete("/v1/api-keys/\(keyId)")
    }
}
