"""Simulations resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

from ensoul.generated.simulations import SimulationDetailResponse

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage
    from ensoul.streaming import AsyncSSEStream, SyncSSEStream

__all__ = [
    "Simulations",
    "AsyncSimulations",
]


class Simulations:
    """Synchronous simulations resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def create(
        self,
        *,
        name: str,
        domain_id: str,
        description: str | None = None,
        config: dict[str, Any] | None = None,
        participant_persona_ids: list[str] | None = None,
    ) -> SimulationDetailResponse:
        """POST /v1/simulations"""
        body: dict[str, Any] = {"name": name, "domain_id": domain_id}
        if description is not None:
            body["description"] = description
        if config is not None:
            body["config"] = config
        if participant_persona_ids is not None:
            body["participant_persona_ids"] = participant_persona_ids
        response = self._client.post("/v1/simulations", json=body)
        return SimulationDetailResponse.model_validate(response.json())

    def get(self, simulation_id: str) -> SimulationDetailResponse:
        """GET /v1/simulations/{simulation_id}"""
        response = self._client.get(f"/v1/simulations/{simulation_id}")
        return SimulationDetailResponse.model_validate(response.json())

    def list(
        self, *, page: int = 1, per_page: int = 20, **kwargs: Any
    ) -> SyncPage[dict]:
        """GET /v1/simulations"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = self._client.get("/v1/simulations", params=params)
        data = response.json()
        return SyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data["per_page"],
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/simulations",
            params=params,
            model=dict,
        )

    def start(
        self, simulation_id: str, *, ticks: int | None = None
    ) -> dict[str, Any]:
        """POST /v1/simulations/{simulation_id}/start"""
        body: dict[str, Any] = {}
        if ticks is not None:
            body["ticks"] = ticks
        response = self._client.post(
            f"/v1/simulations/{simulation_id}/start", json=body
        )
        return response.json()

    def pause(self, simulation_id: str) -> dict[str, Any]:
        """POST /v1/simulations/{simulation_id}/pause"""
        response = self._client.post(
            f"/v1/simulations/{simulation_id}/pause", json={}
        )
        return response.json()

    def stop(self, simulation_id: str) -> dict[str, Any]:
        """POST /v1/simulations/{simulation_id}/stop"""
        response = self._client.post(
            f"/v1/simulations/{simulation_id}/stop", json={}
        )
        return response.json()

    def stream(self, simulation_id: str) -> SyncSSEStream:
        """GET /v1/simulations/{simulation_id}/stream"""
        return self._client.stream_sse(
            "GET", f"/v1/simulations/{simulation_id}/stream"
        )

    def get_events(
        self,
        simulation_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
        **kwargs: Any,
    ) -> SyncPage[dict]:
        """GET /v1/simulations/{simulation_id}/events"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = self._client.get(
            f"/v1/simulations/{simulation_id}/events", params=params
        )
        data = response.json()
        return SyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data["per_page"],
            pages=data["pages"],
            client=self._client,
            method="GET",
            path=f"/v1/simulations/{simulation_id}/events",
            params=params,
            model=dict,
        )

    def get_history(self, simulation_id: str) -> dict[str, Any]:
        """GET /v1/simulations/{simulation_id}/history"""
        response = self._client.get(f"/v1/simulations/{simulation_id}/history")
        return response.json()


class AsyncSimulations:
    """Async version of the simulations resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def create(
        self,
        *,
        name: str,
        domain_id: str,
        description: str | None = None,
        config: dict[str, Any] | None = None,
        participant_persona_ids: list[str] | None = None,
    ) -> SimulationDetailResponse:
        """POST /v1/simulations"""
        body: dict[str, Any] = {"name": name, "domain_id": domain_id}
        if description is not None:
            body["description"] = description
        if config is not None:
            body["config"] = config
        if participant_persona_ids is not None:
            body["participant_persona_ids"] = participant_persona_ids
        response = await self._client.post("/v1/simulations", json=body)
        return SimulationDetailResponse.model_validate(response.json())

    async def get(self, simulation_id: str) -> SimulationDetailResponse:
        """GET /v1/simulations/{simulation_id}"""
        response = await self._client.get(f"/v1/simulations/{simulation_id}")
        return SimulationDetailResponse.model_validate(response.json())

    async def list(
        self, *, page: int = 1, per_page: int = 20, **kwargs: Any
    ) -> AsyncPage[dict]:
        """GET /v1/simulations"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = await self._client.get("/v1/simulations", params=params)
        data = response.json()
        return AsyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data["per_page"],
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/simulations",
            params=params,
            model=dict,
        )

    async def start(
        self, simulation_id: str, *, ticks: int | None = None
    ) -> dict[str, Any]:
        """POST /v1/simulations/{simulation_id}/start"""
        body: dict[str, Any] = {}
        if ticks is not None:
            body["ticks"] = ticks
        response = await self._client.post(
            f"/v1/simulations/{simulation_id}/start", json=body
        )
        return response.json()

    async def pause(self, simulation_id: str) -> dict[str, Any]:
        """POST /v1/simulations/{simulation_id}/pause"""
        response = await self._client.post(
            f"/v1/simulations/{simulation_id}/pause", json={}
        )
        return response.json()

    async def stop(self, simulation_id: str) -> dict[str, Any]:
        """POST /v1/simulations/{simulation_id}/stop"""
        response = await self._client.post(
            f"/v1/simulations/{simulation_id}/stop", json={}
        )
        return response.json()

    async def stream(self, simulation_id: str) -> AsyncSSEStream:
        """GET /v1/simulations/{simulation_id}/stream"""
        return await self._client.stream_sse(
            "GET", f"/v1/simulations/{simulation_id}/stream"
        )

    async def get_events(
        self,
        simulation_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
        **kwargs: Any,
    ) -> AsyncPage[dict]:
        """GET /v1/simulations/{simulation_id}/events"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = await self._client.get(
            f"/v1/simulations/{simulation_id}/events", params=params
        )
        data = response.json()
        return AsyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data["per_page"],
            pages=data["pages"],
            client=self._client,
            method="GET",
            path=f"/v1/simulations/{simulation_id}/events",
            params=params,
            model=dict,
        )

    async def get_history(self, simulation_id: str) -> dict[str, Any]:
        """GET /v1/simulations/{simulation_id}/history"""
        response = await self._client.get(f"/v1/simulations/{simulation_id}/history")
        return response.json()
