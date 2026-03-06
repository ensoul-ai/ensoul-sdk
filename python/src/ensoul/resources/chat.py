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
            per_page=data["per_page"],
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
            per_page=data["per_page"],
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
