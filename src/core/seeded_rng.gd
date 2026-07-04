class_name SeededRng
extends RefCounted

var seed_value: int
var _rng: RandomNumberGenerator


func _init(initial_seed: int = 1) -> void:
	_rng = RandomNumberGenerator.new()
	reset(initial_seed)


func reset(new_seed: int) -> void:
	seed_value = new_seed
	_rng.seed = new_seed


func next_int(min_value: int, max_value: int) -> int:
	if min_value > max_value:
		return min_value
	return _rng.randi_range(min_value, max_value)


func next_float() -> float:
	return _rng.randf()


func next_float_range(min_value: float, max_value: float) -> float:
	if min_value > max_value:
		return min_value
	return _rng.randf_range(min_value, max_value)


func choose_index(item_count: int) -> int:
	if item_count <= 0:
		return -1
	return next_int(0, item_count - 1)
