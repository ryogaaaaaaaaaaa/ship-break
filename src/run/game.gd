class_name Game
extends Node2D

const SeededRngScript := preload("res://src/core/seeded_rng.gd")
const RuleServiceScript := preload("res://src/rules/rule_service.gd")
const PlayerScript := preload("res://src/actors/player/player.gd")
const ChaserScript := preload("res://src/actors/enemies/chaser.gd")
const ProjectileScript := preload("res://src/combat/projectile.gd")
const MobileControlsScript := preload("res://src/ui/mobile_controls.gd")

enum RunStatus {
	PLAYING,
	WON,
	LOST,
}

var default_seed: int = 1842
var _rng: Variant
var _rule_service: Variant
var _snapshot: Variant
var _session_root: Node2D
var _player: Variant
var _status: int = RunStatus.PLAYING
var _elapsed_seconds: float = 0.0
var _spawn_timer: float = 0.0
var _kill_count: int = 0
var _run_duration_seconds: float = 60.0
var _restart_was_pressed: bool = false
var _arena_rect := Rect2(Vector2(80.0, 70.0), Vector2(1120.0, 580.0))
var _wall_rects: Array[Rect2] = []
var _spawn_points: Array[Vector2] = []
var _ui_layer: CanvasLayer
var _status_label: Label
var _message_label: Label
var _warning_label: Label
var _mobile_controls: Variant


func _ready() -> void:
	_create_ui()
	start_run(default_seed)


func start_run(seed: int = default_seed) -> void:
	default_seed = seed
	_clear_session()
	_rng = SeededRngScript.new(seed)
	_session_root = Node2D.new()
	_session_root.name = "SessionRoot"
	add_child(_session_root)

	_rule_service = RuleServiceScript.new()
	_rule_service.name = "RuleService"
	_session_root.add_child(_rule_service)
	_rule_service.reset_to_default()
	_snapshot = _rule_service.get_snapshot()

	_elapsed_seconds = 0.0
	_spawn_timer = 0.0
	_kill_count = 0
	_status = RunStatus.PLAYING
	_run_duration_seconds = _snapshot.get_float("run.duration_seconds", 60.0)
	_wall_rects.clear()
	_spawn_points = [
		Vector2(145.0, 145.0),
		Vector2(1135.0, 145.0),
		Vector2(145.0, 575.0),
		Vector2(1135.0, 575.0),
		Vector2(640.0, 110.0),
		Vector2(640.0, 610.0),
	]

	_create_arena()
	_create_player()
	for index in range(2):
		_spawn_chaser()
	_update_ui()
	queue_redraw()


func get_status() -> int:
	return _status


func get_session_root() -> Node2D:
	return _session_root


func get_rule_snapshot() -> Variant:
	return _snapshot


func count_session_children() -> int:
	if _session_root == null:
		return 0
	return _session_root.get_child_count()


func _physics_process(delta: float) -> void:
	_handle_restart_input()
	if _session_root == null:
		return
	if _status != RunStatus.PLAYING:
		_update_ui()
		return

	_elapsed_seconds += delta
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_chaser()
		_spawn_timer = _current_spawn_interval()

	_resolve_projectile_enemy_hits()
	_resolve_projectile_wall_hits()
	_resolve_enemy_contact()
	_check_success()
	_update_ui()
	queue_redraw()


func _draw() -> void:
	var anomaly: float = get_anomaly_intensity()
	var arena_color := Color(0.035, 0.043, 0.058).lerp(Color(0.08, 0.035, 0.045), anomaly)
	var border_color := Color(0.18, 0.22, 0.28).lerp(Color(0.95, 0.24, 0.18), anomaly)
	draw_rect(_arena_rect, arena_color, true)
	draw_rect(_arena_rect, border_color, false, 3.0 + anomaly * 3.0)
	if anomaly > 0.0:
		_draw_instability_lines(anomaly)


func _clear_session() -> void:
	if _session_root != null and is_instance_valid(_session_root):
		remove_child(_session_root)
		_session_root.free()
	_session_root = null
	_player = null
	_rule_service = null
	_snapshot = null


