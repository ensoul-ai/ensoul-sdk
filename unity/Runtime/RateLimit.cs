using System;
using System.Collections.Generic;
using System.Linq;

namespace Ensoul
{
    /// <summary>
    /// Parsed rate limit state from API response headers.
    /// </summary>
    public class RateLimitInfo
    {
        public int Limit { get; }
        public int Remaining { get; }
        public double Reset { get; }       // Unix timestamp when the window resets
        public double? RetryAfter { get; } // Seconds to wait, only on 429

        public RateLimitInfo(int limit, int remaining, double reset, double? retryAfter = null)
        {
            Limit = limit;
            Remaining = remaining;
            Reset = reset;
            RetryAfter = retryAfter;
        }

        /// <summary>
        /// Parse rate limit headers from response headers.
        /// Returns null if the required headers are not present.
        /// </summary>
        public static RateLimitInfo? FromHeaders(IDictionary<string, IEnumerable<string>> headers)
        {
            string? GetHeader(string name)
            {
                if (headers.TryGetValue(name, out var values))
                    return values.FirstOrDefault();
                if (headers.TryGetValue(name.ToLowerInvariant(), out var lowerValues))
                    return lowerValues.FirstOrDefault();
                return null;
            }

            var limitRaw = GetHeader("X-RateLimit-Limit");
            var remainingRaw = GetHeader("X-RateLimit-Remaining");
            var resetRaw = GetHeader("X-RateLimit-Reset");

            if (limitRaw == null || remainingRaw == null || resetRaw == null)
                return null;

            if (!int.TryParse(limitRaw, out var limit)) return null;
            if (!int.TryParse(remainingRaw, out var remaining)) return null;
            if (!double.TryParse(resetRaw, out var reset)) return null;

            var retryAfterRaw = GetHeader("Retry-After");
            double? retryAfter = null;
            if (retryAfterRaw != null && double.TryParse(retryAfterRaw, out var ra))
                retryAfter = ra;

            return new RateLimitInfo(limit, remaining, reset, retryAfter);
        }
    }

    /// <summary>
    /// Tracks rate limit state across requests.
    /// </summary>
    public class RateLimitTracker
    {
        private RateLimitInfo? _info;

        /// <summary>Update tracked state from a response's rate limit headers.</summary>
        public void Update(IDictionary<string, IEnumerable<string>> headers)
        {
            var parsed = RateLimitInfo.FromHeaders(headers);
            if (parsed != null)
                _info = parsed;
        }

        /// <summary>
        /// Returns (shouldWait, secondsToWait).
        /// Returns true if remaining == 0 and the reset timestamp is in the future.
        /// </summary>
        public (bool ShouldWait, double Seconds) ShouldWait()
        {
            if (_info == null) return (false, 0.0);
            if (_info.Remaining > 0) return (false, 0.0);

            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000.0;
            var secondsUntilReset = _info.Reset - now;
            if (secondsUntilReset <= 0.0) return (false, 0.0);

            return (true, secondsUntilReset);
        }
    }
}
