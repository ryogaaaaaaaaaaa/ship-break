class_name Projectile
extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 680.0
var damage: int = 1
var lifetime_seconds: float = 1.4
var is_expired: bool = false


func configure(start_position: Vector2, shot_direction: Vector2, shot_speed: float, shot_damage: int = 1) -> void:
	global_position = start_position
	direction = shot_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	speed = shot_speed
	damage = shot_damage


func _ready() -> void:
	add_to_group("projectile")


func _physics_process(delta: float) -> void:
	if is_expired:
		return
	global_position += direction * speed * delta
	lifetime_seconds -= delta
	if lifetime_seconds <= 0.0:
		expire()
	queue_redraw()


func expire() -> void:
	if is_expired:
		return
	is_expired = true
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.86, 0.24))
	draw_circle(Vector2.ZERO, 2.0, Color(1.0, 1.0, 0.78))
