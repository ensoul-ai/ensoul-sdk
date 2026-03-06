/// Error hierarchy for the Ensoul Swift SDK.
///
/// Users can catch specific error types:
/// ```swift
/// do {
///     let result = try await client.personas.get(id: "abc")
/// } catch let err as RateLimitError {
///     print("Rate limited, retry after \(err.retryAfter)s")
/// } catch let err as AuthenticationError {
///     print("Auth failed: \(err.message)")
/// } catch let err as EnsoulAPIError {
///     print("API error \(err.statusCode): \(err.message)")
/// }
/// ```
import Foundation

// MARK: - Base protocol

/// Base protocol for all Ensoul SDK errors.
public protocol EnsoulError: Error, LocalizedError {
    var message: String { get }
}

// MARK: - Supporting types

/// A single field-level validation detail.
public struct ErrorDetail: Sendable {
    public let field: String
    public let message: String
    public let type: String

    public init(field: String, message: String, type: String) {
        self.field = field
        self.message = message
        self.type = type
    }
}

// MARK: - API error base

/// An error returned by the Ensoul API (4xx / 5xx response).
public class EnsoulAPIError: EnsoulError {
    public let statusCode: Int
    public let error: String
    public let message: String
    public let requestId: String?

    public init(
        statusCode: Int,
        error: String,
        message: String,
        requestId: String? = nil
    ) {
        self.statusCode = statusCode
        self.error = error
        self.message = message
        self.requestId = requestId
    }

    public var errorDescription: String? {
        "[\(statusCode)] \(error): \(message)"
    }
}

// MARK: - Specific error types

/// HTTP 401 — authentication failed or token missing / expired.
public final class AuthenticationError: EnsoulAPIError {}

/// HTTP 403 — authenticated but not permitted.
public final class AuthorizationError: EnsoulAPIError {
    public let requiredTier: String?
    public let currentTier: String?

    public init(
        statusCode: Int,
        error: String,
        message: String,
        requestId: String? = nil,
        requiredTier: String? = nil,
        currentTier: String? = nil
    ) {
        self.requiredTier = requiredTier
        self.currentTier = currentTier
        super.init(statusCode: statusCode, error: error, message: message, requestId: requestId)
    }
}

/// HTTP 404 — requested resource does not exist.
public final class NotFoundError: EnsoulAPIError {
    public let resourceType: String?
    public let resourceId: String?

    public init(
        statusCode: Int,
        error: String,
        message: String,
        requestId: String? = nil,
        resourceType: String? = nil,
        resourceId: String? = nil
    ) {
        self.resourceType = resourceType
        self.resourceId = resourceId
        super.init(statusCode: statusCode, error: error, message: message, requestId: requestId)
    }
}

/// HTTP 429 — too many requests.
public final class RateLimitError: EnsoulAPIError {
    /// Seconds to wait before retrying.
    public let retryAfter: TimeInterval

    public init(
        statusCode: Int,
        error: String,
        message: String,
        requestId: String? = nil,
        retryAfter: TimeInterval = 0
    ) {
        self.retryAfter = retryAfter
        super.init(statusCode: statusCode, error: error, message: message, requestId: requestId)
    }
}

/// HTTP 422 — request body failed validation.
public final class ValidationError: EnsoulAPIError {
    public let details: [ErrorDetail]

    public init(
        statusCode: Int,
        error: String,
        message: String,
        requestId: String? = nil,
        details: [ErrorDetail] = []
    ) {
        self.details = details
        super.init(statusCode: statusCode, error: error, message: message, requestId: requestId)
    }
}

/// HTTP 409 — resource already exists or state conflict.
public final class ConflictError: EnsoulAPIError {}

/// HTTP 500 / 503 — server-side failure.
public final class ServerError: EnsoulAPIError {}

// MARK: - Status dispatcher

/// Parse a JSON error body and raise the appropriate SDK error type.
///
/// - Parameters:
///   - data: Raw response body bytes.
///   - response: The HTTP response whose status code drives the error type.
/// - Throws: An `EnsoulAPIError` subclass when `statusCode >= 400`.
public func raiseForStatus(data: Data, response: HTTPURLResponse) throws {
    let status = response.statusCode
    guard status >= 400 else { return }

    // Attempt to decode the standard API error envelope.
    var errorCode = "Unknown Error"
    var message = HTTPURLResponse.localizedString(forStatusCode: status)
    var requestId: String? = nil

    if let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        if let e = body["error"] as? String { errorCode = e }
        if let m = body["message"] as? String { message = m }
        requestId = body["request_id"] as? String
    }

    switch status {
    case 401:
        throw AuthenticationError(
            statusCode: status, error: errorCode, message: message, requestId: requestId
        )

    case 403:
        throw AuthorizationError(
            statusCode: status, error: errorCode, message: message, requestId: requestId
        )

    case 404:
        throw NotFoundError(
            statusCode: status, error: errorCode, message: message, requestId: requestId
        )

    case 409:
        throw ConflictError(
            statusCode: status, error: errorCode, message: message, requestId: requestId
        )

    case 422:
        var details: [ErrorDetail] = []
        if let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let rawDetails = body["details"] as? [[String: Any]] {
            details = rawDetails.compactMap { d in
                guard let field = d["field"] as? String,
                      let msg = d["message"] as? String,
                      let type_ = d["type"] as? String else { return nil }
                return ErrorDetail(field: field, message: msg, type: type_)
            }
        }
        throw ValidationError(
            statusCode: status, error: errorCode, message: message, requestId: requestId, details: details
        )

    case 429:
        var retryAfter: TimeInterval = 0
        if let raw = response.value(forHTTPHeaderField: "Retry-After"),
           let seconds = TimeInterval(raw) {
            retryAfter = seconds
        }
        throw RateLimitError(
            statusCode: status, error: errorCode, message: message, requestId: requestId, retryAfter: retryAfter
        )

    case 500, 503:
        throw ServerError(
            statusCode: status, error: errorCode, message: message, requestId: requestId
        )

    default:
        throw EnsoulAPIError(
            statusCode: status, error: errorCode, message: message, requestId: requestId
        )
    }
}
