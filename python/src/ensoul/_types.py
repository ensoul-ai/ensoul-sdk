"""Shared type aliases for the Ensoul SDK."""

from __future__ import annotations

from typing import Any, Protocol, TypeVar, runtime_checkable

from pydantic import BaseModel

__all__ = [
    "HeadersLike",
    "QueryParams",
    "RequestBody",
    "T",
    "PaginatedResponse",
]

HeadersLike = dict[str, str]
QueryParams = dict[str, Any]
RequestBody = dict[str, Any] | BaseModel
T = TypeVar("T")


@runtime_checkable
class PaginatedResponse(Protocol):
    items: list
    total: int
    page: int
    per_page: int
    pages: int
