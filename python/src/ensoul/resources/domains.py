"""Domains resource for the Ensoul SDK."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any, Literal, NotRequired, TypedDict

if TYPE_CHECKING:
    from ensoul.http import AsyncHTTPClient, SyncHTTPClient
    from ensoul.pagination import AsyncPage, SyncPage

__all__ = [
    "Domains",
    "AsyncDomains",
    "TierDefinitionParams",
    "FieldDefinitionParams",
    "TraitCorrelationParams",
    "PersonalitySchemaParams",
    "ArchetypeParams",
    "NamePatternParams",
    "MemoryTemplateParams",
    "FilterableFieldOptionParams",
    "FilterableFieldParams",
    "TierValueOptionParams",
    "TierValuesConfigParams",
    "StyleTemplateParams",
    "ImageGenerationParams",
    "DomainConfigCreateParams",
    "GeneratedConfigResponse",
]


# ---------------------------------------------------------------------------
# Typed request shapes for ``DomainConfigCreate`` (POST /v1/domains).
#
# These mirror the ``DomainConfigCreate`` Pydantic model (the API source of
# truth in ``src/api/models/domains.py``). Required keys are mandatory; every
# optional key is marked ``NotRequired`` and falls back to the server default.
# ---------------------------------------------------------------------------


class TierDefinitionParams(TypedDict):
    """One tier in the hierarchy (level 0 is the root)."""

    level: int
    name: str
    description: NotRequired[str]


class FieldDefinitionParams(TypedDict):
    """A personality-schema field definition."""

    path: str
    field_type: Literal["float", "int", "str", "enum", "bool"]
    range_min: NotRequired[float | None]
    range_max: NotRequired[float | None]
    default: NotRequired[dict[str, object] | None]
    required: NotRequired[bool]
    heritability: NotRequired[float]
    description: NotRequired[str]
    enum_values: NotRequired[list[str] | None]


class TraitCorrelationParams(TypedDict):
    """Correlation between two personality traits."""

    trait_a: str
    trait_b: str
    correlation: float
    description: NotRequired[str | None]


class PersonalitySchemaParams(TypedDict):
    """Complete personality-schema configuration."""

    fields: list[FieldDefinitionParams]
    version: NotRequired[str]
    trait_correlations: NotRequired[list[TraitCorrelationParams] | None]


class ArchetypeParams(TypedDict):
    """An archetype in the hierarchy."""

    id: str
    name: str
    tier: int
    parent_id: NotRequired[str | None]
    personality_modifiers: NotRequired[dict[str, float]]
    description: NotRequired[str]
    metadata: NotRequired[dict[str, object]]
    probability: NotRequired[float]


class NamePatternParams(TypedDict):
    """Name-generation pattern for a tier value."""

    tier_id: str
    tier_value: str
    first_names: NotRequired[list[str]]
    last_names: NotRequired[list[str]]
    patterns: NotRequired[list[str]]
    gender_handling: NotRequired[Literal["neutral", "separate", "none"]]
    prefixes: NotRequired[list[str]]
    suffixes: NotRequired[list[str]]


class MemoryTemplateParams(TypedDict):
    """Memory-template definition for backstory generation."""

    template_id: str
    template_type: Literal["universal", "contextual"]
    template_string: str
    context_type: NotRequired[str | None]
    context_id: NotRequired[str | None]
    probability: NotRequired[float]
    importance: NotRequired[float]
    tags: NotRequired[list[str]]


class FilterableFieldOptionParams(TypedDict):
    """One option for a select/multiselect filterable field."""

    value: str
    label: str


class FilterableFieldParams(TypedDict):
    """A field exposed for filtering in aggregate queries."""

    path: str
    type: Literal["range", "select", "multiselect"]
    label: str
    description: NotRequired[str]
    min: NotRequired[float | None]
    max: NotRequired[float | None]
    step: NotRequired[float | None]
    options_from: NotRequired[str | None]
    options: NotRequired[list[FilterableFieldOptionParams] | None]


class TierValueOptionParams(TypedDict):
    """One weighted option for a tier value."""

    value: str
    label: str
    probability: NotRequired[float]


class TierValuesConfigParams(TypedDict):
    """Value configuration for hierarchical tier selection."""

    tier_id: str
    options: list[TierValueOptionParams]
    parent_tier_id: NotRequired[str | None]
    parent_value_mapping: NotRequired[dict[str, list[str]] | None]


class StyleTemplateParams(TypedDict):
    """Visual style template for avatar generation."""

    name: str
    style_prompt: str
    description: NotRequired[str]
    negative_prompt: NotRequired[str]


class ImageGenerationParams(TypedDict):
    """Domain-level avatar image-generation settings."""

    default_style: NotRequired[str]
    styles: NotRequired[list[StyleTemplateParams]]
    prompt_prefix: NotRequired[str]
    prompt_suffix: NotRequired[str]


class DomainConfigCreateParams(TypedDict):
    """Request body for ``POST /v1/domains`` (shaped to ``DomainConfigCreate``)."""

    name: str
    display_name: str
    tiers: list[TierDefinitionParams]
    personality_schema: PersonalitySchemaParams
    version: NotRequired[str]
    description: NotRequired[str]
    archetypes: NotRequired[list[ArchetypeParams]]
    name_patterns: NotRequired[list[NamePatternParams]]
    memory_templates: NotRequired[list[MemoryTemplateParams]]
    filterable_fields: NotRequired[list[FilterableFieldParams]]
    tier_values: NotRequired[list[TierValuesConfigParams]]
    image_generation: NotRequired[ImageGenerationParams | None]
    behavioral_guidelines: NotRequired[list[str] | None]
    chat_guardrails: NotRequired[list[str] | None]
    chat_temperature: NotRequired[float | None]
    entity_noun: NotRequired[str]
    is_draft: NotRequired[bool]
    tags: NotRequired[list[str]]
    frameworks: NotRequired[list[str]]


class GeneratedConfigResponse(TypedDict):
    """Response from ``POST /v1/domains/generate`` (the AI wizard)."""

    config: DomainConfigCreateParams
    explanation: str
    suggestions: list[str]
    confidence: float


class Domains:
    """Synchronous domains resource."""

    def __init__(self, client: SyncHTTPClient) -> None:
        self._client = client

    def list(self, *, page: int = 1, per_page: int = 20, **kwargs: Any) -> SyncPage[dict]:
        """GET /v1/domains"""
        from ensoul.pagination import SyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = self._client.get("/v1/domains", params=params)
        data = response.json()
        return SyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data.get("per_page", per_page),
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/domains",
            params=params,
            model=dict,
        )

    def get(self, domain_id: str) -> dict[str, Any]:
        """GET /v1/domains/{domain_id}"""
        response = self._client.get(f"/v1/domains/{domain_id}")
        return response.json()

    def create(self, config: DomainConfigCreateParams) -> dict[str, Any]:
        """POST /v1/domains — create a domain from a full ``DomainConfigCreateParams``.

        Step 1 of the dev workflow. To build the config with the AI wizard instead
        of by hand, call :meth:`generate` first and pass its ``["config"]`` here.
        """
        response = self._client.post("/v1/domains", json=dict(config))
        return response.json()

    def generate(
        self,
        description: str,
        *,
        context: dict[str, Any] | None = None,
        target_sections: list[str] | None = None,
    ) -> GeneratedConfigResponse:
        """POST /v1/domains/generate — AI wizard (requires PRO tier).

        Generate a domain configuration from a natural-language ``description``
        using Claude. The returned ``["config"]`` is a ready-to-use
        :class:`DomainConfigCreateParams` that can be passed straight to
        :meth:`create`.
        """
        body: dict[str, Any] = {"description": description}
        if context is not None:
            body["context"] = context
        if target_sections is not None:
            body["target_sections"] = target_sections
        response = self._client.post("/v1/domains/generate", json=body)
        return response.json()

    def update(self, domain_id: str, **kwargs: Any) -> dict[str, Any]:
        """PUT /v1/domains/{domain_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = self._client.put(f"/v1/domains/{domain_id}", json=body)
        return response.json()

    def delete(self, domain_id: str) -> None:
        """DELETE /v1/domains/{domain_id}"""
        self._client.delete(f"/v1/domains/{domain_id}")

    def validate(self, config: dict[str, Any]) -> dict[str, Any]:
        """POST /v1/domains/validate — validate a domain config (``DomainConfigCreate``)."""
        response = self._client.post("/v1/domains/validate", json=config)
        return response.json()


class AsyncDomains:
    """Async version of the domains resource."""

    def __init__(self, client: AsyncHTTPClient) -> None:
        self._client = client

    async def list(
        self, *, page: int = 1, per_page: int = 20, **kwargs: Any
    ) -> AsyncPage[dict]:
        """GET /v1/domains"""
        from ensoul.pagination import AsyncPage

        params: dict[str, Any] = {"page": page, "per_page": per_page}
        params.update({k: v for k, v in kwargs.items() if v is not None})
        response = await self._client.get("/v1/domains", params=params)
        data = response.json()
        return AsyncPage(
            items=data["items"],
            total=data["total"],
            page=data["page"],
            per_page=data.get("per_page", per_page),
            pages=data["pages"],
            client=self._client,
            method="GET",
            path="/v1/domains",
            params=params,
            model=dict,
        )

    async def get(self, domain_id: str) -> dict[str, Any]:
        """GET /v1/domains/{domain_id}"""
        response = await self._client.get(f"/v1/domains/{domain_id}")
        return response.json()

    async def create(self, config: DomainConfigCreateParams) -> dict[str, Any]:
        """POST /v1/domains — create a domain from a full ``DomainConfigCreateParams``.

        Step 1 of the dev workflow. To build the config with the AI wizard instead
        of by hand, call :meth:`generate` first and pass its ``["config"]`` here.
        """
        response = await self._client.post("/v1/domains", json=dict(config))
        return response.json()

    async def generate(
        self,
        description: str,
        *,
        context: dict[str, Any] | None = None,
        target_sections: list[str] | None = None,
    ) -> GeneratedConfigResponse:
        """POST /v1/domains/generate — AI wizard (requires PRO tier).

        Generate a domain configuration from a natural-language ``description``
        using Claude. The returned ``["config"]`` is a ready-to-use
        :class:`DomainConfigCreateParams` that can be passed straight to
        :meth:`create`.
        """
        body: dict[str, Any] = {"description": description}
        if context is not None:
            body["context"] = context
        if target_sections is not None:
            body["target_sections"] = target_sections
        response = await self._client.post("/v1/domains/generate", json=body)
        return response.json()

    async def update(self, domain_id: str, **kwargs: Any) -> dict[str, Any]:
        """PUT /v1/domains/{domain_id}"""
        body = {k: v for k, v in kwargs.items() if v is not None}
        response = await self._client.put(f"/v1/domains/{domain_id}", json=body)
        return response.json()

    async def delete(self, domain_id: str) -> None:
        """DELETE /v1/domains/{domain_id}"""
        await self._client.delete(f"/v1/domains/{domain_id}")

    async def validate(self, config: dict[str, Any]) -> dict[str, Any]:
        """POST /v1/domains/validate — validate a domain config (``DomainConfigCreate``)."""
        response = await self._client.post("/v1/domains/validate", json=config)
        return response.json()
