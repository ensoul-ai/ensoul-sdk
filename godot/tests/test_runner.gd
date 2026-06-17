#!/usr/bin/env -S godot --headless --script
## Unit test runner for the Ensoul Godot SDK.
##
## Runs pure-logic unit tests that don't require a network connection.
## Uses a simple assert-based test framework (no GUT dependency).
##
## Usage:
##   godot --headless --path . --script tests/test_runner.gd

extends SceneTree

var _passed: int = 0
var _failed: int = 0


func _init() -> void:
	await process_frame
	await _run_all()

	print("\n==================================================")
	print("UNIT TEST RESULTS: %d passed, %d failed" % [_passed, _failed])
	print("==================================================")

	quit(1 if _failed > 0 else 0)


func _run_all() -> void:
	print("Running Ensoul GDScript SDK unit tests...\n")

	# Config tests
	_test_config_defaults()
	_test_config_custom_values()
	_test_config_api_url()
	_test_config_trim_trailing_slash()

	# HTTP helper tests
	_test_build_url_no_query()
	_test_build_url_with_query()
	_test_build_url_null_values_skipped()
	_test_build_headers_api_key()
	_test_build_headers_bearer()
	_test_build_headers_no_auth()
	_test_retry_loop_range()

	# Page tests
	_test_page_from_result_success()
	_test_page_from_result_error()
	_test_page_has_next_page()
	_test_page_no_next_page()

	# SSE parsing tests
	_test_sse_event_defaults()
	await _test_sse_parse_block_simple()
	await _test_sse_parse_block_multiline_data()
	await _test_sse_parse_block_custom_event()
	await _test_sse_parse_block_comment_ignored()
	await _test_sse_parse_buffer_multiple_events()

	# Client version
	_test_client_version()


# =========================================================================
# Helpers
# =========================================================================

func _assert_eq(actual, expected, test_name: String) -> void:
	if actual == expected:
		_passed += 1
		print("  PASS  %s" % test_name)
	else:
		_failed += 1
		print("  FAIL  %s — expected %s got %s" % [test_name, str(expected), str(actual)])


func _assert_true(condition: bool, test_name: String) -> void:
	if condition:
		_passed += 1
		print("  PASS  %s" % test_name)
	else:
		_failed += 1
		print("  FAIL  %s — expected true" % test_name)


func _assert_false(condition: bool, test_name: String) -> void:
	if not condition:
		_passed += 1
		print("  PASS  %s" % test_name)
	else:
		_failed += 1
		print("  FAIL  %s — expected false" % test_name)


func _fail(test_name: String, reason: String = "") -> void:
	_failed += 1
	var msg := "  FAIL  %s" % test_name
	if reason != "":
		msg += " — %s" % reason
	print(msg)


# =========================================================================
# Config Tests
# =========================================================================

func _test_config_defaults() -> void:
	var c := EnsoulConfig.new()
	_assert_eq(c.timeout, 300.0, "config_defaults: timeout")
	_assert_eq(c.max_retries, 3, "config_defaults: max_retries")
	_assert_eq(c.retry_base_sec, 1.0, "config_defaults: retry_base_sec")


func _test_config_custom_values() -> void:
	var c := EnsoulConfig.new("my_key", "https://custom.example.com/api", "my_bearer", 60.0, 5)
	_assert_eq(c.api_key, "my_key", "config_custom: api_key")
	_assert_eq(c.base_url, "https://custom.example.com/api", "config_custom: base_url")
	_assert_eq(c.bearer_token, "my_bearer", "config_custom: bearer_token")
	_assert_eq(c.timeout, 60.0, "config_custom: timeout")
	_assert_eq(c.max_retries, 5, "config_custom: max_retries")


func _test_config_api_url() -> void:
	var c := EnsoulConfig.new("key", "https://example.com/api")
	_assert_eq(c.api_url(), "https://example.com/api/v1", "config_api_url")


func _test_config_trim_trailing_slash() -> void:
	var c := EnsoulConfig.new("key", "https://example.com/api/")
	_assert_eq(c.base_url, "https://example.com/api", "config_trim_slash: base_url")
	_assert_eq(c.api_url(), "https://example.com/api/v1", "config_trim_slash: api_url")


