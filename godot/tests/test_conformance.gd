#!/usr/bin/env -S godot --headless --script
## Conformance test harness for the Ensoul Godot SDK.
##
## Runs against the shared mock server started by run_conformance.py.
## Reads ENSOUL_CONFORMANCE_URL from environment. Prints PASS/FAIL per scenario
## and exits with code 0 (all pass) or 1 (any fail).
##
## Usage:
##   godot --headless --path . --script tests/test_conformance.gd

extends SceneTree

var _url: String
var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0


func _init() -> void:
	_url = OS.get_environment("ENSOUL_CONFORMANCE_URL")
	if _url == "":
		print("SKIP: ENSOUL_CONFORMANCE_URL not set")
		quit(0)
		return

	# Run tests after a single frame so the scene tree is ready
	await process_frame
	await _run_all()

	print("\n==================================================")
	print("CONFORMANCE RESULTS: %d passed, %d failed, %d skipped" % [_passed, _failed, _skipped])
	print("==================================================")

	quit(1 if _failed > 0 else 0)


func _run_all() -> void:
	# --- Personas ---
	await _test_persona_create()
	await _test_persona_get()
	await _test_persona_list_pagination()
	await _test_persona_not_found()
	await _test_persona_update()
	await _test_persona_delete()

	# --- Chat ---
	await _test_chat_send()
	await _test_chat_get_conversations()
	_skip("chat_stream_sse", "SSE streaming requires _process loop, not available in headless")

	# --- Domains ---
	await _test_domain_list()
	await _test_domain_get()

	# --- Simulations ---
	await _test_simulation_create()
	await _test_simulation_start()
	await _test_simulation_list_participants()
	await _test_simulation_add_participants()
	await _test_simulation_event_ticks()

	# --- Chat Sessions ---
	await _test_chat_create_session()
	await _test_chat_list_sessions()
	await _test_chat_session_stats()
	await _test_chat_get_session()
	await _test_chat_update_session()
	await _test_chat_archive_session()
	await _test_chat_delete_session()
	await _test_chat_add_message()
	await _test_chat_get_messages()

	# --- Audit ---
	await _test_audit_get_event()
	await _test_audit_get_commitment()
	await _test_audit_get_proof()
	await _test_audit_verify()
	await _test_audit_signing_key()

	# --- Memory ---
	await _test_memory_create()
	await _test_memory_delete()

	# --- Sessions ---
	await _test_session_create()

	# --- Aggregate ---
	await _test_aggregate_count()

	# --- Health ---
	await _test_health_check()

	# --- Info ---
	await _test_info_config()

	# --- Auth Resources ---
	await _test_auth_token_exchange()
	await _test_auth_me()

	# --- Frameworks ---
	await _test_framework_update()

	# --- Errors ---
	await _test_error_authentication()
	await _test_error_rate_limit()
	await _test_error_validation()
	await _test_error_server()
	await _test_error_authorization_forbidden()
	await _test_error_retry_503()

	# --- Auth Headers ---
	await _test_auth_api_key_header()
	await _test_auth_no_credentials()
	await _test_auth_bearer_token()

	# --- Client Config ---
	await _test_client_custom_base_url()

	# --- Pagination ---
	await _test_pagination_auto_fetch()


# =========================================================================
# Helpers
# =========================================================================

func _make_client(api_key: String = "sk_test_123", bearer_token: String = "",
		max_retries: int = 0, extra_headers: Array[String] = []) -> EnsoulClient:
	var client := EnsoulClient.new()
	root.add_child(client)
	client.configure(api_key, _url, bearer_token, 30.0, max_retries)
	if not extra_headers.is_empty():
		client._http.set_extra_headers(extra_headers)
	return client


func _cleanup(client: EnsoulClient) -> void:
	client.queue_free()


func _pass(test_name: String) -> void:
	_passed += 1
	print("  PASS  %s" % test_name)


func _fail(test_name: String, reason: String = "") -> void:
	_failed += 1
	var msg := "  FAIL  %s" % test_name
	if reason != "":
		msg += " — %s" % reason
	print(msg)


func _skip(test_name: String, reason: String = "") -> void:
	_skipped += 1
	print("  SKIP  %s (%s)" % [test_name, reason])


# =========================================================================
# Personas
# =========================================================================

