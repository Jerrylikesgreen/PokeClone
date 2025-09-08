# res://Scripts/BGM.gd
class_name BGM
extends AudioStreamPlayer2D

@export var track_pool: Array[AudioStreamOggVorbis]

func _ready() -> void:
	Events.bgm_signal.connect(_on_bgm_signal)

func _on_bgm_signal(track_index: int) -> void:
	if track_index < 0 or track_index >= track_pool.size():
		push_warning("BGM: Invalid track index %d" % track_index)
		return

	stream = track_pool[track_index]
	play()
