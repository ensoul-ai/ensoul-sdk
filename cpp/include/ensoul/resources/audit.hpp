#pragma once

#include <string>
#include <map>
#include <optional>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"

namespace ensoul {

// Audit and verification resource.
//
// Exposes the tamper-evident audit trail (Merkle-committed communication
// events) and the public content-verification endpoint. Responses are returned
// as raw decoded JSON, matching the untyped resource methods elsewhere in the
// SDK. The signing key is returned as raw PEM text.
class AuditResource {
public:
    explicit AuditResource(IHttpTransport& transport) : transport_(transport) {}

    // GET /v1/audit/events/{event_id}
    nlohmann::json get_event(const std::string& event_id) {
        auto resp = transport_.request("GET", "/v1/audit/events/" + event_id);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/audit/commitments/{commitment_id}
    nlohmann::json get_commitment(const std::string& commitment_id) {
        auto resp = transport_.request("GET",
            "/v1/audit/commitments/" + commitment_id);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/audit/proofs/{event_id} — Merkle inclusion proof.
    nlohmann::json get_proof(const std::string& event_id) {
        auto resp = transport_.request("GET", "/v1/audit/proofs/" + event_id);
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/verify — verify AI-generated content against the audit trail.
    nlohmann::json verify(const std::string& audit_event_id,
                          const std::string& content_hash = "") {
        nlohmann::json body = {{"audit_event_id", audit_event_id}};
        if (!content_hash.empty()) body["content_hash"] = content_hash;
        auto resp = transport_.request("POST", "/v1/verify", body);
        return nlohmann::json::parse(resp.body);
    }

    // GET /.well-known/ensoul-signing-key.pem — ECDSA public key (PEM text).
    std::string get_signing_key() {
        auto resp = transport_.get_raw("/.well-known/ensoul-signing-key.pem");
        return resp.body;
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