func _test_persona_create() -> void:
	var c := _make_client()
	var result := await c.personas.create("Test Persona", "test_domain", {"trait_a": 75, "trait_b": 50})
	if result.has("error"):
		_fail("persona_create", result.get("error", ""))
	elif result.body.get("id", "") == "" or result.body.get("name") != "Test Persona":
		_fail("persona_create", "unexpected body: %s" % str(result.body))
	else:
		_pass("persona_create")
	_cleanup(c)


func _test_persona_get() -> void:
	var c := _make_client()
	var result := await c.personas.get_persona("p_test_001")
	if result.has("error"):
		_fail("persona_get", result.get("error", ""))
	elif result.body.get("id") != "p_test_001" or result.body.get("name") != "Test Persona" \
			or result.body.get("domain") != "test_domain":
		_fail("persona_get", "unexpected body")
	else:
		_pass("persona_get")
	_cleanup(c)


func _test_persona_list_pagination() -> void:
	var c := _make_client()
	var page := await c.personas.list(1, 10)
	if page.items.size() < 1:
		_fail("persona_list_pagination", "no items")
	elif page.total != 25 or page.page != 1 or page.per_page != 10 or page.pages != 3:
		_fail("persona_list_pagination", "pagination metadata mismatch: total=%d page=%d per_page=%d pages=%d" % [page.total, page.page, page.per_page, page.pages])
	else:
		_pass("persona_list_pagination")
	_cleanup(c)


func _test_persona_not_found() -> void:
	var c := _make_client()
	var result := await c.personas.get_persona("nonexistent_persona_id")
	if not result.has("error"):
		_fail("persona_not_found", "expected error")
	elif result.get("status_code", 0) != 404:
		_fail("persona_not_found", "expected 404 got %s" % str(result.get("status_code", "?")))
	else:
		_pass("persona_not_found")
	_cleanup(c)


func _test_persona_update() -> void:
	var c := _make_client()
	var result := await c.personas.update("p_test_001", {"name": "Updated Persona"})
	if result.has("error"):
		_fail("persona_update", result.get("error", ""))
	elif result.body.get("name") != "Updated Persona" or result.body.get("updated_at", "") == "":
		_fail("persona_update", "name not updated or missing updated_at")
	else:
		_pass("persona_update")
	_cleanup(c)


func _test_persona_delete() -> void:
	var c := _make_client()
	var result := await c.personas.delete("p_test_001")
	# 204 returns empty body — success if no error
	if result.has("error"):
		_fail("persona_delete", result.get("error", ""))
	else:
		_pass("persona_delete")
	_cleanup(c)


# =========================================================================
# Chat
# =========================================================================

func _test_chat_send() -> void:
	var c := _make_client()
	var result := await c.chat.send("p_test_001", "Hello, how are you?")
	if result.has("error"):
		_fail("chat_send", result.get("error", ""))
	elif result.body.get("response", "") == "" or result.body.get("conversation_id", "") == "":
		_fail("chat_send", "missing response or conversation_id")
	else:
		var usage = result.body.get("token_usage", {})
		if usage.get("total_tokens", 0) <= 0:
			_fail("chat_send", "token_usage.total_tokens <= 0")
		else:
			_pass("chat_send")
	_cleanup(c)


func _test_chat_get_conversations() -> void:
	var c := _make_client()
	var page := await c.chat.get_conversations("p_test_001")
	if page.items.size() < 1:
		_fail("chat_get_conversations", "no items")
	elif page.total != 2:
		_fail("chat_get_conversations", "expected total=2 got %d" % page.total)
	else:
		_pass("chat_get_conversations")
	_cleanup(c)


# =========================================================================
# Domains
# =========================================================================

func _test_domain_list() -> void:
	var c := _make_client()
	var page := await c.domains.list()
	if page.items.size() < 1:
		_fail("domain_list", "no items")
	else:
		_pass("domain_list")
	_cleanup(c)


func _test_domain_get() -> void:
	var c := _make_client()
	var result := await c.domains.get_domain("d_test_001")
	if result.has("error"):
		_fail("domain_get", result.get("error", ""))
	elif result.body.get("id") != "d_test_001" or result.body.get("name") != "Test Domain" \
			or result.body.get("field_count", 0) <= 0:
		_fail("domain_get", "unexpected body or missing field_count")
	else:
		_pass("domain_get")
	_cleanup(c)


