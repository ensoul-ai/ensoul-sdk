"""Auto-pagination iterators for the Ensoul SDK."""

from __future__ import annotations

from typing import Any, AsyncIterator, Callable, Generic, Iterator, TypeVar

__all__ = [
    "SyncPage",
    "AsyncPage",
]

T = TypeVar("T")


class SyncPage(Generic[T]):
    """A single page of results with auto-pagination support.

    Holds the current page's items and knows how to fetch subsequent pages
    using the embedded HTTP client reference and original request parameters.
    """

    def __init__(
        self,
        *,
        items: list[T],
        total: int,
        page: int,
        per_page: int,
        pages: int,
        client: Any,
        method: str,
        path: str,
        params: dict[str, Any],
        model: Callable[[dict], T],
    ) -> None:
        self.items = items
        self.total = total
        self.page = page
        self.per_page = per_page
        self.pages = pages
        self._client = client
        self._method = method
        self._path = path
        self._params = params
        self._model = model

    def has_next_page(self) -> bool:
        """True if there are more pages to fetch."""
        return self.page < self.pages

    def next_page(self) -> SyncPage[T]:
        """Fetch and return the next page of results.

        Raises StopIteration if this is already the last page.
        """
        if not self.has_next_page():
            raise StopIteration("No more pages")

        next_params = {**self._params, "page": self.page + 1}
        response = self._client.request(self._method, self._path, params=next_params)
        data = response.json()
        raw_items: list[dict] = data.get("items", [])
        return SyncPage(
            items=[self._model.model_validate(item) if hasattr(self._model, "model_validate") else self._model(item) for item in raw_items],
            total=data.get("total", self.total),
            page=data.get("page", self.page + 1),
            per_page=data.get("per_page", self.per_page),
            pages=data.get("pages", self.pages),
            client=self._client,
            method=self._method,
            path=self._path,
            params=self._params,
            model=self._model,
        )

    def __iter__(self) -> Iterator[T]:
        """Yield items from the current page only."""
        return iter(self.items)

    def auto_paging_iter(self) -> Iterator[T]:
        """Yield items from ALL pages, fetching subsequent pages automatically."""
        current: SyncPage[T] = self
        while True:
            yield from current.items
            if not current.has_next_page():
                break
            current = current.next_page()


class AsyncPage(Generic[T]):
    """Async version of SyncPage with auto-pagination support."""

    def __init__(
        self,
        *,
        items: list[T],
        total: int,
        page: int,
        per_page: int,
        pages: int,
        client: Any,
        method: str,
        path: str,
        params: dict[str, Any],
        model: Callable[[dict], T],
    ) -> None:
        self.items = items
        self.total = total
        self.page = page
        self.per_page = per_page
        self.pages = pages
        self._client = client
        self._method = method
        self._path = path
        self._params = params
        self._model = model

    def has_next_page(self) -> bool:
        """True if there are more pages to fetch."""
        return self.page < self.pages

    async def next_page(self) -> AsyncPage[T]:
        """Fetch and return the next page of results.

        Raises StopAsyncIteration if this is already the last page.
        """
        if not self.has_next_page():
            raise StopAsyncIteration("No more pages")

        next_params = {**self._params, "page": self.page + 1}
        response = await self._client.request(self._method, self._path, params=next_params)
        data = response.json()
        raw_items: list[dict] = data.get("items", [])
        return AsyncPage(
            items=[self._model.model_validate(item) if hasattr(self._model, "model_validate") else self._model(item) for item in raw_items],
            total=data.get("total", self.total),
            page=data.get("page", self.page + 1),
            per_page=data.get("per_page", self.per_page),
            pages=data.get("pages", self.pages),
            client=self._client,
            method=self._method,
            path=self._path,
            params=self._params,
            model=self._model,
        )

    def __aiter__(self) -> AsyncIterator[T]:
        return self._iter_items()

    async def _iter_items(self) -> AsyncIterator[T]:
        """Yield items from the current page only."""
        for item in self.items:
            yield item

    async def auto_paging_iter(self) -> AsyncIterator[T]:
        """Yield items from ALL pages, fetching subsequent pages automatically."""
        current: AsyncPage[T] = self
        while True:
            for item in current.items:
                yield item
            if not current.has_next_page():
                break
            current = await current.next_page()
