/// Rate limit tracking for the Ensoul Swift SDK.
import Foundation

// MARK: - RateLimitInfo

/// Parsed rate limit state extracted from API response headers.
public struct RateLimitInfo {
    /// Maximum requests allowed in the current window.
    public let limit: Int
    /// Requests remaining in the current window.
    public let remaining: Int
    /// When the rate-limit window resets.
    public let reset: Date
    /// Seconds to wait before retrying; populated only on 429 responses.
    public let retryAfter: TimeInterval?

    // MARK: Factory

    /// Parse `X-RateLimit-*` headers from an HTTP response.
    ///
    /// Returns `nil` if any of the three required headers are absent or unparseable.
    public static func from(response: HTTPURLResponse) -> RateLimitInfo? {
        guard
            let limitRaw     = response.value(forHTTPHeaderField: "X-RateLimit-Limit"),
            let remainingRaw = response.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
            let resetRaw     = response.value(forHTTPHeaderField: "X-RateLimit-Reset"),
            let limit        = Int(limitRaw),
            let remaining    = Int(remainingRaw),
            let resetTs      = TimeInterval(resetRaw)
        else {
            return nil
        }

        var retryAfter: TimeInterval? = nil
        if let raw = response.value(forHTTPHeaderField: "Retry-After"),
           let secs = TimeInterval(raw) {
            retryAfter = secs
        }

        return RateLimitInfo(
            limit: limit,
            remaining: remaining,
            reset: Date(timeIntervalSince1970: resetTs),
            retryAfter: retryAfter
        )
    }
}

// MARK: - RateLimitTracker

/// Tracks the most recent rate limit state across successive API responses.
public final class RateLimitTracker {
    private var _info: RateLimitInfo?

    /// The last known rate limit info, or `nil` before the first response arrives.
    public var info: RateLimitInfo? { _info }

    public init() {}

    /// Update tracked state from the rate limit headers in `response`.
    public func update(response: HTTPURLResponse) {
        if let parsed = RateLimitInfo.from(response: response) {
            _info = parsed
        }
    }

    /// Returns whether the caller should pause, and for how long.
    ///
    /// - Returns: `(wait: true, seconds: N)` only when `remaining == 0` and
    ///   the reset time is still in the future.
    public func shouldWait() -> (wait: Bool, seconds: TimeInterval) {
        guard let info = _info else { return (false, 0) }
        guard info.remaining == 0 else { return (false, 0) }
        let secs = info.reset.timeIntervalSinceNow
        if secs <= 0 { return (false, 0) }
        return (true, secs)
    }
}