# =========================================================================
# Simulations
# =========================================================================

func _test_simulation_create() -> void:
	var c := _make_client()
	var result := await c.simulations.create("Test Simulation", "d_test_001")
	if result.has("error"):
		_fail("simulation_create", result.get("error", ""))
	elif result.body.get("id") != "sim_test_001" or result.body.get("status") != "created":
		_fail("simulation_create", "unexpected body")
	else:
		_pass("simulation_create")
	_cleanup(c)


func _test_simulation_start() -> void:
	var c := _make_client()
	var result := await c.simulations.start("sim_test_001", 50)
	if result.has("error"):
		_fail("simulation_start", result.get("error", ""))
	elif result.body.get("status") != "running" or result.body.get("ticks_requested") != 50:
		_fail("simulation_start", "unexpected body")
	else:
		_pass("simulation_start")
	_cleanup(c)


# =========================================================================
# Memory
# =========================================================================

func _test_memory_create() -> void:
	var c := _make_client()
	var result := await c.memory.create("p_test_001", "Remembers meeting a friend at the park", "user")
	if result.has("error"):
		_fail("memory_create", result.get("error", ""))
	elif result.body.get("id") != "mem_test_001" or result.body.get("persona_id") != "p_test_001":
		_fail("memory_create", "unexpected body")
	else:
		_pass("memory_create")
	_cleanup(c)


func _test_memory_delete() -> void:
	var c := _make_client()
	var result := await c.memory.delete("p_test_001", "mem_test_001")
	if result.has("error"):
		_fail("memory_delete", result.get("error", ""))
	else:
		_pass("memory_delete")
	_cleanup(c)


# =========================================================================
# Sessions
# =========================================================================

func _test_session_create() -> void:
	var c := _make_client()
	var result := await c.sessions.create(0)
	if result.has("error"):
		_fail("session_create", result.get("error", ""))
	elif result.body.get("id") != "sess_test_001" or result.body.get("tier") != 0:
		_fail("session_create", "unexpected body")
	else:
		_pass("session_create")
	_cleanup(c)


# =========================================================================
# Aggregate
# =========================================================================

func _test_aggregate_count() -> void:
	var c := _make_client()
	var result := await c.aggregate.count("demo")
	if result.has("error"):
		_fail("aggregate_count", result.get("error", ""))
	elif result.body.get("sample_size") != 500 or result.body.get("confidence") != 0.95:
		_fail("aggregate_count", "unexpected body")
	else:
		_pass("aggregate_count")
	_cleanup(c)


# =========================================================================
# Health
# =========================================================================

func _test_health_check() -> void:
	var c := _make_client()
	var result := await c.health.check()
	if result.has("error"):
		_fail("health_check", result.get("error", ""))
	elif result.body.get("status") != "ok" or result.body.get("version", "") == "" \
			or result.body.get("uptime_seconds", 0) <= 0:
		_fail("health_check", "missing status, version, or uptime_seconds")
	else:
		_pass("health_check")
	_cleanup(c)


# =========================================================================
# Info
# =========================================================================

func _test_info_config() -> void:
	var c := _make_client()
	var result := await c.info.config()
	if result.has("error"):
		_fail("info_config", result.get("error", ""))
	elif result.body.get("api_version") != "1.0.0" or result.body.get("max_batch_size") != 100:
		_fail("info_config", "unexpected body")
	else:
		_pass("info_config")
	_cleanup(c)


# =========================================================================
# Auth Resources
# =========================================================================

func _test_auth_token_exchange() -> void:
	var c := _make_client("", "", 0)  # no auth needed for token exchange
	var result := await c.auth.token("testuser", "testpass")
	if result.has("error"):
		_fail("auth_token_exchange", result.get("error", ""))
	elif result.body.get("access_token", "") == "" or result.body.get("token_type") != "bearer" \
			or result.body.get("expires_in") != 3600 or result.body.get("refresh_token", "") == "":
		_fail("auth_token_exchange", "unexpected body")
	else:
		_pass("auth_token_exchange")
	_cleanup(c)


