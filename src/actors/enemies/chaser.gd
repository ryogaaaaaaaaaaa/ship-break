class_name Chaser
extends CharacterBody2D

signal died(chaser)

var target: Node2D
var health: int = 2
var speed: float = 118.0
var contact_damage: int = 1
var contact_radius: float = 24.0
var hit_radius: float = 18.0
var contact_cooldown_seconds: float = 0.55
var _contact_cooldown_remaining: float = 0.0
var _hit_flash_remaining: float = 0.0


func configure(next_target: Node2D, rules: Variant) -> void:
	target = next_target
	speed = rules.get_float("enemy.chaser_speed", speed)
	health = rules.get_int("enemy.chaser_health", health)
	contact_damage = rules.get_int("enemy.contact_damage", contact_damage)


func _ready() -> void:
	add_to_group("chaser")
	_setup_collision()


func _physics_process(delta: float) -> void:
	_contact_cooldown_remaining = maxf(0.0, _contact_cooldown_remaining - delta)
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - delta)
	if target != null and is_instance_valid(target):
		var to_target: Vector2 = target.global_position - global_position
		if to_target.length() > 1.0:
			velocity = to_target.normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
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


func _draw() -> void:
	var body_color := Color(0.9, 0.18, 0.16)
	if _hit_flash_remaining > 0.0:
		body_color = Color(1.0, 0.82, 0.72)
	draw_circle(Vector2.ZERO, hit_radius, body_color)
	draw_circle(Vector2.ZERO, 6.0, Color(0.18, 0.02, 0.03))
	if target != null and is_instance_valid(target):
		var aim: Vector2 = (target.global_position - global_position).normalized()
		draw_line(Vector2.ZERO, aim * (hit_radius + 8.0), Color(1.0, 0.55, 0.44), 3.0)
