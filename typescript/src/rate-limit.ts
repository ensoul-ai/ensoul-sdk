/**
 * Rate limit tracking for the Ensoul TypeScript SDK.
 */

export interface RateLimitInfo {
  limit: number;
  remaining: number;
  reset: number; // Unix timestamp
  retryAfter?: number; // seconds
}

export function parseRateLimitHeaders(
  headers: Headers,
): RateLimitInfo | undefined {
  const limitRaw = headers.get("X-RateLimit-Limit");
  const remainingRaw = headers.get("X-RateLimit-Remaining");
  const resetRaw = headers.get("X-RateLimit-Reset");

  if (limitRaw == null || remainingRaw == null || resetRaw == null) {
    return undefined;
  }

  const limit = parseInt(limitRaw, 10);
  const remaining = parseInt(remainingRaw, 10);
  const reset = parseFloat(resetRaw);

  if (isNaN(limit) || isNaN(remaining) || isNaN(reset)) {
    return undefined;
  }

  let retryAfter: number | undefined;
  const retryAfterRaw = headers.get("Retry-After");
  if (retryAfterRaw != null) {
    const parsed = parseFloat(retryAfterRaw);
    if (!isNaN(parsed)) retryAfter = parsed;
  }

  return { limit, remaining, reset, retryAfter };
}

export class RateLimitTracker {
  private _info: RateLimitInfo | undefined;

  get info(): RateLimitInfo | undefined {
    return this._info;
  }

  update(headers: Headers): void {
    const info = parseRateLimitHeaders(headers);
    if (info != null) {
      this._info = info;
    }
  }

  shouldWait(): { wait: boolean; seconds: number } {
    if (this._info == null) return { wait: false, seconds: 0 };
    if (this._info.remaining > 0) return { wait: false, seconds: 0 };

    const now = Date.now() / 1000;
    const secondsUntilReset = this._info.reset - now;
    if (secondsUntilReset <= 0) return { wait: false, seconds: 0 };

    return { wait: true, seconds: secondsUntilReset };
  }
}
