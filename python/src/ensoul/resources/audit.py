"""Audit and verification resource for the Ensoul SDK.

Exposes the tamper-evident audit trail (Merkle-committed communication events)
and the public content-verification endpoint. Responses are returned as raw
decoded JSON, matching the untyped resource methods elsewhere in the SDK.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient

__all__ = [
    "Audit",
    "AsyncAudit",
]


class Audit:
    """Synchronous audit and verification resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def get_event(self, event_id: str) -> dict[str, Any]:
        """GET /v1/audit/events/{event_id}"""
        response = self._client.get(f"/v1/audit/events/{event_id}")
        return response.json()

    def get_commitment(self, commitment_id: str) -> dict[str, Any]:
        """GET /v1/audit/commitments/{commitment_id}"""
        response = self._client.get(f"/v1/audit/commitments/{commitment_id}")
        return response.json()

    def get_proof(self, event_id: str) -> dict[str, Any]:
        """GET /v1/audit/proofs/{event_id} — Merkle inclusion proof."""
        response = self._client.get(f"/v1/audit/proofs/{event_id}")
        return response.json()

    def verify(
        self,
        audit_event_id: str,
        *,
        content_hash: str | None = None,
    ) -> dict[str, Any]:
        """POST /v1/verify — verify AI-generated content against the audit trail."""
        body: dict[str, Any] = {"audit_event_id": audit_event_id}
        if content_hash is not None:
            body["content_hash"] = content_hash
        response = self._client.post("/v1/verify", json=body)
        return response.json()

    def get_signing_key(self) -> str:
        """GET /.well-known/ensoul-signing-key.pem — ECDSA public key (PEM text)."""
        response = self._client.get_raw("/.well-known/ensoul-signing-key.pem")
        return response.text


class AsyncAudit:
    """Async version of the audit and verification resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def get_event(self, event_id: str) -> dict[str, Any]:
        """GET /v1/audit/events/{event_id}"""
        response = await self._client.get(f"/v1/audit/events/{event_id}")
        return response.json()

    async def get_commitment(self, commitment_id: str) -> dict[str, Any]:
        """GET /v1/audit/commitments/{commitment_id}"""
        response = await self._client.get(
            f"/v1/audit/commitments/{commitment_id}"
        )
        return response.json()

    async def get_proof(self, event_id: str) -> dict[str, Any]:
        """GET /v1/audit/proofs/{event_id} — Merkle inclusion proof."""
        response = await self._client.get(f"/v1/audit/proofs/{event_id}")
        return response.json()

    async def verify(
        self,
        audit_event_id: str,
        *,
        content_hash: str | None = None,
    ) -> dict[str, Any]:
        """POST /v1/verify — verify AI-generated content against the audit trail."""
        body: dict[str, Any] = {"audit_event_id": audit_event_id}
        if content_hash is not None:
            body["content_hash"] = content_hash
        response = await self._client.post("/v1/verify", json=body)
        return response.json()

    async def get_signing_key(self) -> str:
        """GET /.well-known/ensoul-signing-key.pem — ECDSA public key (PEM text)."""
        response = await self._client.get_raw(
            "/.well-known/ensoul-signing-key.pem"
        )
        return response.text
