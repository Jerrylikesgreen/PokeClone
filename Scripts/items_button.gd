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
			var item_name := ""

			if key is Resource:
				var rname := (key as Resource).resource_name
				item_name = rname if rname != "" else key.get_class()
			elif key is String:
				item_name = key
			else:
				item_name = str(key)

			item_lines.append("• %s x%d" % [item_name, qty])

		item_lines.sort()

	var msg := "Monies: %d | Trainer XP: %d" % [monies, trainer_xp]
	msg += "\nItems:\n" + ("\n".join(item_lines) if item_lines.size() > 0 else "(none)")
	Events.show_dialog(msg)
	print(msg)
