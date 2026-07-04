class_name DangerOverlay
extends Control

var danger_intensity: float = 0.0
var pulse_phase: float = 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(delta: float) -> void:
	pulse_phase = fmod(pulse_phase + delta * lerpf(2.5, 8.0, danger_intensity), TAU)
	queue_redraw()


func set_danger_intensity(next_intensity: float) -> void:
	danger_intensity = clampf(next_intensity, 0.0, 1.0)


func _draw() -> void:
	if danger_intensity <= 0.01:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var pulse: float = 0.5 + sin(pulse_phase) * 0.5
	var alpha: float = danger_intensity * (0.12 + pulse * 0.10)
	var edge_size: float = lerpf(18.0, 64.0, danger_intensity)
	var danger_color := Color(1.0, 0.12, 0.08, alpha)

	draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, edge_size)), danger_color, true)
	draw_rect(Rect2(Vector2(0.0, viewport_size.y - edge_size), Vector2(viewport_size.x, edge_size)), danger_color, true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(edge_size, viewport_size.y)), danger_color, true)
	draw_rect(Rect2(Vector2(viewport_size.x - edge_size, 0.0), Vector2(edge_size, viewport_size.y)), danger_color, true)

	var corner_color := Color(1.0, 0.22, 0.12, alpha * 1.4)
	var corner_length: float = lerpf(42.0, 92.0, danger_intensity)
	var inset: float = 18.0
	draw_line(Vector2(inset, inset), Vector2(inset + corner_length, inset), corner_color, 4.0)
	draw_line(Vector2(inset, inset), Vector2(inset, inset + corner_length), corner_color, 4.0)
	draw_line(Vector2(viewport_size.x - inset, inset), Vector2(viewport_size.x - inset - corner_length, inset), corner_color, 4.0)
	draw_line(Vector2(viewport_size.x - inset, inset), Vector2(viewport_size.x - inset, inset + corner_length), corner_color, 4.0)
	draw_line(Vector2(inset, viewport_size.y - inset), Vector2(inset + corner_length, viewport_size.y - inset), corner_color, 4.0)
	draw_line(Vector2(inset, viewport_size.y - inset), Vector2(inset, viewport_size.y - inset - corner_length), corner_color, 4.0)
	draw_line(Vector2(viewport_size.x - inset, viewport_size.y - inset), Vector2(viewport_size.x - inset - corner_length, viewport_size.y - inset), corner_color, 4.0)
	draw_line(Vector2(viewport_size.x - inset, viewport_size.y - inset), Vector2(viewport_size.x - inset, viewport_size.y - inset - corner_length), corner_color, 4.0)
