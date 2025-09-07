class_name Move_Slot_Button extends Button

signal on_move_slot_pressed_signal(selected_move:Moves)


func _ready() -> void:
	self.pressed.connect(_on_pressed)
	

func _on_pressed()->void:
	var _move_selected: Moves = self.get_meta("move")
	emit_signal("on_move_slot_pressed_signal", _move_selected)
