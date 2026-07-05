class_name Player
extends CharacterBody2D

signal shoot_requested(origin: Vector2, direction: Vector2)
signal dash_started(origin: Vector2, direction: Vector2)
signal health_changed(current_health: int, max_health: int)
signal died

var rules: Variant
var mobile_controls: Variant
var time_scale_source: Variant
var max_health: int = 5
var health: int = 5
var hit_radius: float = 16.0
var _aim_direction: Vector2 = Vector2.RIGHT
var _attack_cooldown_remaining: float = 0.0
var _dash_cooldown_remaining: float = 0.0
var _dash_remaining: float = 0.0
var _dash_direction: Vector2 = Vector2.RIGHT
var _invulnerable_remaining: float = 0.0
var _damage_flash_remaining: float = 0.0
var _shot_feedback_remaining: float = 0.0
var _was_space_pressed: bool = false


func configure(next_rules: Variant, next_mobile_controls: Variant = null, next_time_scale_source: Variant = null) -> void:
	rules = next_rules
	mobile_controls = next_mobile_controls
	time_scale_source = next_time_scale_source
	max_health = rules.get_int("player.max_health", max_health)
	health = max_health


func _ready() -> void:
	_setup_collision()
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	var time_scale: float = _get_time_scale()
	var scaled_delta: float = delta * time_scale
	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - scaled_delta)
	_dash_cooldown_remaining = maxf(0.0, _dash_cooldown_remaining - scaled_delta)
	_invulnerable_remaining = maxf(0.0, _invulnerable_remaining - scaled_delta)
	_damage_flash_remaining = maxf(0.0, _damage_flash_remaining - scaled_delta)
	_shot_feedback_remaining = maxf(0.0, _shot_feedback_remaining - scaled_delta)
	_update_aim()
	_update_dash(scaled_delta, time_scale)
	_update_fire()
	queue_redraw()


func take_damage(amount: int) -> void:
	if _invulnerable_remaining > 0.0 or health <= 0:
		return
	health = max(0, health - amount)
	_invulnerable_remaining = 0.55
	_damage_flash_remaining = 0.12
	health_changed.emit(health, max_health)
	if health <= 0:
		died.emit()


func get_aim_direction() -> Vector2:
	return _aim_direction


func _setup_collision() -> void:
	var shape := CircleShape2D.new()
	shape.radius = hit_radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func _update_aim() -> void:
	if mobile_controls != null and mobile_controls.has_aim_input():
		_aim_direction = mobile_controls.aim_direction
		return
	var to_mouse: Vector2 = get_global_mouse_position() - global_position
	if to_mouse.length() > 4.0:
		_aim_direction = to_mouse.normalized()


func _update_dash(delta: float, time_scale: float) -> void:
	var input_vector: Vector2 = _read_movement_input()
	var space_pressed: bool = Input.is_key_pressed(KEY_SPACE)
	var mobile_dash_started: bool = mobile_controls != null and mobile_controls.dash_just_pressed
	var should_start_dash: bool = (space_pressed and not _was_space_pressed or mobile_dash_started) and _dash_cooldown_remaining <= 0.0
	_was_space_pressed = space_pressed
	if should_start_dash:
		_dash_direction = input_vector
		if _dash_direction == Vector2.ZERO:
			_dash_direction = _aim_direction
		_dash_remaining = rules.get_float("player.dash_duration", 0.16)
		_dash_cooldown_remaining = rules.get_float("player.dash_cooldown", 0.62)
		dash_started.emit(global_position, _dash_direction)

	if _dash_remaining > 0.0:
		_dash_remaining = maxf(0.0, _dash_remaining - delta)
		velocity = _dash_direction.normalized() * rules.get_float("player.dash_speed", 760.0) * time_scale
	else:
		velocity = input_vector * rules.get_float("player.movement_speed", 260.0) * time_scale
	move_and_slide()


func _update_fire() -> void:
	var mobile_shooting: bool = mobile_controls != null and mobile_controls.shoot_pressed
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or mobile_shooting) and _attack_cooldown_remaining <= 0.0:
		_attack_cooldown_remaining = rules.get_float("player.attack_cooldown", 0.20)
		_shot_feedback_remaining = 0.07
		shoot_requested.emit(global_position + _aim_direction * 22.0, _aim_direction)


func _read_movement_input() -> Vector2:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0
	if input_vector == Vector2.ZERO and mobile_controls != null:
		input_vector = mobile_controls.movement_vector
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	return input_vector


func _get_time_scale() -> float:
	if time_scale_source != null and is_instance_valid(time_scale_source) and time_scale_source.has_method("get_player_time_scale"):
		return time_scale_source.get_player_time_scale()
	return 1.0


func _draw() -> void:
	var body_color := Color(0.1, 0.84, 1.0)
	if _damage_flash_remaining > 0.0:
		body_color = Color(1.0, 1.0, 1.0)
	draw_circle(Vector2.ZERO, hit_radius, body_color)
	draw_circle(Vector2.ZERO, 6.0, Color(0.03, 0.12, 0.16))
	var aim_length: float = 34.0
	var aim_width: float = 4.0
	var aim_color := Color(0.72, 1.0, 1.0)
	if mobile_controls != null and mobile_controls.has_aim_input():
		aim_length = 52.0 + mobile_controls.get_aim_strength() * 26.0
		aim_width = 5.0
		aim_color = Color(1.0, 0.9, 0.36)
	if _shot_feedback_remaining > 0.0:
		aim_length = 46.0
		aim_width = 6.0
		aim_color = Color(1.0, 0.96, 0.46)
	draw_line(Vector2.ZERO, _aim_direction * aim_length, aim_color, aim_width)
	if _dash_remaining > 0.0:
		draw_arc(Vector2.ZERO, hit_radius + 5.0, 0.0, TAU, 24, Color(0.9, 1.0, 1.0), 3.0)
