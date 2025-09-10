class_name PlayerMons extends Sprite2D


var player_mon_resource: MonsResource
@onready var player_health_bar: ProgressBar = %PlayerHealthBar

func _ready() -> void:
	Events.target_healed_signal.connect(_on_health_changed)
	Events.target_ko.connect(_on_target_ko)

func _on_target_ko(target: MonsResource) -> void:
	if target == player_mon_resource:
		return

	var total_exp := 0
	var total_money := 0
	var total_trainer_xp := 0
	var item_lines: Array[String] = []

	for drop: DropResource in target.drop_pool:
		var r: Dictionary = _grant_drop(drop, target)
		total_exp += int(r["exp"])
		total_money += int(r["money"])
		total_trainer_xp += int(r["trainer_xp"])
		for it in r["items"]:
			item_lines.append("%s x%d" % [it["name"], int(it["qty"])])

	var parts: Array[String] = []
	if total_exp > 0: parts.append("+%d EXP" % total_exp)
	if total_trainer_xp > 0: parts.append("+%d Trainer XP" % total_trainer_xp)
	if total_money > 0: parts.append("+%d Monies" % total_money)
	if item_lines.size() > 0: parts.append("Items: " + ", ".join(item_lines))

	var msg := "Rewards: " + ("None" if parts.is_empty() else " | ".join(parts))
	Events.show_dialog(msg)
	print(msg)




func _grant_drop(drop: DropResource, _defeated: MonsResource) -> Dictionary:
	var exp_drop := 0
	var monies := 0
	var trainer_xp := 0
	var items: Array = []  # each: {"name": String, "qty": int}

	match drop.type:
		DropResource.DropType.EXP:
			player_mon_resource.gain_exp(drop.value)
			exp_drop = int(drop.value)

		DropResource.DropType.MONEY:
			Globals.monies += drop.value
			monies = int(drop.value)

		DropResource.DropType.TRAINER_XP:
			Globals.trainer_exp += drop.value
			trainer_xp = int(drop.value)

		DropResource.DropType.ITEM:
			# stack by item or by name (choose one)
			if drop.item:
				Globals.inventory[drop.item] = Globals.inventory.get(drop.item, 0) + drop.value
				items.append({"name": drop.name, "qty": int(drop.value)})
			else:
				Globals.inventory[drop.name] = Globals.inventory.get(drop.name, 0) + drop.value
				items.append({"name": drop.name, "qty": int(drop.value)})

	return {
		"exp": exp_drop,
		"money": monies,
		"trainer_xp": trainer_xp,
		"items": items
	}



func _on_health_changed(target: MonsResource, previous: int, current: int)->void:
	print("Hp Changed")
#	if target == player_mon_resource:
#		player_health_bar.value = player_mon_resource.stats.health
#		print("player HP Changed ", player_health_bar.value )
