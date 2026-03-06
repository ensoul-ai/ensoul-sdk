class_name EnsoulInfo
extends Node

var _http: EnsoulHttp


func config() -> Dictionary:
	return await _http.get_req("/info/config")


func rate_limits() -> Dictionary:
	return await _http.get_req("/info/rate-limits")


func tiers() -> Dictionary:
	return await _http.get_req("/info/tiers")


func features() -> Dictionary:
	return await _http.get_req("/info/features")
