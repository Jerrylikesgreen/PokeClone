## Autoload - Events
extends Node
## target: MonsResource, previous: int, current: int
signal target_health_changed_signal(target: MonsResource, previous: int, current: int)
signal target_ko(target: MonsResource)
signal show_dialog_signal(out_text:String)
signal battle_started_signal(mon:MonsResource)
signal battle_ended_signal
signal target_healed_signal(target: MonsResource, previous: int, current: int)

func show_dialog(in_text:String)->void:
	emit_signal("show_dialog_signal", in_text)


## dmg: int, target: MonsResource
func damage_done(dmg: int, target: MonsResource) -> bool:
	if target == null:
		print("no target")
		return false

	var prev := int(target.health)
	if prev <= 0:
		print("Returned ", target.health)
		return true                   # already KO'd; nothing to do

	var actual = min(prev, dmg)     # cap damage to remaining HP
	var curr = prev - actual        # never below 0

	target.health = curr
	emit_signal("target_health_changed_signal", target, prev, curr)
	print("target_health_changed" + str(target))


	# KO if we crossed to 0 (handles overkill)
	var ko = (prev > 0 and curr <= 0)
	if ko:
		emit_signal("target_ko", target)
		print("KO")
	return ko

func heal_done(heal: int, target: MonsResource) -> void:

	var prev := int(target.health)
	var curr = prev + heal

	target.health = curr
	emit_signal("target_healed_signal", target, prev, curr)
	print("Heal Signal Sent from Events")


func battle_started(mon:MonsResource)->void:
	
	emit_signal("battle_started_signal", mon)
