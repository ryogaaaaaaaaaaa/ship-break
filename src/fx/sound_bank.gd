class_name SoundBank
extends Node

const MAX_PLAYERS := 16
const MIX_RATE := 22050

var _streams: Dictionary = {}
var _audio_enabled: bool = true


func _ready() -> void:
	_audio_enabled = DisplayServer.get_name() != "headless"
	if not _audio_enabled:
		return
	_streams = {
		"shoot": _make_tone(680.0, 390.0, 0.075, 0.34, 0.18),
		"hit": _make_tone(270.0, 180.0, 0.085, 0.28, 0.55),
		"death": _make_tone(120.0, 58.0, 0.22, 0.42, 0.76),
		"dash": _make_tone(260.0, 920.0, 0.12, 0.24, 0.12),
		"danger": _make_tone(82.0, 96.0, 0.11, 0.20, 0.72),
		"player_damage": _make_tone(90.0, 42.0, 0.18, 0.45, 0.9),
		"win": _make_tone(420.0, 760.0, 0.28, 0.26, 0.2),
		"lost": _make_tone(180.0, 70.0, 0.32, 0.34, 0.66),
	}


func play(sound_id: String) -> void:
	if not _audio_enabled:
		return
	if not _streams.has(sound_id):
		return
	if get_child_count() >= MAX_PLAYERS:
		return
	var player := AudioStreamPlayer.new()
	player.stream = _streams[sound_id]
	player.volume_db = -9.0
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func clear_active() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
		child.queue_free()


func active_players() -> int:
	return get_child_count()


func _exit_tree() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
		child.free()
	_streams.clear()


func _make_tone(start_hz: float, end_hz: float, duration: float, volume: float, grit: float) -> AudioStreamWAV:
	var sample_count: int = int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase: float = 0.0
	for index in range(sample_count):
		var t: float = float(index) / maxf(float(sample_count - 1), 1.0)
		var frequency: float = lerpf(start_hz, end_hz, t)
		phase += TAU * frequency / float(MIX_RATE)
		var envelope: float = pow(1.0 - t, 2.2)
		var harmonic: float = sin(phase) * (1.0 - grit * 0.35) + sin(phase * 2.03) * 0.24 * grit
		var click: float = sin(phase * 7.0) * grit * 0.12 * (1.0 - t)
		var sample_value: int = int(clampf((harmonic + click) * envelope * volume, -1.0, 1.0) * 32767.0)
		if sample_value < 0:
			sample_value = 65536 + sample_value
		data[index * 2] = sample_value & 0xff
		data[index * 2 + 1] = (sample_value >> 8) & 0xff

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
