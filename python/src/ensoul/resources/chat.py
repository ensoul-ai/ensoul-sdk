"""Chat resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

from ensoul.generated.chat import (
    ChatResponse,
    ConversationListItem,
    ConversationResponse,
)

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage
    from ensoul.streaming import AsyncSSEStream, SyncSSEStream

__all__ = [
    "Chat",
    "AsyncChat",
]


class Chat:
    """Synchronous chat resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def send(
        self,
        persona_id: str,
        message: str,
        *,
        conversation_id: str | None = None,
        user_id: str | None = None,
        max_tokens: int = 1024,
        temperature: float = 1.0,
        include_memories: bool = True,
        include_knowledge: bool = True,
    ) -> ChatResponse:
        """POST /v1/personas/{persona_id}/chat"""
        body: dict[str, Any] = {
            "message": message,
            "max_tokens": max_tokens,
            "temperature": temperature,
            "include_memories": include_memories,
            "include_knowledge": include_knowledge,
        }
        if conversation_id is not None:
            body["conversation_id"] = conversation_id
        if user_id is not None:
            body["user_id"] = user_id
        response = self._client.post(f"/v1/personas/{persona_id}/chat", json=body)
        return ChatResponse.model_validate(response.json())

    def stream(
        self,
        persona_id: str,
        message: str,
        **kwargs: Any,
    ) -> SyncSSEStream:
        """POST /v1/personas/{persona_id}/chat/stream — returns SSE stream."""
        body: dict[str, Any] = {
            "message": message,
            **{k: v for k, v in kwargs.items() if v is not None},
        }
        return self._client.stream_sse(
            "POST",
            f"/v1/personas/{persona_id}/chat/stream",
            json=body,
        )

    def get_conversations(
        self,
        persona_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> SyncPage[ConversationListItem]:
        """GET /v1/personas/{persona_id}/conversations"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = self._client.get(
            f"/v1/personas/{persona_id}/conversations", params=params
        )
        data = response.json()
        return SyncPage(
            items=[ConversationListItem.model_validate(item) for item in data["items"]],
            total=data["total"],
            page=data["page"],
            per_page=data.get("per_page", per_page),
            pages=data["pages"],
            client=self._client,
            method="GET",
            path=f"/v1/personas/{persona_id}/conversations",
            params=params,
            model=ConversationListItem,
        )

    def get_conversation(
        self,
        persona_id: str,
        conversation_id: str,
    ) -> ConversationResponse:
        """GET /v1/personas/{persona_id}/conversations/{conversation_id}"""
        response = self._client.get(
            f"/v1/personas/{persona_id}/conversations/{conversation_id}"
        )
        return ConversationResponse.model_validate(response.json())

    # -- Chat sessions (persisted conversation history) --------------------

    def create_session(
        self,
        *,
        team_id: str,
        user_id: str,
        domain_id: str,
        persona_id: str | None = None,
        mode: str | None = None,
        participant_persona_ids: list[str] | None = None,
        title: str | None = None,
    ) -> dict[str, Any]:
        """POST /v1/chat/sessions"""
        body: dict[str, Any] = {
            "team_id": team_id,
            "user_id": user_id,
            "domain_id": domain_id,
        }
        if persona_id is not None:
            body["persona_id"] = persona_id
        if mode is not None:
            body["mode"] = mode
        if participant_persona_ids is not None:
            body["participant_persona_ids"] = participant_persona_ids
        if title is not None:
            body["title"] = title
        response = self._client.post("/v1/chat/sessions", json=body)
        return response.json()

    def list_sessions(
        self,
        *,
        user_id: str,
        mode: str | None = None,
        domain_id: str | None = None,
        include_archived: bool | None = None,
        page: int = 1,
        per_page: int = 20,
    ) -> dict[str, Any]:
        """GET /v1/chat/sessions"""
        params: dict[str, Any] = {
            "user_id": user_id,
            "page": page,
            "per_page": per_page,
        }
        if mode is not None:
            params["mode"] = mode
        if domain_id is not None:
            params["domain_id"] = domain_id
        if include_archived is not None:
            params["include_archived"] = include_archived
        response = self._client.get("/v1/chat/sessions", params=params)
        return response.json()

    def session_stats(
        self,
        *,
        team_id: str,
        start_date: str,
        end_date: str,
    ) -> dict[str, Any]:
        """GET /v1/chat/sessions/stats"""
        params: dict[str, Any] = {
            "team_id": team_id,
            "start_date": start_date,
            "end_date": end_date,
        }
        response = self._client.get("/v1/chat/sessions/stats", params=params)
        return response.json()

    def get_session(
        self,
        session_id: str,
        *,
        user_id: str | None = None,
    ) -> dict[str, Any]:
        """GET /v1/chat/sessions/{session_id}"""
        params: dict[str, Any] = {}
        if user_id is not None:
            params["user_id"] = user_id
        response = self._client.get(
            f"/v1/chat/sessions/{session_id}", params=params or None
        )
        return response.json()

    def update_session(
        self,
        session_id: str,
        *,
        title: str | None = None,
        is_archived: bool | None = None,
    ) -> dict[str, Any]:
        """PATCH /v1/chat/sessions/{session_id}"""
        body: dict[str, Any] = {}
        if title is not None:
            body["title"] = title
        if is_archived is not None:
            body["is_archived"] = is_archived
        response = self._client.patch(
            f"/v1/chat/sessions/{session_id}", json=body
        )
        return response.json()

    def delete_session(self, session_id: str) -> None:
        """DELETE /v1/chat/sessions/{session_id}"""
        self._client.delete(f"/v1/chat/sessions/{session_id}")

    def archive_session(self, session_id: str) -> dict[str, Any]:
        """POST /v1/chat/sessions/{session_id}/archive"""
        response = self._client.post(
            f"/v1/chat/sessions/{session_id}/archive", json={}
        )
        return response.json()

    def add_message(
        self,
        session_id: str,
        *,
        role: str,
        content: str,
        input_tokens: int | None = None,
        output_tokens: int | None = None,
        model_used: str | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """POST /v1/chat/sessions/{session_id}/messages"""
        body: dict[str, Any] = {"role": role, "content": content}
        if input_tokens is not None:
            body["input_tokens"] = input_tokens
        if output_tokens is not None:
            body["output_tokens"] = output_tokens
        if model_used is not None:
            body["model_used"] = model_used
        if metadata is not None:
            body["metadata"] = metadata
        response = self._client.post(
            f"/v1/chat/sessions/{session_id}/messages", json=body
        )
        return response.json()

    def get_messages(
        self,
        session_id: str,
        *,
        limit: int | None = None,
        offset: int | None = None,
    ) -> list[dict[str, Any]]:
        """GET /v1/chat/sessions/{session_id}/messages"""
        params: dict[str, Any] = {}
        if limit is not None:
            params["limit"] = limit
        if offset is not None:
            params["offset"] = offset
        response = self._client.get(
            f"/v1/chat/sessions/{session_id}/messages", params=params or None
        )
        return response.json()


class AsyncChat:
    """Async version of the chat resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def send(
        self,
        persona_id: str,
        message: str,
        *,
        conversation_id: str | None = None,
        user_id: str | None = None,
        max_tokens: int = 1024,
        temperature: float = 1.0,
        include_memories: bool = True,
        include_knowledge: bool = True,
    ) -> ChatResponse:
        """POST /v1/personas/{persona_id}/chat"""
        body: dict[str, Any] = {
            "message": message,
            "max_tokens": max_tokens,
            "temperature": temperature,
            "include_memories": include_memories,
            "include_knowledge": include_knowledge,
        }
        if conversation_id is not None:
            body["conversation_id"] = conversation_id
        if user_id is not None:
            body["user_id"] = user_id
        response = await self._client.post(
            f"/v1/personas/{persona_id}/chat", json=body
        )
        return ChatResponse.model_validate(response.json())

    async def stream(
        self,
        persona_id: str,
        message: str,
        **kwargs: Any,
    ) -> AsyncSSEStream:
        """POST /v1/personas/{persona_id}/chat/stream — returns SSE stream."""
        body: dict[str, Any] = {
            "message": message,
            **{k: v for k, v in kwargs.items() if v is not None},
        }
        return await self._client.stream_sse(
            "POST",
            f"/v1/personas/{persona_id}/chat/stream",
            json=body,
        )

    async def get_conversations(
        self,
        persona_id: str,
        *,
        page: int = 1,
        per_page: int = 20,
    ) -> AsyncPage[ConversationListItem]:
        """GET /v1/personas/{persona_id}/conversations"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        response = await self._client.get(
            f"/v1/personas/{persona_id}/conversations", params=params
        )
        data = response.json()
        return AsyncPage(
            items=[ConversationListItem.model_validate(item) for item in data["items"]],
            total=data["total"],
            page=data["page"],
            per_page=data.get("per_page", per_page),
            pages=data["pages"],
            client=self._client,
            method="GET",
            path=f"/v1/personas/{persona_id}/conversations",
            params=params,
            model=ConversationListItem,
        )

    async def get_conversation(
        self,
        persona_id: str,
        conversation_id: str,
    ) -> ConversationResponse:
        """GET /v1/personas/{persona_id}/conversations/{conversation_id}"""
        response = await self._client.get(
            f"/v1/personas/{persona_id}/conversations/{conversation_id}"
        )
        return ConversationResponse.model_validate(response.json())

    # -- Chat sessions (persisted conversation history) --------------------

    async def create_session(
        self,
        *,
        team_id: str,
        user_id: str,
        domain_id: str,
        persona_id: str | None = None,
        mode: str | None = None,
        participant_persona_ids: list[str] | None = None,
        title: str | None = None,
    ) -> dict[str, Any]:
        """POST /v1/chat/sessions"""
        body: dict[str, Any] = {
            "team_id": team_id,
            "user_id": user_id,
            "domain_id": domain_id,
        }
        if persona_id is not None:
            body["persona_id"] = persona_id
        if mode is not None:
            body["mode"] = mode
        if participant_persona_ids is not None:
            body["participant_persona_ids"] = participant_persona_ids
        if title is not None:
            body["title"] = title
        response = await self._client.post("/v1/chat/sessions", json=body)
        return response.json()

    async def list_sessions(
        self,
        *,
        user_id: str,
        mode: str | None = None,
        domain_id: str | None = None,
        include_archived: bool | None = None,
        page: int = 1,
        per_page: int = 20,
    ) -> dict[str, Any]:
        """GET /v1/chat/sessions"""
        params: dict[str, Any] = {
            "user_id": user_id,
            "page": page,
            "per_page": per_page,
        }
        if mode is not None:
            params["mode"] = mode
        if domain_id is not None:
            params["domain_id"] = domain_id
        if include_archived is not None:
            params["include_archived"] = include_archived
        response = await self._client.get("/v1/chat/sessions", params=params)
        return response.json()

    async def session_stats(
        self,
        *,
        team_id: str,
        start_date: str,
        end_date: str,
    ) -> dict[str, Any]:
        """GET /v1/chat/sessions/stats"""
        params: dict[str, Any] = {
            "team_id": team_id,
            "start_date": start_date,
            "end_date": end_date,
        }
        response = await self._client.get(
            "/v1/chat/sessions/stats", params=params
        )
        return response.json()

    async def get_session(
        self,
        session_id: str,
        *,
        user_id: str | None = None,
    ) -> dict[str, Any]:
        """GET /v1/chat/sessions/{session_id}"""
        params: dict[str, Any] = {}
        if user_id is not None:
            params["user_id"] = user_id
        response = await self._client.get(
            f"/v1/chat/sessions/{session_id}", params=params or None
        )
        return response.json()

    async def update_session(
        self,
        session_id: str,
        *,
        title: str | None = None,
        is_archived: bool | None = None,
    ) -> dict[str, Any]:
        """PATCH /v1/chat/sessions/{session_id}"""
        body: dict[str, Any] = {}
        if title is not None:
            body["title"] = title
        if is_archived is not None:
            body["is_archived"] = is_archived
        response = await self._client.patch(
            f"/v1/chat/sessions/{session_id}", json=body
        )
        return response.json()

    async def delete_session(self, session_id: str) -> None:
        """DELETE /v1/chat/sessions/{session_id}"""
        await self._client.delete(f"/v1/chat/sessions/{session_id}")

    async def archive_session(self, session_id: str) -> dict[str, Any]:
        """POST /v1/chat/sessions/{session_id}/archive"""
        response = await self._client.post(
            f"/v1/chat/sessions/{session_id}/archive", json={}
        )
        return response.json()

    async def add_message(
        self,
        session_id: str,
        *,
        role: str,
        content: str,
        input_tokens: int | None = None,
        output_tokens: int | None = None,
        model_used: str | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """POST /v1/chat/sessions/{session_id}/messages"""
        body: dict[str, Any] = {"role": role, "content": content}
        if input_tokens is not None:
            body["input_tokens"] = input_tokens
        if output_tokens is not None:
            body["output_tokens"] = output_tokens
        if model_used is not None:
            body["model_used"] = model_used
        if metadata is not None:
            body["metadata"] = metadata
        response = await self._client.post(
            f"/v1/chat/sessions/{session_id}/messages", json=body
        )
        return response.json()

    async def get_messages(
        self,
        session_id: str,
        *,
        limit: int | None = None,
        offset: int | None = None,
    ) -> list[dict[str, Any]]:
        """GET /v1/chat/sessions/{session_id}/messages"""
        params: dict[str, Any] = {}
        if limit is not None:
            params["limit"] = limit
        if offset is not None:
            params["offset"] = offset
        response = await self._client.get(
            f"/v1/chat/sessions/{session_id}/messages", params=params or None
        )
        return response.json()
