class_name EnsoulMemory
extends Node

var _http: EnsoulHttp


func create(
	persona_id: String,
	content: String,
	memory_type: String = "episodic",
	importance: float = 0.5,
	metadata: Dictionary = {}
) -> Dictionary:
	var body := {
		"content": content,
		"memory_type": memory_type,
		"importance": importance,
	}
	if not metadata.is_empty():
		body["metadata"] = metadata
	return await _http.post("/personas/%s/memories" % persona_id, body)


func list(persona_id: String, page: int = 1, per_page: int = 20) -> EnsoulPage:
	var q := {"page": page, "per_page": per_page}
	var path := "/personas/%s/memories" % persona_id
	var result := await _http.get_req(path, q)
	return EnsoulPage.from_result(result, _http, path, q)


func get_memory(persona_id: String, memory_id: String) -> Dictionary:
	return await _http.get_req("/personas/%s/memories/%s" % [persona_id, memory_id])


func delete(persona_id: String, memory_id: String) -> Dictionary:
	return await _http.delete("/personas/%s/memories/%s" % [persona_id, memory_id])


func batch_create(persona_id: String, memories: Array) -> Dictionary:
	return await _http.post("/personas/%s/memories/batch" % persona_id, {"memories": memories})


func consolidate(persona_id: String) -> Dictionary:
	return await _http.post("/personas/%s/memories/consolidate" % persona_id)


func query_knowledge(persona_id: String, query: String) -> Dictionary:
	return await _http.post("/personas/%s/knowledge/query" % persona_id, {"query": query})