func _test_auth_me() -> void:
	var c := _make_client()
	var result := await c.auth.me()
	if result.has("error"):
		_fail("auth_me", result.get("error", ""))
	elif result.body.get("consumer_id") != "user_test_001" or result.body.get("username") != "testuser" \
			or typeof(result.body.get("permissions")) != TYPE_ARRAY or result.body.get("permissions", []).size() < 1:
		_fail("auth_me", "unexpected body")
	else:
		_pass("auth_me")
	_cleanup(c)


# =========================================================================
# Frameworks
# =========================================================================

func _test_framework_update() -> void:
	var c := _make_client()
	var result := await c.frameworks.update("fw_test_001", {"name": "Big Five Updated"})
	if result.has("error"):
		_fail("framework_update", result.get("error", ""))
	elif result.body.get("id") != "fw_test_001" or result.body.get("name") != "Big Five Updated":
		_fail("framework_update", "unexpected body")
	else:
		_pass("framework_update")
	_cleanup(c)


# =========================================================================
# Error Handling
# =========================================================================

func _test_error_authentication() -> void:
	var c := _make_client("", "", 0)  # no credentials
	var raw := await c._http.get_req("/personas", {"page": 1, "per_page": 20})
	if not raw.has("error"):
		_fail("error_authentication", "expected 401 error")
	elif raw.get("status_code", 0) != 401:
		_fail("error_authentication", "expected status_code=401 got %s" % str(raw.get("status_code", "?")))
	else:
		_pass("error_authentication")
	_cleanup(c)


func _test_error_rate_limit() -> void:
	var c := _make_client("sk_test_123", "", 0, ["X-Trigger-RateLimit: true"])
	var result := await c._http.get_req("/personas", {"page": 1, "per_page": 20})
	if not result.has("error"):
		_fail("error_rate_limit", "expected 429 error")
	elif result.get("status_code", 0) != 429:
		_fail("error_rate_limit", "expected status_code=429 got %s" % str(result.get("status_code", "?")))
	else:
		_pass("error_rate_limit")
	_cleanup(c)


func _test_error_validation() -> void:
	var c := _make_client()
	var result := await c.personas.create("", "")
	if not result.has("error"):
		_fail("error_validation", "expected 422 error")
	elif result.get("status_code", 0) != 422:
		_fail("error_validation", "expected status_code=422 got %s" % str(result.get("status_code", "?")))
	else:
		_pass("error_validation")
	_cleanup(c)


func _test_error_server() -> void:
	var c := _make_client("sk_test_123", "", 0, ["X-Trigger-ServerError: true"])
	var result := await c._http.get_req("/personas", {"page": 1, "per_page": 20})
	if not result.has("error"):
		_fail("error_server", "expected 500 error")
	elif result.get("status_code", 0) != 500:
		_fail("error_server", "expected status_code=500 got %s" % str(result.get("status_code", "?")))
	else:
		_pass("error_server")
	_cleanup(c)


func _test_error_authorization_forbidden() -> void:
	var c := _make_client("sk_test_123", "", 0, ["X-Trigger-Forbidden: true"])
	var result := await c._http.get_req("/personas", {"page": 1, "per_page": 20})
	if not result.has("error"):
		_fail("error_authorization_forbidden", "expected 403 error")
	elif result.get("status_code", 0) != 403:
		_fail("error_authorization_forbidden", "expected status_code=403")
	else:
		_pass("error_authorization_forbidden")
	_cleanup(c)


func _test_error_retry_503() -> void:
	# max_retries=2 so first 503 is retried, second attempt succeeds
	var c := _make_client("sk_test_123", "", 2, ["X-Trigger-503-Once: true", "X-SDK-Language: gdscript-retry-test"])
	var page := await c.personas.list()
	if page.items.size() < 1:
		_fail("error_retry_503", "expected items after retry, got %d" % page.items.size())
	else:
		_pass("error_retry_503")
	_cleanup(c)


# =========================================================================
# Auth Headers
# =========================================================================

func _test_auth_api_key_header() -> void:
	var c := _make_client("sk_test_123")
	var page := await c.personas.list()
	if page.items.size() < 1:
		_fail("auth_api_key_header", "no items — API key may not have been sent")
	else:
		_pass("auth_api_key_header")
	_cleanup(c)


