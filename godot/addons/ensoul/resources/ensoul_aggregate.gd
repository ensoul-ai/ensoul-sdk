class_name EnsoulAggregate
extends Node

var _http: EnsoulHttp


func query(query_str: String, filters: Dictionary = {}, aggregation_mode: String = "") -> Dictionary:
	var body := {"query": query_str}
	if not filters.is_empty(): body["filters"] = filters
	if aggregation_mode != "": body["aggregation_mode"] = aggregation_mode
	return await _http.post("/aggregate/query", body)


func stream(
	query_str: String,
	filters: Dictionary = {},
	aggregation_mode: String = "",
	target_confidence: float = 0.95,
	min_samples: int = 100,
	max_samples: int = -1
) -> EnsoulSseStream:
	var config: EnsoulConfig = _http._config
	var url := config.api_url() + "/aggregate/stream"  # no format needed — static path
	var headers := PackedStringArray()
	headers.append("Content-Type: application/json")
	if config.bearer_token != "":
		headers.append("Authorization: Bearer %s" % config.bearer_token)
	elif config.api_key != "":
		headers.append("X-Api-Key: %s" % config.api_key)
	var body := {
		"query": query_str,
		"target_confidence": target_confidence,
		"min_samples": min_samples,
	}
	if not filters.is_empty(): body["filters"] = filters
	if aggregation_mode != "": body["aggregation_mode"] = aggregation_mode
	if max_samples >= 0: body["max_samples"] = max_samples
	var sse := EnsoulSseStream.new()
	add_child(sse)
	sse.connect_to_url(url, headers, JSON.stringify(body), HTTPClient.METHOD_POST)
	return sse


func grouped_stream(
	query_str: String,
	group_by: String,
	filters: Dictionary = {}
) -> EnsoulSseStream:
	var config: EnsoulConfig = _http._config
	var url := config.api_url() + "/aggregate/stream/grouped"  # no format needed — static path
	var headers := PackedStringArray()
	headers.append("Content-Type: application/json")
	if config.bearer_token != "":
		headers.append("Authorization: Bearer %s" % config.bearer_token)
	elif config.api_key != "":
		headers.append("X-Api-Key: %s" % config.api_key)
	var body := {"query": query_str, "group_by": group_by}
	if not filters.is_empty(): body["filters"] = filters
	var sse := EnsoulSseStream.new()
	add_child(sse)
	sse.connect_to_url(url, headers, JSON.stringify(body), HTTPClient.METHOD_POST)
	return sse


func simulate(
	scenario: String,
	target_cohort: Dictionary = {},
	duration_days: int = 30,
	parameters: Dictionary = {}
) -> Dictionary:
	var body := {"scenario": scenario, "duration_days": duration_days}
	if not target_cohort.is_empty(): body["target_cohort"] = target_cohort
	if not parameters.is_empty(): body["parameters"] = parameters
	return await _http.post("/aggregate/simulate", body)


func trace_influence(
	persona_id: String,
	influence_type: String = "",
	direction: String = "downstream",
	max_depth: int = 3
) -> Dictionary:
	var q := {"direction": direction, "max_depth": max_depth}
	if influence_type != "": q["influence_type"] = influence_type
	return await _http.get_req("/aggregate/influence/%s" % persona_id, q)
