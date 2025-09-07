class_name DialogLabel
extends RichTextLabel
@onready var battle_screen: BattleScreen = $"../.."

signal finished_typing
@export_range(0, 200) var chars_per_second: float = 30.0

var _typing := false
var _accum := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not Events.show_dialog_signal.is_connected(prompt_text):
		Events.show_dialog_signal.connect(prompt_text)
	visible_characters = 0
	set_process(false)

	
	

func prompt_text(line: String) -> void:
	text = line
	visible_characters = 0
	_accum = 0.0
	_typing = chars_per_second > 0.0
	set_process(_typing)
	if not _typing:
		visible_characters = -1
		emit_signal("finished_typing")

func _process(delta: float) -> void:
	if not _typing: return
	_accum += delta * chars_per_second
	var step := int(_accum)
	if step <= 0: return
	_accum -= step

	var total := get_total_character_count()
	visible_characters = min(visible_characters + step, total)
	if visible_characters >= total:
		_finish()

func skip() -> void:
	if not _typing: return
	visible_characters = get_total_character_count()
	_finish()

func _finish() -> void:
	_typing = false
	set_process(false)
	emit_signal("finished_typing")
