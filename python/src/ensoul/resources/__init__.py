"""Resource modules for the Ensoul SDK."""

from __future__ import annotations

from ensoul.resources.aggregate import Aggregate, AsyncAggregate
from ensoul.resources.auth_resource import AsyncAuthResource, AuthResource
from ensoul.resources.chat import AsyncChat, Chat
from ensoul.resources.domains import AsyncDomains, Domains
from ensoul.resources.frameworks import AsyncFrameworks, Frameworks
from ensoul.resources.health import AsyncHealth, Health
from ensoul.resources.info import AsyncInfo, Info
from ensoul.resources.memory import AsyncMemory, Memory
from ensoul.resources.personas import AsyncPersonas, Personas
from ensoul.resources.sessions import AsyncSessions, Sessions
from ensoul.resources.simulations import AsyncSimulations, Simulations

__all__ = [
    "Aggregate",
    "AsyncAggregate",
    "AuthResource",
    "AsyncAuthResource",
    "Chat",
    "AsyncChat",
    "Domains",
    "AsyncDomains",
    "Frameworks",
    "AsyncFrameworks",
    "Health",
    "AsyncHealth",
    "Info",
    "AsyncInfo",
    "Memory",
    "AsyncMemory",
    "Personas",
    "AsyncPersonas",
    "Sessions",
    "AsyncSessions",
    "Simulations",
    "AsyncSimulations",
]
