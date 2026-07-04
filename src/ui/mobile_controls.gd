class_name MobileControls
extends Control

var movement_vector: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.RIGHT
var shoot_pressed: bool = false
var dash_pressed: bool = false
var dash_just_pressed: bool = false

var _left_touch_id: int = -1
var _right_touch_id: int = -1
var _dash_touch_id: int = -1
var _left_origin: Vector2 = Vector2.ZERO
var _left_current: Vector2 = Vector2.ZERO
var _right_origin: Vector2 = Vector2.ZERO
var _right_current: Vector2 = Vector2.ZERO
var _is_touch_capable: bool = false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_touch_capable = DisplayServer.is_touchscreen_available() or OS.has_feature("web_android") or OS.has_feature("web_ios")
	set_process_input(true)
	set_process(true)
	visible = _is_touch_capable


func _process(_delta: float) -> void:
	if dash_just_pressed:
		dash_just_pressed = false
	queue_redraw()


func has_aim_input() -> bool:
	return _right_touch_id != -1


func is_active() -> bool:
	return _is_touch_capable


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if event.pressed:
		if _is_inside_dash_button(event.position, viewport_size) and _dash_touch_id == -1:
			_dash_touch_id = event.index
			dash_pressed = true
			dash_just_pressed = true
			return
		if event.position.x < viewport_size.x * 0.5 and _left_touch_id == -1:
			_left_touch_id = event.index
			_left_origin = event.position
			_left_current = event.position
			movement_vector = Vector2.ZERO
			return
		if event.position.x >= viewport_size.x * 0.5 and _right_touch_id == -1:
			_right_touch_id = event.index
			_right_origin = event.position
			_right_current = event.position
			shoot_pressed = true
			return
	else:
		if event.index == _left_touch_id:
			_left_touch_id = -1
			movement_vector = Vector2.ZERO
		if event.index == _right_touch_id:
			_right_touch_id = -1
			shoot_pressed = false
		if event.index == _dash_touch_id:
			_dash_touch_id = -1
			dash_pressed = false


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == _left_touch_id:
		_left_current = event.position
		var delta: Vector2 = _left_current - _left_origin
		movement_vector = delta.limit_length(70.0) / 70.0
	elif event.index == _right_touch_id:
		_right_current = event.position
		var aim_delta: Vector2 = _right_current - _right_origin
		if aim_delta.length() > 12.0:
			aim_direction = aim_delta.normalized()
		shoot_pressed = true


func _is_inside_dash_button(point: Vector2, viewport_size: Vector2) -> bool:
	var center := Vector2(viewport_size.x - 92.0, viewport_size.y - 92.0)
	return point.distance_to(center) <= 58.0


func _draw() -> void:
	if not visible:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var left_base := Vector2(112.0, viewport_size.y - 116.0)
	var left_knob := left_base + movement_vector * 48.0
	if _left_touch_id != -1:
		left_base = _left_origin
		left_knob = _left_origin + movement_vector * 48.0

	draw_circle(left_base, 66.0, Color(0.12, 0.18, 0.22, 0.35))
	draw_arc(left_base, 66.0, 0.0, TAU, 36, Color(0.55, 0.9, 1.0, 0.55), 3.0)
	draw_circle(left_knob, 24.0, Color(0.55, 0.9, 1.0, 0.55))

	var dash_center := Vector2(viewport_size.x - 92.0, viewport_size.y - 92.0)
	var dash_color := Color(0.95, 0.95, 1.0, 0.38)
	if dash_pressed:
		dash_color = Color(1.0, 1.0, 1.0, 0.62)
	draw_circle(dash_center, 58.0, Color(0.12, 0.13, 0.18, 0.38))
	draw_arc(dash_center, 58.0, 0.0, TAU, 36, dash_color, 4.0)
	draw_line(dash_center + Vector2(-18.0, 12.0), dash_center + Vector2(22.0, -16.0), dash_color, 5.0)

	var aim_center := Vector2(viewport_size.x - 230.0, viewport_size.y - 130.0)
	if _right_touch_id != -1:
		aim_center = _right_origin
	draw_circle(aim_center, 46.0, Color(0.22, 0.16, 0.08, 0.22))
	draw_line(aim_center, aim_center + aim_direction * 48.0, Color(1.0, 0.84, 0.28, 0.58), 4.0)
