#!/usr/bin/env -S godot --headless --script
## Integration test harness for the Ensoul Godot SDK.
##
## Runs against a live API stack (Docker or production).
## Reads ENSOUL_INTEGRATION_URL, ENSOUL_INTEGRATION_PASSWORD,
## and optionally ENSOUL_INTEGRATION_DOMAIN from environment.
##
## Usage:
##   godot --headless --path . --script tests/test_integration.gd

extends SceneTree

var _url: String
var _password: String
var _domain: String
var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0


func _init() -> void:
	_url = OS.get_environment("ENSOUL_INTEGRATION_URL")
	if _url == "":
		print("SKIP: ENSOUL_INTEGRATION_URL not set")
		quit(0)
		return

	_password = OS.get_environment("ENSOUL_INTEGRATION_PASSWORD")
	_domain = OS.get_environment("ENSOUL_INTEGRATION_DOMAIN")

	await process_frame
	await _run_all()

	print("\n==================================================")
	print("INTEGRATION RESULTS: %d passed, %d failed, %d skipped" % [_passed, _failed, _skipped])
	print("==================================================")

	quit(1 if _failed > 0 else 0)


func _run_all() -> void:
	print("Running Ensoul GDScript SDK integration tests...")
	print("  URL: %s" % _url)

	# Health (always available)
	await _test_health()

	# Auth (requires password)
	if _password != "":
		await _test_auth_flow()
	else:
		_skip("auth_flow", "ENSOUL_INTEGRATION_PASSWORD not set")

	# Persona CRUD (requires domain)
	if _domain != "" and _password != "":
		await _test_persona_crud()
	else:
		_skip("persona_crud", "ENSOUL_INTEGRATION_DOMAIN or PASSWORD not set")


func _make_client_with_token() -> EnsoulClient:
	var client := EnsoulClient.new()
	root.add_child(client)
	client.configure("", _url)

	# Get a token via auth
	var username := OS.get_environment("ENSOUL_INTEGRATION_USERNAME")
	if username == "":
		username = "pro-user"
	var token_result := await client.auth.token(username, _password)
	if token_result.has("error"):
		push_warning("Auth failed: %s" % token_result["error"])
		return client

	var access_token: String = token_result["body"].get("access_token", "")
	# Reconfigure with bearer token
	client.configure("", _url, access_token)
	return client


func _pass(test_name: String) -> void:
	_passed += 1
	print("  PASS  %s" % test_name)


func _fail(test_name: String, reason: String = "") -> void:
	_failed += 1
	print("  FAIL  %s — %s" % [test_name, reason])


func _skip(test_name: String, reason: String = "") -> void:
	_skipped += 1
	print("  SKIP  %s (%s)" % [test_name, reason])


func _cleanup(client: EnsoulClient) -> void:
	client.queue_free()


# =========================================================================
# Tests
# =========================================================================

func _test_health() -> void:
	var client := EnsoulClient.new()
	root.add_child(client)
	client.configure("", _url)
	var result := await client.health.check()
	if result.has("error"):
		_fail("health", result["error"])
	elif result["body"].get("status") not in ["ok", "healthy"]:
		_fail("health", "expected status ok/healthy got %s" % str(result["body"].get("status", "?")))
	else:
		_pass("health")
	_cleanup(client)


func _test_auth_flow() -> void:
	var client := EnsoulClient.new()
	root.add_child(client)
	client.configure("", _url)

	var username := OS.get_environment("ENSOUL_INTEGRATION_USERNAME")
	if username == "":
		username = "pro-user"

	# Token exchange
	var token_result := await client.auth.token(username, _password)
	if token_result.has("error"):
		_fail("auth_token", token_result["error"])
		_cleanup(client)
		return
	_pass("auth_token")

	# Use token to call /auth/me
	var access_token: String = token_result["body"].get("access_token", "")
	client.configure("", _url, access_token)
	var me_result := await client.auth.me()
	if me_result.has("error"):
		_fail("auth_me", me_result["error"])
	else:
		_pass("auth_me")
	_cleanup(client)


func _test_persona_crud() -> void:
	var client := await _make_client_with_token()

	# List personas
	var page := await client.personas.list()
	if page.items.size() < 1:
		_fail("persona_list", "no personas found")
		_cleanup(client)
		return
	_pass("persona_list")

	# Get first persona
	var first_id: String = page.items[0].get("id", "")
	if first_id == "":
		_fail("persona_get", "no id on first persona")
		_cleanup(client)
		return

	var get_result := await client.personas.get_persona(first_id)
	if get_result.has("error"):
		_fail("persona_get", get_result["error"])
	else:
		_pass("persona_get")

	# Chat with persona
	var chat_result := await client.chat.send(first_id, "Hello from Godot SDK integration test!")
	if chat_result.has("error"):
		_fail("chat_send", chat_result["error"])
	elif chat_result["body"].get("response", "") == "":
		_fail("chat_send", "empty response")
	else:
		_pass("chat_send")

	_cleanup(client)
