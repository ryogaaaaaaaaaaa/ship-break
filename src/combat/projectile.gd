class_name Projectile
extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 680.0
var damage: int = 1
var lifetime_seconds: float = 1.4
var is_expired: bool = false
var time_scale_source: Variant


func configure(start_position: Vector2, shot_direction: Vector2, shot_speed: float, shot_damage: int = 1, shot_lifetime: float = 1.4, next_time_scale_source: Variant = null) -> void:
	global_position = start_position
	direction = shot_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	speed = shot_speed
	damage = shot_damage
	lifetime_seconds = shot_lifetime
	time_scale_source = next_time_scale_source


func _ready() -> void:
	add_to_group("projectile")


func _physics_process(delta: float) -> void:
	if is_expired:
		return
	var scaled_delta: float = delta * _get_time_scale()
	global_position += direction * speed * scaled_delta
	lifetime_seconds -= scaled_delta
	if lifetime_seconds <= 0.0:
		expire()
	queue_redraw()


func expire() -> void:
	if is_expired:
		return
	is_expired = true
	queue_free()


func _get_time_scale() -> float:
	if time_scale_source != null and is_instance_valid(time_scale_source) and time_scale_source.has_method("get_world_time_scale"):
		return time_scale_source.get_world_time_scale()
	return 1.0


func _draw() -> void:
	draw_line(-direction * 18.0, direction * 7.0, Color(1.0, 0.74, 0.22, 0.82), 4.0)
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.9, 0.32))
	draw_circle(Vector2.ZERO, 2.0, Color(1.0, 1.0, 0.8))
