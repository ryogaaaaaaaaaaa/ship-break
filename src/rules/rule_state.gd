class_name RuleState
extends RefCounted

var _values: Dictionary


func _init(values: Dictionary = {}) -> void:
	if values.is_empty():
		_values = default_values()
	else:
		_values = values.duplicate(true)


static func default_values() -> Dictionary:
	return {
		"player": {
			"movement_speed": 260.0,
			"dash_speed": 760.0,
			"dash_duration": 0.16,
			"dash_cooldown": 0.62,
			"attack_cooldown": 0.20,
			"projectile_speed": 680.0,
			"max_health": 5,
		},
		"enemy": {
			"max_active": 24,
			"chaser_speed": 118.0,
			"chaser_health": 2,
			"contact_damage": 1,
		},
		"combat": {
			"max_projectiles": 36,
		},
		"debug": {
			"show_hitboxes": false,
		},
		"run": {
			"duration_seconds": 60.0,
		},
	}


func to_dictionary() -> Dictionary:
	return _values.duplicate(true)
