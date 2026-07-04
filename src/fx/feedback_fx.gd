class_name FeedbackFx
extends Node2D

const MAX_EFFECTS := 48

var _effects: Array[Dictionary] = []


func _process(delta: float) -> void:
	for effect in _effects:
		effect["age"] += delta
	for index in range(_effects.size() - 1, -1, -1):
		if _effects[index]["age"] >= _effects[index]["duration"]:
			_effects.remove_at(index)
	queue_redraw()


func spawn_muzzle(origin: Vector2, direction: Vector2) -> void:
	_add_effect({
		"type": "muzzle",
		"origin": origin,
		"direction": direction.normalized(),
		"age": 0.0,
		"duration": 0.10,
	})


func spawn_hit(origin: Vector2) -> void:
	_add_effect({
		"type": "hit",
		"origin": origin,
		"age": 0.0,
		"duration": 0.16,
	})


func spawn_death(origin: Vector2) -> void:
	_add_effect({
		"type": "death",
		"origin": origin,
		"age": 0.0,
		"duration": 0.28,
	})


func spawn_dash(origin: Vector2, direction: Vector2) -> void:
	_add_effect({
		"type": "dash",
		"origin": origin,
		"direction": direction.normalized(),
		"age": 0.0,
		"duration": 0.18,
	})


func spawn_damage(origin: Vector2) -> void:
	_add_effect({
		"type": "damage",
		"origin": origin,
		"age": 0.0,
		"duration": 0.22,
	})


func active_count() -> int:
	return _effects.size()


func _add_effect(effect: Dictionary) -> void:
	if _effects.size() >= MAX_EFFECTS:
		_effects.pop_front()
	_effects.append(effect)


func _draw() -> void:
	for effect in _effects:
		var progress: float = clampf(effect["age"] / effect["duration"], 0.0, 1.0)
		match effect["type"]:
			"muzzle":
				_draw_muzzle(effect, progress)
			"hit":
				_draw_hit(effect, progress)
			"death":
				_draw_death(effect, progress)
			"dash":
				_draw_dash(effect, progress)
			"damage":
				_draw_damage(effect, progress)


func _draw_muzzle(effect: Dictionary, progress: float) -> void:
	var origin: Vector2 = effect["origin"]
	var direction: Vector2 = effect["direction"]
	var alpha: float = 1.0 - progress
	draw_line(origin - direction * 4.0, origin + direction * (34.0 + progress * 12.0), Color(1.0, 0.95, 0.42, 0.75 * alpha), 5.0)
	draw_circle(origin + direction * 20.0, 7.0 + progress * 10.0, Color(1.0, 0.72, 0.22, 0.28 * alpha))


func _draw_hit(effect: Dictionary, progress: float) -> void:
	var origin: Vector2 = effect["origin"]
	var alpha: float = 1.0 - progress
	draw_circle(origin, 5.0 + progress * 16.0, Color(1.0, 0.83, 0.36, 0.32 * alpha))
	for index in range(4):
		var angle: float = TAU * float(index) / 4.0 + progress * 1.2
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(origin + direction * 5.0, origin + direction * (12.0 + progress * 18.0), Color(1.0, 0.9, 0.56, 0.8 * alpha), 2.0)


func _draw_death(effect: Dictionary, progress: float) -> void:
	var origin: Vector2 = effect["origin"]
	var alpha: float = 1.0 - progress
	draw_arc(origin, 12.0 + progress * 38.0, 0.0, TAU, 36, Color(1.0, 0.18, 0.12, 0.65 * alpha), 4.0)
	draw_circle(origin, 18.0 + progress * 18.0, Color(0.9, 0.05, 0.05, 0.18 * alpha))


func _draw_dash(effect: Dictionary, progress: float) -> void:
	var origin: Vector2 = effect["origin"]
	var direction: Vector2 = effect["direction"]
	var alpha: float = 1.0 - progress
	var side := Vector2(-direction.y, direction.x)
	draw_line(origin - direction * (72.0 + progress * 24.0), origin - direction * 12.0, Color(0.54, 1.0, 1.0, 0.45 * alpha), 7.0)
	draw_line(origin - direction * 54.0 + side * 14.0, origin + side * 4.0, Color(0.8, 1.0, 1.0, 0.28 * alpha), 3.0)
	draw_line(origin - direction * 54.0 - side * 14.0, origin - side * 4.0, Color(0.8, 1.0, 1.0, 0.28 * alpha), 3.0)


func _draw_damage(effect: Dictionary, progress: float) -> void:
	var origin: Vector2 = effect["origin"]
	var alpha: float = 1.0 - progress
	draw_arc(origin, 24.0 + progress * 28.0, -0.8, 0.8, 16, Color(1.0, 0.18, 0.12, 0.7 * alpha), 5.0)
	draw_arc(origin, 24.0 + progress * 28.0, PI - 0.8, PI + 0.8, 16, Color(1.0, 0.18, 0.12, 0.7 * alpha), 5.0)