func _create_arena() -> void:
	_create_wall(Vector2(640.0, 55.0), Vector2(1150.0, 30.0))
	_create_wall(Vector2(640.0, 665.0), Vector2(1150.0, 30.0))
	_create_wall(Vector2(65.0, 360.0), Vector2(30.0, 610.0))
	_create_wall(Vector2(1215.0, 360.0), Vector2(30.0, 610.0))
	_create_wall(Vector2(360.0, 235.0), Vector2(230.0, 34.0))
	_create_wall(Vector2(920.0, 485.0), Vector2(230.0, 34.0))
	_create_wall(Vector2(520.0, 470.0), Vector2(36.0, 150.0))
	_create_wall(Vector2(760.0, 250.0), Vector2(36.0, 150.0))
	_create_wall(Vector2(640.0, 360.0), Vector2(150.0, 30.0))


func _create_wall(center: Vector2, size: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.name = "Wall"
	wall.position = center
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)
	var visual := Polygon2D.new()
	visual.color = Color(0.16, 0.18, 0.23)
	visual.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])
	wall.add_child(visual)
	_session_root.add_child(wall)
	_wall_rects.append(Rect2(center - size * 0.5, size))


func _create_player() -> void:
	_player = PlayerScript.new()
	_player.name = "Player"
	_player.global_position = _arena_rect.get_center()
	_player.configure(_snapshot, _mobile_controls)
	_player.shoot_requested.connect(_on_player_shoot_requested)
	_player.health_changed.connect(_on_player_health_changed)
	_player.died.connect(_on_player_died)
	_session_root.add_child(_player)


func _spawn_chaser() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var max_active: int = _snapshot.get_int("enemy.max_active", 24)
	if get_tree().get_nodes_in_group("chaser").size() >= max_active:
		return
	var eligible_points: Array[Vector2] = []
	for spawn_point in _spawn_points:
		if spawn_point.distance_to(_player.global_position) >= 390.0:
			eligible_points.append(spawn_point)
	if eligible_points.is_empty():
		eligible_points = _spawn_points.duplicate()
	var spawn_index: int = _rng.choose_index(eligible_points.size())
	if spawn_index < 0:
		return
	var chaser: Variant = ChaserScript.new()
	chaser.name = "Chaser"
	chaser.global_position = eligible_points[spawn_index]
	chaser.configure(_player, _snapshot)
	chaser.died.connect(_on_chaser_died)
	_session_root.add_child(chaser)


func _on_player_shoot_requested(origin: Vector2, direction: Vector2) -> void:
	var max_projectiles: int = _snapshot.get_int("combat.max_projectiles", 36)
	if get_tree().get_nodes_in_group("projectile").size() >= max_projectiles:
		return
	var projectile: Variant = ProjectileScript.new()
	projectile.name = "Projectile"
	projectile.configure(
		origin,
		direction,
		_snapshot.get_float("player.projectile_speed", 680.0),
		_snapshot.get_int("combat.projectile_damage", 1),
		_snapshot.get_float("combat.projectile_lifetime", 1.4)
	)
	_session_root.add_child(projectile)


func _on_player_health_changed(_current_health: int, _max_health: int) -> void:
	_update_ui()


func _on_player_died() -> void:
	_status = RunStatus.LOST
	_update_ui()


func _on_chaser_died(_chaser: Variant) -> void:
	_kill_count += 1


func _resolve_projectile_enemy_hits() -> void:
	var projectiles: Array[Node] = get_tree().get_nodes_in_group("projectile")
	var chasers: Array[Node] = get_tree().get_nodes_in_group("chaser")
	for projectile_node in projectiles:
		if projectile_node == null or not is_instance_valid(projectile_node):
			continue
		var projectile: Variant = projectile_node
		if projectile.is_expired:
			continue
		for chaser_node in chasers:
			if chaser_node == null or not is_instance_valid(chaser_node):
				continue
			var chaser: Variant = chaser_node
			if projectile.global_position.distance_to(chaser.global_position) <= chaser.hit_radius + 5.0:
				chaser.apply_damage(projectile.damage)
				projectile.expire()
				break


func _resolve_projectile_wall_hits() -> void:
	var projectiles: Array[Node] = get_tree().get_nodes_in_group("projectile")
	for projectile_node in projectiles:
		if projectile_node == null or not is_instance_valid(projectile_node):
			continue
		var projectile: Variant = projectile_node
		if projectile.is_expired:
			continue
		if not _arena_rect.has_point(projectile.global_position) or _is_inside_wall(projectile.global_position):
			projectile.expire()


