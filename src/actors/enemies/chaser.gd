class_name Chaser
extends CharacterBody2D

signal died(chaser)

var target: Node2D
var time_scale_source: Variant
var health: int = 2
var speed: float = 118.0
var surge_distance: float = 230.0
var surge_multiplier: float = 1.32
var contact_damage: int = 1
var contact_radius: float = 24.0
var hit_radius: float = 18.0
var contact_cooldown_seconds: float = 0.55
var _contact_cooldown_remaining: float = 0.0
var _hit_flash_remaining: float = 0.0
var _surge_intensity: float = 0.0


func configure(next_target: Node2D, rules: Variant, next_time_scale_source: Variant = null) -> void:
	target = next_target
	time_scale_source = next_time_scale_source
	speed = rules.get_float("enemy.chaser_speed", speed)
	health = rules.get_int("enemy.chaser_health", health)
	surge_distance = rules.get_float("enemy.chaser_surge_distance", surge_distance)
	surge_multiplier = rules.get_float("enemy.chaser_surge_multiplier", surge_multiplier)
	contact_damage = rules.get_int("enemy.contact_damage", contact_damage)


func _ready() -> void:
	add_to_group("chaser")
	_setup_collision()


func _physics_process(delta: float) -> void:
	var time_scale: float = _get_time_scale()
	var scaled_delta: float = delta * time_scale
	_contact_cooldown_remaining = maxf(0.0, _contact_cooldown_remaining - scaled_delta)
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - scaled_delta)
	if target != null and is_instance_valid(target):
		var to_target: Vector2 = target.global_position - global_position
		if to_target.length() > 1.0:
			_surge_intensity = 1.0 - clampf(to_target.length() / surge_distance, 0.0, 1.0)
			var active_speed: float = speed * lerpf(1.0, surge_multiplier, _surge_intensity)
			velocity = to_target.normalized() * active_speed * time_scale
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		_surge_intensity = 0.0
	move_and_slide()
	queue_redraw()


func apply_damage(amount: int) -> void:
	health -= amount
	_hit_flash_remaining = 0.08
	if health <= 0:
		died.emit(self)
		queue_free()


func can_contact_damage() -> bool:
	return _contact_cooldown_remaining <= 0.0


func mark_contact_damage() -> void:
	_contact_cooldown_remaining = contact_cooldown_seconds


func _setup_collision() -> void:
	var shape := CircleShape2D.new()
	shape.radius = hit_radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func _get_time_scale() -> float:
	if time_scale_source != null and is_instance_valid(time_scale_source) and time_scale_source.has_method("get_world_time_scale"):
		return time_scale_source.get_world_time_scale()
	return 1.0


func _draw() -> void:
	var body_color := Color(0.9, 0.18, 0.16)
	if _hit_flash_remaining > 0.0:
		body_color = Color(1.0, 0.82, 0.72)
	else:
		body_color = body_color.lerp(Color(1.0, 0.42, 0.18), _surge_intensity * 0.7)
	draw_circle(Vector2.ZERO, hit_radius, body_color)
	draw_circle(Vector2.ZERO, 6.0, Color(0.18, 0.02, 0.03))
	if _surge_intensity > 0.05:
		draw_arc(Vector2.ZERO, hit_radius + 5.0, 0.0, TAU, 24, Color(1.0, 0.45, 0.28, 0.42 * _surge_intensity), 2.0)
	if target != null and is_instance_valid(target):
		var aim: Vector2 = (target.global_position - global_position).normalized()
		draw_line(Vector2.ZERO, aim * (hit_radius + 8.0), Color(1.0, 0.55, 0.44), 3.0)
