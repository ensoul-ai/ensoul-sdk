class_name EnsoulDomains
extends Node

var _http: EnsoulHttp


func list(page: int = 1, per_page: int = 20) -> EnsoulPage:
	var q := {"page": page, "per_page": per_page}
	var result := await _http.get_req("/domains", q)
	return EnsoulPage.from_result(result, _http, "/domains", q)


func get_domain(domain_id: String) -> Dictionary:
	return await _http.get_req("/domains/%s" % domain_id)


func create(body: Dictionary) -> Dictionary:
	return await _http.post("/domains", body)


func update(domain_id: String, body: Dictionary) -> Dictionary:
	return await _http.put("/domains/%s" % domain_id, body)


func delete(domain_id: String) -> Dictionary:
	return await _http.delete("/domains/%s" % domain_id)


func validate(config: Dictionary) -> Dictionary:
	## POST /v1/domains/validate — validate a domain config (DomainConfigCreate).
	## Top-level route (no domain id in the path).
	return await _http.post("/domains/validate", config)
