class_name ItemsButton
extends Button

func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var monies := int(Globals.monies)            
	var trainer_xp := int(Globals.trainer_exp)
	var inv = Globals.inventory               ## expect Dictionary

	var item_lines: Array[String] = []
	if inv is Dictionary and not inv.is_empty():
		for key in inv.keys():
			var qty := int(inv[key])
			var name := ""

			if key is Resource:
				# Prefer resource_name if set; else fall back to class
				var rname := (key as Resource).resource_name
				name = rname if rname != "" else key.get_class()
			elif key is String:
				name = key
			else:
				name = str(key)

			item_lines.append("• %s x%d" % [name, qty])

		item_lines.sort()  # alphabetical

	var msg := "Monies: %d | Trainer XP: %d" % [monies, trainer_xp]
	msg += "\nItems:\n" + ("\n".join(item_lines) if item_lines.size() > 0 else "(none)")

	# Show it via your dialog system (and also log)
	Events.show_dialog(msg)  # or Events.show_dialog_signal.emit(msg)
	print(msg)
