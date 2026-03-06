"""Ensoul SDK Quickstart Example.

Set ENSOUL_API_KEY environment variable before running.

Usage:
    python examples/quickstart.py
"""

from __future__ import annotations

import asyncio
import json

from ensoul import AsyncEnsoul, Ensoul, NotFoundError


def sync_example() -> None:
    """Synchronous usage examples."""
    client = Ensoul()  # reads ENSOUL_API_KEY from env

    # List domains
    domains = client.domains.list()
    print("Domains:")
    for domain in domains.items:
        print(f"  {domain}")

    # Create a persona
    persona = client.personas.create(
        name="Research Participant",
        domain="example_domain",
        personality_data={"openness": 75, "conscientiousness": 60},
    )
    print(f"\nCreated persona: {persona.id}")

    # Chat
    response = client.chat.send(persona.id, "What are your thoughts on technology?")
    print(f"Response: {response.response}")

    # Streaming chat
    print("Streaming: ", end="")
    for event in client.chat.stream(persona.id, "Tell me more."):
        try:
            data = json.loads(event.data)
            if "chunk" in data:
                print(data["chunk"], end="", flush=True)
        except json.JSONDecodeError:
            pass
    print()

    # Auto-pagination — iterates all pages automatically
    print("\nAll personas:")
    for p in client.personas.list(per_page=10).auto_paging_iter():
        print(f"  {p.name}")

    # Error handling
    try:
        client.personas.get("nonexistent_id")
    except NotFoundError as e:
        print(f"\nExpected error: {e.message}")

    client.close()


async def async_example() -> None:
    """Async usage examples."""
    async with AsyncEnsoul() as client:
        personas = await client.personas.list()
        print("Async personas:")
        for p in personas.items:
            print(f"  {p.name}")


if __name__ == "__main__":
    sync_example()
    asyncio.run(async_example())
