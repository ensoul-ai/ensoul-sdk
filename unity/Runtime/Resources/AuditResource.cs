using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    /// <summary>
    /// Audit and verification resource. Exposes the tamper-evident audit trail
    /// (Merkle-committed communication events) and the public content-verification
    /// endpoint. Responses are returned as raw decoded JSON, matching the untyped
    /// resource methods elsewhere in the SDK.
    /// </summary>
    public class AuditResource
    {
        private readonly EnsoulHttpClient _client;

        public AuditResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        /// <summary>GET /v1/audit/events/{eventId}</summary>
        public async Task<JObject> GetEventAsync(string eventId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/audit/events/{eventId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/audit/commitments/{commitmentId}</summary>
        public async Task<JObject> GetCommitmentAsync(string commitmentId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/audit/commitments/{commitmentId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/audit/proofs/{eventId} — Merkle inclusion proof.</summary>
        public async Task<JObject> GetProofAsync(string eventId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/audit/proofs/{eventId}");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/verify — verify AI-generated content against the audit trail.</summary>
        public async Task<JObject> VerifyAsync(string auditEventId, string contentHash = null)
        {
            var body = new Dictionary<string, object?> { ["audit_event_id"] = auditEventId };
            if (contentHash != null) body["content_hash"] = contentHash;
            var response = await _client.RequestAsync(HttpMethod.Post, "/v1/verify", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>
        /// GET /.well-known/ensoul-signing-key.pem — ECDSA public key (PEM text).
        /// Returns the raw PEM string, not JSON.
        /// </summary>
        public async Task<string> GetSigningKeyAsync()
        {
            var response = await _client.GetRawAsync("/.well-known/ensoul-signing-key.pem");
            return await response.Content.ReadAsStringAsync();
        }
    }
}
