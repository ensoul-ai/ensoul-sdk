"""Tests for SyncPage and AsyncPage pagination."""

from __future__ import annotations

import json

import httpx
import pytest
import respx

from ensoul import Ensoul
from ensoul.generated.personas import PersonaResponse
from ensoul.pagination import AsyncPage, SyncPage

TEST_BASE_URL = "https://test.ensoul.ai"


def _make_persona(i: int) -> dict:
    return {
        "id": f"persona_{i:03d}",
        "name": f"Persona {i}",
        "domain": "test_domain",
        "personality_data": {},
        "avatar_url": None,
        "archetype": None,
        "age": 25 + i,
        "country": "test_country",
        "region": "test_region",
        "city": "Test City",
        "batch_id": None,
        "created_at": "2025-01-15T10:30:00Z",
    }


def _make_page_payload(page: int, per_page: int, total: int) -> dict:
    import math
    pages = math.ceil(total / per_page)
    start = (page - 1) * per_page
    items = [_make_persona(i) for i in range(start, min(start + per_page, total))]
    return {
        "items": items,
        "total": total,
        "page": page,
        "per_page": per_page,
        "pages": pages,
    }


@pytest.fixture
def client():
    return Ensoul(api_key="sk_test_123", base_url=TEST_BASE_URL)


class TestSyncPage:
    def test_has_next_page_true(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=_make_page_payload(1, 2, 5))
            )
            page = client.personas.list(per_page=2)
        assert page.has_next_page() is True

    def test_has_next_page_false_on_last(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=_make_page_payload(1, 20, 3))
            )
            page = client.personas.list()
        assert page.has_next_page() is False

    def test_iteration_yields_items(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=_make_page_payload(1, 3, 3))
            )
            page = client.personas.list()
        items = list(page)
        assert len(items) == 3
        assert all(isinstance(p, PersonaResponse) for p in items)

    def test_auto_paging_iter_fetches_all_pages(self, client):
        total = 5
        per_page = 2

        def page_handler(request: httpx.Request) -> httpx.Response:
            params = dict(httpx.URL(request.url).params)
            p = int(params.get("page", 1))
            return httpx.Response(200, json=_make_page_payload(p, per_page, total))

        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(side_effect=page_handler)
            page = client.personas.list(per_page=per_page)
            all_items = list(page.auto_paging_iter())

        assert len(all_items) == total
        assert all(isinstance(p, PersonaResponse) for p in all_items)

    def test_auto_paging_iter_single_page(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=_make_page_payload(1, 20, 2))
            )
            page = client.personas.list()
            items = list(page.auto_paging_iter())
        assert len(items) == 2

    def test_next_page_raises_stop_iteration_on_last_page(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=_make_page_payload(1, 20, 1))
            )
            page = client.personas.list()
        with pytest.raises(StopIteration):
            page.next_page()

    def test_page_attributes(self, client):
        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=_make_page_payload(1, 2, 7))
            )
            page = client.personas.list(per_page=2)
        assert page.total == 7
        assert page.page == 1
        assert page.per_page == 2
        assert page.pages == 4


class TestAsyncPage:
    @pytest.mark.asyncio
    async def test_async_auto_paging_iter(self):
        from ensoul import AsyncEnsoul

        total = 4
        per_page = 2

        def page_handler(request: httpx.Request) -> httpx.Response:
            params = dict(httpx.URL(request.url).params)
            p = int(params.get("page", 1))
            return httpx.Response(200, json=_make_page_payload(p, per_page, total))

        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(side_effect=page_handler)
            async with AsyncEnsoul(api_key="sk_test", base_url=TEST_BASE_URL) as client:
                page = await client.personas.list(per_page=per_page)
                items = [p async for p in page.auto_paging_iter()]

        assert len(items) == total

    @pytest.mark.asyncio
    async def test_async_page_has_next_page(self):
        from ensoul import AsyncEnsoul

        with respx.mock(base_url=TEST_BASE_URL) as mock:
            mock.get("/v1/personas").mock(
                return_value=httpx.Response(200, json=_make_page_payload(1, 2, 5))
            )
            async with AsyncEnsoul(api_key="sk_test", base_url=TEST_BASE_URL) as client:
                page = await client.personas.list(per_page=2)
        assert page.has_next_page() is True