func _resolve_enemy_contact() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var chasers: Array[Node] = get_tree().get_nodes_in_group("chaser")
	for chaser_node in chasers:
		if chaser_node == null or not is_instance_valid(chaser_node):
			continue
		var chaser: Variant = chaser_node
		var contact_distance: float = _player.hit_radius + chaser.contact_radius
		if chaser.can_contact_damage() and _player.global_position.distance_to(chaser.global_position) <= contact_distance:
			_player.take_damage(chaser.contact_damage)
			chaser.mark_contact_damage()


func _is_inside_wall(point: Vector2) -> bool:
	for wall_rect in _wall_rects:
		if wall_rect.has_point(point):
			return true
	return false


func _current_spawn_interval() -> float:
	var progress: float = clampf(_elapsed_seconds / maxf(_run_duration_seconds, 1.0), 0.0, 1.0)
	return lerpf(1.85, 0.72, progress)


func get_anomaly_intensity() -> float:
	var warning_start: float = maxf(_run_duration_seconds - 10.0, 1.0)
	if _elapsed_seconds <= warning_start:
		return 0.0
	return clampf((_elapsed_seconds - warning_start) / maxf(_run_duration_seconds - warning_start, 1.0), 0.0, 1.0)


func _draw_instability_lines(anomaly: float) -> void:
	var line_count: int = 5
	for index in range(line_count):
		var y_offset: float = fmod(_elapsed_seconds * (18.0 + index * 7.0) + index * 103.0, _arena_rect.size.y)
		var start := Vector2(_arena_rect.position.x, _arena_rect.position.y + y_offset)
		var end := Vector2(_arena_rect.end.x, start.y)
		draw_line(start, end, Color(1.0, 0.2, 0.16, 0.08 + anomaly * 0.18), 1.0 + anomaly * 2.0)


func _check_success() -> void:
	if _elapsed_seconds >= _run_duration_seconds:
		_status = RunStatus.WON
		_update_ui()


func _handle_restart_input() -> void:
	var restart_pressed: bool = Input.is_key_pressed(KEY_R)
	if restart_pressed and not _restart_was_pressed:
		start_run(default_seed)
	_restart_was_pressed = restart_pressed


func _create_ui() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "Hud"
	add_child(_ui_layer)
	_status_label = Label.new()
	_status_label.position = Vector2(24.0, 18.0)
	_status_label.add_theme_font_size_override("font_size", 20)
	_ui_layer.add_child(_status_label)

	_message_label = Label.new()
	_message_label.position = Vector2(450.0, 320.0)
	_message_label.add_theme_font_size_override("font_size", 28)
	_ui_layer.add_child(_message_label)

	_warning_label = Label.new()
	_warning_label.position = Vector2(24.0, 50.0)
	_warning_label.add_theme_font_size_override("font_size", 18)
	_ui_layer.add_child(_warning_label)

	_mobile_controls = MobileControlsScript.new()
	_mobile_controls.name = "MobileControls"
	_ui_layer.add_child(_mobile_controls)


func _update_ui() -> void:
	if _status_label == null:
		return
	var current_health: int = 0
	var max_health: int = 0
	if _player != null and is_instance_valid(_player):
		current_health = _player.health
		max_health = _player.max_health
	_status_label.text = "生存 %.1f / %.0f  耐久 %d/%d  撃破 %d  Seed %d" % [
		_elapsed_seconds,
		_run_duration_seconds,
		current_health,
		max_health,
		_kill_count,
		default_seed,
	]
	if _warning_label != null:
		var anomaly: float = get_anomaly_intensity()
		if _status == RunStatus.PLAYING and anomaly > 0.0:
			_warning_label.text = "BUILD INSTABILITY %.0f%%" % [anomaly * 100.0]
		else:
			_warning_label.text = ""
	if _message_label == null:
		return
	match _status:
		RunStatus.PLAYING:
			_message_label.text = ""
		RunStatus.WON:
			_message_label.text = "60秒生存成功\nRで再開"
		RunStatus.LOST:
			_message_label.text = "テスト失敗\nRで再開"