func _test_auth_no_credentials() -> void:
	var c := _make_client("", "", 0)
	var result := await c._http.get_req("/personas", {"page": 1, "per_page": 20})
	if not result.has("error"):
		_fail("auth_no_credentials", "expected 401")
	elif result.get("status_code", 0) != 401:
		_fail("auth_no_credentials", "expected 401 got %s" % str(result.get("status_code", "?")))
	else:
		_pass("auth_no_credentials")
	_cleanup(c)


func _test_auth_bearer_token() -> void:
	var c := _make_client("", "test_token_123", 0)
	var page := await c.personas.list()
	if page.items.size() < 1:
		_fail("auth_bearer_token", "no items — bearer token may not have been sent")
	else:
		_pass("auth_bearer_token")
	_cleanup(c)


# =========================================================================
# Client Configuration
# =========================================================================

func _test_client_custom_base_url() -> void:
	var c := _make_client("sk_test_123")
	var page := await c.personas.list()
	if page.items.size() < 1:
		_fail("client_custom_base_url", "no items from custom base URL")
	else:
		_pass("client_custom_base_url")
	_cleanup(c)


# =========================================================================
# Pagination
# =========================================================================

func _test_pagination_auto_fetch() -> void:
	var c := _make_client()
	var page := await c.frameworks.list(1, 2)
	var all := await page.all_items()
	if all.size() != 3:
		_fail("pagination_auto_fetch", "expected 3 items got %d" % all.size())
	else:
		_pass("pagination_auto_fetch")
	_cleanup(c)


# =========================================================================
# Simulation Participants
# =========================================================================

func _test_simulation_list_participants() -> void:
	var c := _make_client()
	var result := await c.simulations.list_participants("sim_test_001")
	if result.has("error"):
		_fail("simulation_list_participants", result.get("error", ""))
	elif result.body.get("total") != 2 or result.body.get("items", []).size() != 2:
		_fail("simulation_list_participants", "unexpected body")
	else:
		_pass("simulation_list_participants")
	_cleanup(c)


func _test_simulation_add_participants() -> void:
	var c := _make_client()
	var result := await c.simulations.add_participants("sim_test_001", ["persona_test_003"])
	if result.has("error"):
		_fail("simulation_add_participants", result.get("error", ""))
	elif result.body.get("id") != "sim_test_001":
		_fail("simulation_add_participants", "unexpected body")
	else:
		_pass("simulation_add_participants")
	_cleanup(c)


func _test_simulation_event_ticks() -> void:
	var c := _make_client()
	var result := await c.simulations.get_event_ticks("sim_test_001")
	if result.has("error"):
		_fail("simulation_event_ticks", result.get("error", ""))
	elif result.body.get("ticks", []).size() != 3:
		_fail("simulation_event_ticks", "expected 3 ticks")
	else:
		_pass("simulation_event_ticks")
	_cleanup(c)


# =========================================================================
# Chat Sessions
# =========================================================================

func _test_chat_create_session() -> void:
	var c := _make_client()
	var result := await c.chat.create_session("team_test_001", "user_test_001", "d_test_001")
	if result.has("error"):
		_fail("chat_create_session", result.get("error", ""))
	elif result.body.get("id") != "csess_test_001" or result.body.get("is_archived") != false:
		_fail("chat_create_session", "unexpected body")
	else:
		_pass("chat_create_session")
	_cleanup(c)


func _test_chat_list_sessions() -> void:
	var c := _make_client()
	var result := await c.chat.list_sessions("user_test_001")
	if result.has("error"):
		_fail("chat_list_sessions", result.get("error", ""))
	elif result.body.get("pagination", {}).get("total") != 1 or result.body.get("sessions", []).size() < 1:
		_fail("chat_list_sessions", "unexpected body")
	else:
		_pass("chat_list_sessions")
	_cleanup(c)


func _test_chat_session_stats() -> void:
	var c := _make_client()
	var result := await c.chat.session_stats("team_test_001", "2025-01-01", "2025-01-31")
	if result.has("error"):
		_fail("chat_session_stats", result.get("error", ""))
	elif result.body.get("total") != 7:
		_fail("chat_session_stats", "expected total=7")
	else:
		_pass("chat_session_stats")
	_cleanup(c)


