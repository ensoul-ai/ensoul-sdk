"""Create a domain with the Ensoul SDK.

A domain is the first thing you build: it defines the tier hierarchy,
personality schema, and archetypes that every persona in it inherits.

There are two ways to create one:

1. AI wizard (easy path) — describe the domain in plain English and let
   ``domains.generate`` produce a full config, then create it. Requires the
   PRO tier and a server with the Claude API configured.
2. By hand — build a typed ``DomainConfigCreateParams`` and pass it to
   ``domains.create``. Works on any tier.

Set ENSOUL_API_KEY (and optionally ENSOUL_BASE_URL) before running.

Usage:
    python examples/create_domain.py
"""

from __future__ import annotations

from ensoul import Ensoul
from ensoul.resources.domains import DomainConfigCreateParams


def create_with_ai_wizard(client: Ensoul) -> None:
    """Step 1, easy path: generate a domain config from a description."""
    result = client.domains.generate(
        "A fantasy RPG world with playable races (elves, dwarves, humans) and "
        "classes (warrior, mage, rogue). Characters have courage and wisdom traits.",
        context={"inspiration": "tabletop RPGs"},
    )
    print(f"Generated config (confidence {result['confidence']:.2f}):")
    print(f"  explanation: {result['explanation']}")

    # The generated config is ready to create as-is.
    domain = client.domains.create(result["config"])
    print(f"Created generated domain: {domain}")


def create_by_hand(client: Ensoul) -> None:
    """Step 1, manual path: build a typed config and create it."""
    config: DomainConfigCreateParams = {
        "name": "example_world",
        "display_name": "Example World",
        "description": "A minimal hand-built domain.",
        "tiers": [
            {"level": 0, "name": "world", "description": "Root tier"},
            {"level": 1, "name": "character", "description": "Individuals"},
        ],
        "personality_schema": {
            "fields": [
                {
                    "path": "traits.courage",
                    "field_type": "float",
                    "range_min": 0.0,
                    "range_max": 100.0,
                    "description": "How brave the character is",
                },
            ],
        },
        "archetypes": [
            {"id": "hero", "name": "Hero", "tier": 1, "personality_modifiers": {"traits.courage": 30}},
        ],
        "entity_noun": "character",
    }

    domain = client.domains.create(config)
    print(f"Created hand-built domain: {domain}")


def main() -> None:
    client = Ensoul()  # reads ENSOUL_API_KEY / ENSOUL_BASE_URL from env
    try:
        create_by_hand(client)
        # Uncomment if your account has the PRO tier and the server has the
        # Claude API configured:
        # create_with_ai_wizard(client)
    finally:
        client.close()


if __name__ == "__main__":
    main()
