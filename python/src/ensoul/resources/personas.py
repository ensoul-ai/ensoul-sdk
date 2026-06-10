"""Personas resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

from ensoul.generated.personas import (
    PersonaBatchResponse,
    PersonaFiltersResponse,
    PersonaResponse,
    PersonalityVectorResponse,
)

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage

__all__ = [
    "Personas",
    "AsyncPersonas",
]


class Personas:
    """Synchronous personas resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def create(
        self,
        *,
        name: str,
        domain: str,
        personality_data: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> PersonaResponse:
        """POST /v1/personas"""
        body: dict[str, Any] = {"name": name, "domain": domain}
        if personality_data is not None:
            body["personality_data"] = personality_data
        body.update({k: v for k, v in kwargs.items() if v is not None})
        response = self._client.post("/v1/personas", json=body)
        return PersonaResponse.model_validate(response.json())

    def get(self, persona_id: str) -> PersonaResponse:
        """GET /v1/personas/{persona_id}"""
        response = self._client.get(f"/v1/personas/{persona_id}")
        return PersonaResponse.model_validate(response.json())

    def update(self, persona_id: str, **kwargs: Any) -> PersonaResponse:
        """PUT /v1/personas/{persona_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = self._client.put(f"/v1/personas/{persona_id}", json=body)
        return PersonaResponse.model_validate(response.json())

    def delete(self, persona_id: str) -> None:
        """DELETE /v1/personas/{persona_id}"""
        self._client.delete(f"/v1/personas/{persona_id}")

    def list(
        self,
        *,
        page: int = 1,
        per_page: int = 20,
        region: str | None = None,
        archetype: str | None = None,
        country: str | None = None,
        city: str | None = None,
        **kwargs: Any,
    ) -> SyncPage[PersonaResponse]:
        """GET /v1/personas — returns auto-paginating page."""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        if region is not None:
            params["region"] = region
        if archetype is not None:
            params["archetype"] = archetype
        if country is not None:
            params["country"] = country
        if city is not None:
            params["city"] = city
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = self._client.get("/v1/personas", params=params)
        data = response.json()
        return SyncPage(
            items=[PersonaResponse.model_validate(item) for item in data["items"]],
            total=data["total"],
            page=data["page"],
            per_page=data.get("per_page", per_page),
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/personas",
            params=params,
            model=PersonaResponse,
        )

    def batch_create(
        self,
        personas: list[dict[str, Any]],
        *,
        batch_id: str | None = None,
        domain: str | None = None,
    ) -> PersonaBatchResponse:
        """POST /v1/personas/batch"""
        body: dict[str, Any] = {"personas": personas}
        if batch_id is not None:
            body["batch_id"] = batch_id
        if domain is not None:
            body["domain"] = domain
        response = self._client.post("/v1/personas/batch", json=body)
        return PersonaBatchResponse.model_validate(response.json())

    def get_personality(self, persona_id: str) -> PersonalityVectorResponse:
        """GET /v1/personas/{persona_id}/personality"""
        response = self._client.get(f"/v1/personas/{persona_id}/personality")
        return PersonalityVectorResponse.model_validate(response.json())

    def get_filters(self) -> PersonaFiltersResponse:
        """GET /v1/personas/filters"""
        response = self._client.get("/v1/personas/filters")
        return PersonaFiltersResponse.model_validate(response.json())

    def get_connections(self, persona_id: str) -> list[Any]:
        """GET /v1/personas/{persona_id}/connections"""
        response = self._client.get(f"/v1/personas/{persona_id}/connections")
        return response.json()


class AsyncPersonas:
    """Async version of the personas resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def create(
        self,
        *,
        name: str,
        domain: str,
        personality_data: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> PersonaResponse:
        """POST /v1/personas"""
        body: dict[str, Any] = {"name": name, "domain": domain}
        if personality_data is not None:
            body["personality_data"] = personality_data
        body.update({k: v for k, v in kwargs.items() if v is not None})
        response = await self._client.post("/v1/personas", json=body)
        return PersonaResponse.model_validate(response.json())

    async def get(self, persona_id: str) -> PersonaResponse:
        """GET /v1/personas/{persona_id}"""
        response = await self._client.get(f"/v1/personas/{persona_id}")
        return PersonaResponse.model_validate(response.json())

    async def update(self, persona_id: str, **kwargs: Any) -> PersonaResponse:
        """PUT /v1/personas/{persona_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = await self._client.put(f"/v1/personas/{persona_id}", json=body)
        return PersonaResponse.model_validate(response.json())

    async def delete(self, persona_id: str) -> None:
        """DELETE /v1/personas/{persona_id}"""
        await self._client.delete(f"/v1/personas/{persona_id}")

    async def list(
        self,
        *,
        page: int = 1,
        per_page: int = 20,
        region: str | None = None,
        archetype: str | None = None,
        country: str | None = None,
        city: str | None = None,
        **kwargs: Any,
    ) -> AsyncPage[PersonaResponse]:
        """GET /v1/personas — returns auto-paginating page."""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        if region is not None:
            params["region"] = region
        if archetype is not None:
            params["archetype"] = archetype
        if country is not None:
            params["country"] = country
        if city is not None:
            params["city"] = city
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = await self._client.get("/v1/personas", params=params)
        data = response.json()
        return AsyncPage(
            items=[PersonaResponse.model_validate(item) for item in data["items"]],
            total=data["total"],
            page=data["page"],
            per_page=data.get("per_page", per_page),
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/personas",
            params=params,
            model=PersonaResponse,
        )

    async def batch_create(
        self,
        personas: list[dict[str, Any]],
        *,
        batch_id: str | None = None,
        domain: str | None = None,
    ) -> PersonaBatchResponse:
        """POST /v1/personas/batch"""
        body: dict[str, Any] = {"personas": personas}
        if batch_id is not None:
            body["batch_id"] = batch_id
        if domain is not None:
            body["domain"] = domain
        response = await self._client.post("/v1/personas/batch", json=body)
        return PersonaBatchResponse.model_validate(response.json())

    async def get_personality(self, persona_id: str) -> PersonalityVectorResponse:
        """GET /v1/personas/{persona_id}/personality"""
        response = await self._client.get(f"/v1/personas/{persona_id}/personality")
        return PersonalityVectorResponse.model_validate(response.json())

    async def get_filters(self) -> PersonaFiltersResponse:
        """GET /v1/personas/filters"""
        response = await self._client.get("/v1/personas/filters")
        return PersonaFiltersResponse.model_validate(response.json())

    async def get_connections(self, persona_id: str) -> list[Any]:
        """GET /v1/personas/{persona_id}/connections"""
        response = await self._client.get(f"/v1/personas/{persona_id}/connections")
        return response.json()