func _test_chat_get_session() -> void:
	var c := _make_client()
	var result := await c.chat.get_session("csess_test_001")
	if result.has("error"):
		_fail("chat_get_session", result.get("error", ""))
	elif result.body.get("id") != "csess_test_001" or result.body.get("messages", []).size() < 1:
		_fail("chat_get_session", "unexpected body")
	else:
		_pass("chat_get_session")
	_cleanup(c)


func _test_chat_update_session() -> void:
	var c := _make_client()
	var result := await c.chat.update_session("csess_test_001", "New Title")
	if result.has("error"):
		_fail("chat_update_session", result.get("error", ""))
	elif result.body.get("id") != "csess_test_001":
		_fail("chat_update_session", "unexpected body")
	else:
		_pass("chat_update_session")
	_cleanup(c)


func _test_chat_archive_session() -> void:
	var c := _make_client()
	var result := await c.chat.archive_session("csess_test_001")
	if result.has("error"):
		_fail("chat_archive_session", result.get("error", ""))
	elif result.body.get("id") != "csess_test_001":
		_fail("chat_archive_session", "unexpected body")
	else:
		_pass("chat_archive_session")
	_cleanup(c)


func _test_chat_delete_session() -> void:
	var c := _make_client()
	var result := await c.chat.delete_session("csess_test_001")
	# 204 returns empty body — success if no error
	if result.has("error"):
		_fail("chat_delete_session", result.get("error", ""))
	else:
		_pass("chat_delete_session")
	_cleanup(c)


func _test_chat_add_message() -> void:
	var c := _make_client()
	var result := await c.chat.add_message("csess_test_001", "assistant", "Hello!")
	if result.has("error"):
		_fail("chat_add_message", result.get("error", ""))
	elif result.body.get("id") != "msg_test_002" or result.body.get("role") != "assistant":
		_fail("chat_add_message", "unexpected body")
	else:
		_pass("chat_add_message")
	_cleanup(c)


func _test_chat_get_messages() -> void:
	var c := _make_client()
	var result := await c.chat.get_messages("csess_test_001")
	if result.has("error"):
		_fail("chat_get_messages", result.get("error", ""))
	elif typeof(result.body) != TYPE_ARRAY or result.body.size() != 2 \
			or result.body[0].get("role") != "user":
		_fail("chat_get_messages", "unexpected body")
	else:
		_pass("chat_get_messages")
	_cleanup(c)


# =========================================================================
# Audit
# =========================================================================

func _test_audit_get_event() -> void:
	var c := _make_client()
	var result := await c.audit.get_event("evt_test_001")
	if result.has("error"):
		_fail("audit_get_event", result.get("error", ""))
	elif result.body.get("event_id") != "evt_test_001":
		_fail("audit_get_event", "unexpected body")
	else:
		_pass("audit_get_event")
	_cleanup(c)


func _test_audit_get_commitment() -> void:
	var c := _make_client()
	var result := await c.audit.get_commitment("cmt_test_001")
	if result.has("error"):
		_fail("audit_get_commitment", result.get("error", ""))
	elif result.body.get("commitment_id") != "cmt_test_001" or result.body.get("event_count") != 42:
		_fail("audit_get_commitment", "unexpected body")
	else:
		_pass("audit_get_commitment")
	_cleanup(c)


func _test_audit_get_proof() -> void:
	var c := _make_client()
	var result := await c.audit.get_proof("evt_test_001")
	if result.has("error"):
		_fail("audit_get_proof", result.get("error", ""))
	elif result.body.get("verified") != true or result.body.get("proof_path", []).size() != 2:
		_fail("audit_get_proof", "unexpected body")
	else:
		_pass("audit_get_proof")
	_cleanup(c)


func _test_audit_verify() -> void:
	var c := _make_client()
	var result := await c.audit.verify("evt_test_001")
	if result.has("error"):
		_fail("audit_verify", result.get("error", ""))
	elif result.body.get("verified") != true:
		_fail("audit_verify", "expected verified=true")
	else:
		_pass("audit_verify")
	_cleanup(c)


func _test_audit_signing_key() -> void:
	var c := _make_client()
	var result := await c.audit.get_signing_key()
	if result.has("error"):
		_fail("audit_signing_key", result.get("error", ""))
	elif not str(result.get("text", "")).contains("BEGIN PUBLIC KEY"):
		_fail("audit_signing_key", "PEM text missing public key header")
	else:
		_pass("audit_signing_key")
	_cleanup(c)
