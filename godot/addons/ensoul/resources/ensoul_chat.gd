class_name EnsoulChat
extends Node

var _http: EnsoulHttp


func send(
	persona_id: String,
	message: String,
	conversation_id: String = "",
	user_id: String = "",
	max_tokens: int = 1024,
	temperature: float = 1.0,
	include_memories: bool = true,
	include_knowledge: bool = true
) -> Dictionary:
	var body := {
		"message": message,
		"max_tokens": max_tokens,
		"temperature": temperature,
		"include_memories": include_memories,
		"include_knowledge": include_knowledge,
	}
	if conversation_id != "": body["conversation_id"] = conversation_id
	if user_id         != "": body["user_id"]         = user_id
	return await _http.post("/personas/%s/chat" % persona_id, body)


func stream(persona_id: String, message: String, extras: Dictionary = {}) -> EnsoulSseStream:
	var config: EnsoulConfig = _http._config
	var url := config.api_url() + ("/personas/%s/chat/stream" % persona_id)
	var headers := PackedStringArray()
	headers.append("Content-Type: application/json")
	if config.bearer_token != "":
		headers.append("Authorization: Bearer %s" % config.bearer_token)
	elif config.api_key != "":
		headers.append("X-Api-Key: %s" % config.api_key)
	var body := {"message": message}
	body.merge(extras)
	var sse := EnsoulSseStream.new()
	add_child(sse)
	sse.connect_to_url(url, headers, JSON.stringify(body), HTTPClient.METHOD_POST)
	return sse


func get_conversations(persona_id: String, page: int = 1, per_page: int = 20) -> EnsoulPage:
	var q := {"page": page, "per_page": per_page}
	var path := "/personas/%s/conversations" % persona_id
	var result := await _http.get_req(path, q)
	return EnsoulPage.from_result(result, _http, path, q)


func get_conversation(persona_id: String, conversation_id: String) -> Dictionary:
	return await _http.get_req("/personas/%s/conversations/%s" % [persona_id, conversation_id])