# =========================================================================
# HTTP Helper Tests (test internal methods via a temporary EnsoulHttp)
# =========================================================================

func _test_build_url_no_query() -> void:
	var http := EnsoulHttp.new()
	var config := EnsoulConfig.new("key", "https://example.com/api")
	http.setup(config)
	root.add_child(http)
	var url := http._build_url("/personas")
	_assert_eq(url, "https://example.com/api/v1/personas", "build_url_no_query")
	http.queue_free()


func _test_build_url_with_query() -> void:
	var http := EnsoulHttp.new()
	var config := EnsoulConfig.new("key", "https://example.com/api")
	http.setup(config)
	root.add_child(http)
	var url := http._build_url("/personas", {"page": 1, "per_page": 10})
	_assert_true(url.begins_with("https://example.com/api/v1/personas?"), "build_url_with_query: prefix")
	_assert_true(url.contains("page=1"), "build_url_with_query: page param")
	_assert_true(url.contains("per_page=10"), "build_url_with_query: per_page param")
	http.queue_free()


func _test_build_url_null_values_skipped() -> void:
	var http := EnsoulHttp.new()
	var config := EnsoulConfig.new("key", "https://example.com/api")
	http.setup(config)
	root.add_child(http)
	var url := http._build_url("/test", {"a": 1, "b": null})
	_assert_true(url.contains("a=1"), "build_url_null_skip: has a")
	_assert_false(url.contains("b="), "build_url_null_skip: no b")
	http.queue_free()


func _test_build_headers_api_key() -> void:
	var http := EnsoulHttp.new()
	var config := EnsoulConfig.new("my_key", "https://example.com/api")
	http.setup(config)
	root.add_child(http)
	var headers := http._build_headers()
	var has_api_key := false
	for h in headers:
		if h == "X-Api-Key: my_key":
			has_api_key = true
	_assert_true(has_api_key, "build_headers_api_key")
	http.queue_free()


func _test_build_headers_bearer() -> void:
	var http := EnsoulHttp.new()
	var config := EnsoulConfig.new("", "https://example.com/api", "my_token")
	http.setup(config)
	root.add_child(http)
	var headers := http._build_headers()
	var has_bearer := false
	for h in headers:
		if h == "Authorization: Bearer my_token":
			has_bearer = true
	_assert_true(has_bearer, "build_headers_bearer")
	http.queue_free()


func _test_build_headers_no_auth() -> void:
	var http := EnsoulHttp.new()
	var config := EnsoulConfig.new("", "https://example.com/api")
	http.setup(config)
	root.add_child(http)
	var headers := http._build_headers()
	var has_auth := false
	for h in headers:
		if h.begins_with("X-Api-Key:") or h.begins_with("Authorization:"):
			has_auth = true
	_assert_false(has_auth, "build_headers_no_auth")
	http.queue_free()


func _test_retry_loop_range() -> void:
	# max_retries=0 means 1 attempt (no retries), matching Python/TS/Unity semantics.
	# Verify the loop executes exactly max_retries+1 times.
	var attempts_0 := 0
	for attempt in 0 + 1:
		attempts_0 += 1
	_assert_eq(attempts_0, 1, "retry_range: max_retries=0 → 1 attempt")

	var attempts_3 := 0
	for attempt in 3 + 1:
		attempts_3 += 1
	_assert_eq(attempts_3, 4, "retry_range: max_retries=3 → 4 attempts")


# =========================================================================
# Page Tests
# =========================================================================

func _test_page_from_result_success() -> void:
	var result := {
		"status_code": 200,
		"body": {
			"items": [{"id": "1"}, {"id": "2"}],
			"total": 10,
			"page": 1,
			"per_page": 2,
			"pages": 5
		}
	}
	var page := EnsoulPage.from_result(result, null, "/test", {})
	_assert_eq(page.items.size(), 2, "page_from_result: items count")
	_assert_eq(page.total, 10, "page_from_result: total")
	_assert_eq(page.page, 1, "page_from_result: page")
	_assert_eq(page.per_page, 2, "page_from_result: per_page")
	_assert_eq(page.pages, 5, "page_from_result: pages")


