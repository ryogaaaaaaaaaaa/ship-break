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
			"movement_speed": 286.0,
			"dash_speed": 900.0,
			"dash_duration": 0.14,
			"dash_cooldown": 0.78,
			"attack_cooldown": 0.31,
			"projectile_speed": 920.0,
			"max_health": 5,
		},
		"enemy": {
			"max_active": 14,
			"chaser_speed": 132.0,
			"chaser_health": 3,
			"chaser_surge_distance": 230.0,
			"chaser_surge_multiplier": 1.32,
			"contact_damage": 1,
		},
		"combat": {
			"max_projectiles": 36,
			"projectile_damage": 2,
			"projectile_lifetime": 1.05,
		},
		"debug": {
			"show_hitboxes": false,
		},
		"world": {
			"time_desync_enabled": false,
			"time_desync_player_exempt": false,
			"time_desync_interval": 4.8,
			"time_desync_duration": 1.1,
			"time_desync_scale": 0.38,
		},
		"run": {
			"duration_seconds": 60.0,
		},
	}


func to_dictionary() -> Dictionary:
	return _values.duplicate(true)
