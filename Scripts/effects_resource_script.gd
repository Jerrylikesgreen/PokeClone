class_name Effects
extends Resource

enum Stat {
	HEALTH,
	ATTACK,
	S_ATTACK,
	DEFENCE,
	S_DEFENCE,
	SPEED,
	MAX_HEALTH,
	HIT
}

@export var effect_name: String
@export var multiplier: float
@export var target_stat: Stat = Stat.ATTACK
@export var duration:int = 0

# Helper to map enum to property names
func _get_stat_name(stat: Stat) -> StringName:
	match stat:
		Stat.HEALTH: return "health"
		Stat.ATTACK: return "attack"
		Stat.S_ATTACK: return "s_attack"
		Stat.DEFENCE: return "defence"
		Stat.S_DEFENCE: return "s_defence"
		Stat.SPEED: return "speed"
		Stat.MAX_HEALTH: return "max_health"
		Stat.HIT: return "hit"
		_: return ""
		

func apply_to(mon: MonsResource) -> void:
	var stat_name: StringName = _get_stat_name(target_stat)
	if mon.stats.has_property(stat_name):
		var current = mon.stats.get(stat_name)
		mon.stats.set(stat_name, current * multiplier)