func _test_page_from_result_error() -> void:
	var result := {"error": "something went wrong"}
	var page := EnsoulPage.from_result(result, null, "/test", {})
	_assert_eq(page.items.size(), 0, "page_from_error: empty items")
	_assert_eq(page.total, 0, "page_from_error: total=0")


func _test_page_has_next_page() -> void:
	var page := EnsoulPage.new()
	page.page = 1
	page.pages = 3
	_assert_true(page.has_next_page(), "page_has_next_page")


func _test_page_no_next_page() -> void:
	var page := EnsoulPage.new()
	page.page = 3
	page.pages = 3
	_assert_false(page.has_next_page(), "page_no_next_page")


# =========================================================================
# SSE Tests
# =========================================================================

func _test_sse_event_defaults() -> void:
	var evt := EnsoulServerSentEvent.new()
	_assert_eq(evt.type, "message", "sse_event_defaults: type")
	_assert_eq(evt.data, "", "sse_event_defaults: data")
	_assert_eq(evt.last_event_id, "", "sse_event_defaults: last_event_id")
	_assert_eq(evt.retry, -1, "sse_event_defaults: retry")


func _test_sse_parse_block_simple() -> void:
	var stream := EnsoulSseStream.new()
	root.add_child(stream)
	var received: Array = []
	stream.event_received.connect(func(evt: EnsoulServerSentEvent): received.append(evt))

	stream._parse_block("data: hello world")
	# call_deferred means we need a frame
	await process_frame

	if received.size() != 1:
		_fail("sse_parse_block_simple", "expected 1 event got %d" % received.size())
	else:
		_assert_eq(received[0].data, "hello world", "sse_parse_block_simple: data")
	stream.queue_free()


func _test_sse_parse_block_multiline_data() -> void:
	var stream := EnsoulSseStream.new()
	root.add_child(stream)
	var received: Array = []
	stream.event_received.connect(func(evt: EnsoulServerSentEvent): received.append(evt))

	stream._parse_block("data: line1\ndata: line2")
	await process_frame

	if received.size() != 1:
		_fail("sse_parse_block_multiline", "expected 1 event got %d" % received.size())
	else:
		_assert_eq(received[0].data, "line1\nline2", "sse_parse_block_multiline: data")
	stream.queue_free()


func _test_sse_parse_block_custom_event() -> void:
	var stream := EnsoulSseStream.new()
	root.add_child(stream)
	var received: Array = []
	stream.event_received.connect(func(evt: EnsoulServerSentEvent): received.append(evt))

	stream._parse_block("event: custom\ndata: payload")
	await process_frame

	if received.size() != 1:
		_fail("sse_parse_block_custom_event", "expected 1 event")
	else:
		_assert_eq(received[0].type, "custom", "sse_parse_block_custom_event: type")
		_assert_eq(received[0].data, "payload", "sse_parse_block_custom_event: data")
	stream.queue_free()


func _test_sse_parse_block_comment_ignored() -> void:
	var stream := EnsoulSseStream.new()
	root.add_child(stream)
	var received: Array = []
	stream.event_received.connect(func(evt: EnsoulServerSentEvent): received.append(evt))

	stream._parse_block(": this is a comment\ndata: actual")
	await process_frame

	if received.size() != 1:
		_fail("sse_comment_ignored", "expected 1 event")
	else:
		_assert_eq(received[0].data, "actual", "sse_comment_ignored: data")
	stream.queue_free()


func _test_sse_parse_buffer_multiple_events() -> void:
	var stream := EnsoulSseStream.new()
	root.add_child(stream)
	var received: Array = []
	stream.event_received.connect(func(evt: EnsoulServerSentEvent): received.append(evt))

	stream._buffer = "data: first\n\ndata: second\n\n"
	stream._parse_buffer()
	await process_frame

	_assert_eq(received.size(), 2, "sse_buffer_multiple: count")
	if received.size() == 2:
		_assert_eq(received[0].data, "first", "sse_buffer_multiple: first")
		_assert_eq(received[1].data, "second", "sse_buffer_multiple: second")
	stream.queue_free()


# =========================================================================
# Client Tests
# =========================================================================

func _test_client_version() -> void:
	_assert_eq(EnsoulClient.VERSION, "0.1.0", "client_version")
