# Migrating to Ensoul SDK 0.2.0

0.2.0 realigns every SDK with the live Ensoul API. The 0.1.x SDKs were generated
against a spec that had drifted: four resource namespaces pointed at routes that
no longer exist and returned 404 in production. 0.2.0 corrects those paths, adds
coverage for new endpoint groups, and bumps all seven SDKs in lockstep.

This is a breaking release. Pin to `0.1.x` if you are not ready to migrate.

## How to read this guide

Method names below use Python snake_case. The same changes apply to every SDK
under its own naming convention (camelCase for TypeScript, Kotlin, Swift,
PascalCase for C#, snake_case for C++ and Godot). The HTTP path and request or
response shape is what actually changed. The naming is per-language as before.

---

## Breaking changes

### `memory`
Rebased from the persona sub-path to a dedicated memory path.

- Base path `/v1/personas/{id}/memories...` is now `/v1/memory/{persona_id}...`.
- Knowledge query `/v1/personas/{id}/knowledge/query` is now `/v1/memory/{persona_id}/knowledge` (the `/query` suffix is gone).
- `MemoryCreate` body is now `{content, source, references}`.
- List returns a flat `MemoriesResponse` and takes `limit` / `offset`.
- The dead single-item `get` was removed. New methods: `stats`, `generate`,
  `working`, `update_access`, `clear`, `add_knowledge`, `get_knowledge`.

### `info`
Collapsed from four methods to one.

- `config()`, `rate_limits()`, `tiers()`, `features()` previously hit `/v1/info/*`,
  which never existed. There is a single `GET /v1/api/info` that returns one blob.
- Use `get_info()` and read the sub-section you need from the returned object.

### `aggregate`
Method and cardinality changed.

- `query()` was `POST /v1/aggregate/query` with a JSON body. It is replaced by
  `count()` and `stats()`, both `GET` with query-string parameters (no body).
- `simulate` corrected to `simulation`.

### `sessions`
- Rebased to `/v1/sessions/*`.
- `POST /v1/sessions` (create) has no persona in the path. `persona_id` moved
  into the request body. Calls that passed it positionally must move it.
- Note: `/v1/chat/sessions` is a separate persisted-chat feature, not this
  namespace. See the new `chat` session methods below.

### Smaller path fixes
- `simulations.stop` removed (no live route). Use `pause`.
- `frameworks.validate` (POST) is now `validations` (GET).
- `domains.validate(id)` is now `validate(config)` — `POST /v1/domains/validate`
  with a `DomainConfigCreate` body.

### Server schema note: `ValidationError`
The server's `ValidationError` schema dropped its `ctx` and `input` fields. The
SDKs are unaffected — the SDK `ValidationError` is a hand-written exception that
parses any 422 body generically into `details`, it never typed those two fields.
No code change is required on your side.

### Authentication is enforced on more endpoints
Roughly fifty endpoints that were open in the 0.1.x era now require a key. Pass
`ENSOUL_API_KEY` (or an explicit key) for any call that previously worked without
one. Unauthenticated calls to a secured route now return 401.

---

## New in 0.2.0

All new methods return the raw decoded response body, matching the SDK's existing
untyped methods such as `simulations.start`. They are not typed models.

### `audit` (new namespace)
- `get_event(event_id)`, `get_commitment(commitment_id)`, `get_proof(event_id)` —
  the Merkle-committed audit trail.
- `verify(audit_event_id, content_hash=None)` — `POST /v1/verify`.
- `get_signing_key()` — the public ECDSA key from
  `/.well-known/ensoul-signing-key.pem`, returned as raw PEM text (not JSON, no
  auth required).

### `chat` persisted sessions
Nine methods against `/v1/chat/sessions/*`: `create_session`, `list_sessions`,
`session_stats`, `get_session`, `update_session`, `delete_session`,
`archive_session`, `add_message`, `get_messages`.

### `simulations`
`list_participants`, `add_participants`, `get_event_ticks`.

---

## Installation

0.2.0 ships from GitHub registries, not PyPI or npmjs. See the mirror README for
per-language steps. Quick reference:

```bash
# Python (GitHub Releases wheel)
pip install https://github.com/ensoul-ai/ensoul-sdk/releases/download/v0.2.0/ensoul-0.2.0-py3-none-any.whl

# TypeScript (GitHub npm — needs .npmrc pointing at npm.pkg.github.com)
npm install @ensoul-ai/sdk@0.2.0
```

Swift, Kotlin, Unity, C++, and Godot resolve the `v0.2.0` git tag. See the mirror
README for the exact dependency declaration per language.
