/**
 * Exception hierarchy for the Ensoul TypeScript SDK.
 */

export interface ErrorDetail {
  field: string;
  message: string;
  type: string;
}

export class EnsoulError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "EnsoulError";
  }
}

export class APIError extends EnsoulError {
  readonly statusCode: number;
  readonly error: string;
  readonly requestId: string | undefined;

  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
  ) {
    super(message);
    this.name = "APIError";
    this.statusCode = statusCode;
    this.error = error;
    this.requestId = requestId;
  }
}

export class AuthenticationError extends APIError {
  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
  ) {
    super(statusCode, error, message, requestId);
    this.name = "AuthenticationError";
  }
}

export class AuthorizationError extends APIError {
  readonly requiredTier: string | undefined;
  readonly currentTier: string | undefined;

  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
    requiredTier?: string,
    currentTier?: string,
  ) {
    super(statusCode, error, message, requestId);
    this.name = "AuthorizationError";
    this.requiredTier = requiredTier;
    this.currentTier = currentTier;
  }
}

export class NotFoundError extends APIError {
  readonly resourceType: string | undefined;
  readonly resourceId: string | undefined;

  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
    resourceType?: string,
    resourceId?: string,
  ) {
    super(statusCode, error, message, requestId);
    this.name = "NotFoundError";
    this.resourceType = resourceType;
    this.resourceId = resourceId;
  }
}

export class RateLimitError extends APIError {
  readonly retryAfter: number;

  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
    retryAfter = 0,
  ) {
    super(statusCode, error, message, requestId);
    this.name = "RateLimitError";
    this.retryAfter = retryAfter;
  }
}

export class ValidationError extends APIError {
  readonly details: ErrorDetail[];

  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
    details: ErrorDetail[] = [],
  ) {
    super(statusCode, error, message, requestId);
    this.name = "ValidationError";
    this.details = details;
  }
}

export class ConflictError extends APIError {
  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
  ) {
    super(statusCode, error, message, requestId);
    this.name = "ConflictError";
  }
}

export class ServerError extends APIError {
  constructor(
    statusCode: number,
    error: string,
    message: string,
    requestId?: string,
  ) {
    super(statusCode, error, message, requestId);
    this.name = "ServerError";
  }
}

/**
 * Raise an appropriate SDK exception for 4xx/5xx responses.
 */
export function raiseForStatus(
  status: number,
  body: Record<string, unknown>,
  headers?: Headers,
): void {
  if (status < 400) return;

  const error = (body.error as string) ?? "Unknown Error";
  const message = (body.message as string) ?? "Unknown error";
  const requestId = body.request_id as string | undefined;

  if (status === 401) {
    throw new AuthenticationError(status, error, message, requestId);
  }

  if (status === 403) {
    throw new AuthorizationError(status, error, message, requestId);
  }

  if (status === 404) {
    throw new NotFoundError(status, error, message, requestId);
  }

  if (status === 409) {
    throw new ConflictError(status, error, message, requestId);
  }

  if (status === 422) {
    const rawDetails = (body.details as Record<string, unknown>[]) ?? [];
    const details: ErrorDetail[] = rawDetails.map((d) => ({
      field: (d.field as string) ?? "",
      message: (d.message as string) ?? "",
      type: (d.type as string) ?? "",
    }));
    throw new ValidationError(status, error, message, requestId, details);
  }

  if (status === 429) {
    let retryAfter = 0;
    const raw = headers?.get("Retry-After");
    if (raw) {
      const parsed = parseInt(raw, 10);
      if (!isNaN(parsed)) retryAfter = parsed;
    }
    throw new RateLimitError(status, error, message, requestId, retryAfter);
  }

  if (status === 500 || status === 503) {
    throw new ServerError(status, error, message, requestId);
  }

  throw new APIError(status, error, message, requestId);
}
