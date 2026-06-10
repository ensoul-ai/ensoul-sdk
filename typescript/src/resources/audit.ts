import type { HTTPClient } from "../http.js";

/**
 * Audit and verification resource.
 *
 * Exposes the tamper-evident audit trail (Merkle-committed communication
 * events) and the public content-verification endpoint. Responses are returned
 * as raw decoded JSON, matching the untyped resource methods elsewhere in the SDK.
 */
export class Audit {
  constructor(private readonly client: HTTPClient) {}

  /** GET /v1/audit/events/{eventId} */
  async getEvent(eventId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/audit/events/${eventId}`);
  }

  /** GET /v1/audit/commitments/{commitmentId} */
  async getCommitment(commitmentId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/audit/commitments/${commitmentId}`);
  }

  /** GET /v1/audit/proofs/{eventId} — Merkle inclusion proof. */
  async getProof(eventId: string): Promise<Record<string, unknown>> {
    return this.client.get(`/v1/audit/proofs/${eventId}`);
  }

  /** POST /v1/verify — verify AI-generated content against the audit trail. */
  async verify(
    auditEventId: string,
    options?: { contentHash?: string },
  ): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = { audit_event_id: auditEventId };
    if (options?.contentHash != null) body.content_hash = options.contentHash;
    return this.client.post("/v1/verify", body);
  }

  /** GET /.well-known/ensoul-signing-key.pem — ECDSA public key (PEM text). */
  async getSigningKey(): Promise<string> {
    return this.client.getText("/.well-known/ensoul-signing-key.pem");
  }
}
