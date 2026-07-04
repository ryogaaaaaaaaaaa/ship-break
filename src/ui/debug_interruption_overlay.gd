class_name DebugInterruptionOverlay
extends Control

var _title_label: Label
var _summary_label: Label
var _body_label: Label
var _slot_label: Label
var _restart_label: Label
var _pulse_seconds: float = 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_process(false)
	_build_layout()


func show_interruption(elapsed_seconds: float, kill_count: int, seed: int, time_desync_enabled: bool) -> void:
	visible = true
	set_process(true)
	_summary_label.text = "RUN %.1fs / 撃破 %d / Seed %d" % [elapsed_seconds, kill_count, seed]
	if time_desync_enabled:
		_body_label.text = "TIME DESYNC は継続中です。\n次のランも、一定間隔で世界全体が短くスローになります。"
		_slot_label.text = "FIX  未接続    WORKAROUND  継続中    EXPLOIT  未接続"
		_restart_label.text = "タップ / クリック / Enter / Space / R で次のラン"
	else:
		_body_label.text = "TIME DESYNC を検出しました。\nWORKAROUND を接続すると、一定間隔で世界全体が短くスローになります。"
		_slot_label.text = "FIX  未接続    WORKAROUND  接続可能    EXPLOIT  未接続"
		_restart_label.text = "タップ / クリック / Enter / Space / R で WORKAROUND を適用"
	_pulse_seconds = 0.0
	queue_redraw()


func hide_interruption() -> void:
	visible = false
	set_process(false)
	queue_redraw()


func is_showing() -> bool:
	return visible


func _process(delta: float) -> void:
	_pulse_seconds += delta
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.015, 0.018, 0.024, 0.88), true)
	var pulse: float = 0.5 + sin(_pulse_seconds * 5.0) * 0.5
	var alert_color := Color(1.0, 0.18, 0.12, 0.10 + pulse * 0.09)
	draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, 74.0)), alert_color, true)
	for index in range(0, int(viewport_size.y), 24):
		var alpha: float = 0.035 + pulse * 0.018
		draw_line(Vector2(0.0, index), Vector2(viewport_size.x, index), Color(0.65, 0.95, 1.0, alpha), 1.0)


func _build_layout() -> void:
	var root_margin := MarginContainer.new()
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 32)
	root_margin.add_theme_constant_override("margin_top", 28)
	root_margin.add_theme_constant_override("margin_right", 32)
	root_margin.add_theme_constant_override("margin_bottom", 28)
	add_child(root_margin)

	var center := CenterContainer.new()
	root_margin.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760.0, 0.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.043, 0.058, 0.94)
	panel_style.border_color = Color(1.0, 0.24, 0.16, 0.82)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	margin.add_child(stack)

	_title_label = Label.new()
	_title_label.text = "BUILD INTERRUPTED"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 34)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.28, 0.18))
	stack.add_child(_title_label)

	_summary_label = Label.new()
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.add_theme_font_size_override("font_size", 18)
	_summary_label.add_theme_color_override("font_color", Color(0.72, 0.92, 1.0))
	stack.add_child(_summary_label)

	_body_label = Label.new()
	_body_label.text = "通常ゲームは最後まで走りました。\n次のパッチスロットを準備しています。"
	_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.add_theme_font_size_override("font_size", 22)
	_body_label.add_theme_color_override("font_color", Color(0.91, 0.95, 0.96))
	stack.add_child(_body_label)

	_slot_label = Label.new()
	_slot_label.text = "FIX  未接続    WORKAROUND  未接続    EXPLOIT  未接続"
	_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_slot_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_slot_label.add_theme_font_size_override("font_size", 18)
	_slot_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.32))
	stack.add_child(_slot_label)

	_restart_label = Label.new()
	_restart_label.text = "タップ / クリック / Enter / Space / R で再起動"
	_restart_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_restart_label.add_theme_font_size_override("font_size", 18)
	_restart_label.add_theme_color_override("font_color", Color(0.74, 0.79, 0.83))
	stack.add_child(_restart_label)
