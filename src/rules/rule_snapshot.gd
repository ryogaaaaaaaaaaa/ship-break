class_name RuleSnapshot
extends RefCounted

var _values: Dictionary


func _init(values: Dictionary = {}) -> void:
	_values = values.duplicate(true)


func get_value(path: String, fallback: Variant = null) -> Variant:
	var current: Variant = _values
	for part in path.split("."):
		if not current is Dictionary:
			return fallback
		var current_dict: Dictionary = current
		if not current_dict.has(part):
			return fallback
		current = current_dict[part]
	return current


func get_float(path: String, fallback: float) -> float:
	var raw_value: Variant = get_value(path, fallback)
	if raw_value is int or raw_value is float:
		return float(raw_value)
	return fallback


func get_int(path: String, fallback: int) -> int:
	var raw_value: Variant = get_value(path, fallback)
	if raw_value is int:
		return raw_value
	if raw_value is float:
		return int(raw_value)
	return fallback


func get_bool(path: String, fallback: bool) -> bool:
	var raw_value: Variant = get_value(path, fallback)
	if raw_value is bool:
		return raw_value
	return fallback


func to_dictionary() -> Dictionary:
	return _values.duplicate(true)
