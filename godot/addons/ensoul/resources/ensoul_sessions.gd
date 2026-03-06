class_name EnsoulSessions
extends Node

var _http: EnsoulHttp


func create(
	persona_id: String,
	tier: int = 0,
	parent_session_id: String = "",
	system_instructions: String = ""
) -> Dictionary:
	var body := {"tier": tier}
	if parent_session_id != "": body["parent_session_id"] = parent_session_id
	if system_instructions != "": body["system_instructions"] = system_instructions
	return await _http.post("/personas/%s/sessions" % persona_id, body)


func get_session(persona_id: String, session_id: String) -> Dictionary:
	return await _http.get_req("/personas/%s/sessions/%s" % [persona_id, session_id])


func list(persona_id: String, page: int = 1, per_page: int = 20) -> EnsoulPage:
	var q := {"page": page, "per_page": per_page}
	var path := "/personas/%s/sessions" % persona_id
	var result := await _http.get_req(path, q)
	return EnsoulPage.from_result(result, _http, path, q)


func get_child_sessions(persona_id: String, session_id: String) -> Dictionary:
	return await _http.get_req("/personas/%s/sessions/%s/children" % [persona_id, session_id])


func aggregate_children(
	persona_id: String,
	session_id: String,
	aggregation_mode: String = "summary"
) -> Dictionary:
	return await _http.post(
		"/personas/%s/sessions/%s/aggregate" % [persona_id, session_id],
		{"aggregation_mode": aggregation_mode}
	)
