class_name MonsResource
extends Resource

signal applied(target)



@export_category("--- Name / Sprite ---")
@export var mon_name: String = ""
@export var sprite: SpriteFrames
@export var _player: bool = false

@export_category("--- Level / XP ---")
var _lvl: int = 1
@export var lvl: int:
	get: return _lvl
	set(value):
		_lvl = max(1, value)
		max_exp = exp_for_level(_lvl)

@export var current_exp: int = 0
@export var max_exp: int = 10  # Updated dynamically in setter/init

static func exp_for_level(level: int) -> int:
	return 10 * level  # Customize as needed

func gain_exp(amount: int) -> void:
	current_exp += max(0, amount)
	while current_exp >= max_exp:
		current_exp -= max_exp
		lvl += 1  # triggers setter

@export_category("--- HP / Stats ---")
@export var stats: Stats
@export var current_status: Array[Effects]

@export_category("--- Move Pool ---")
@export var move_pool: Array[Moves] = []

@export_category("--- Drop Pool ---")
@export var drop_pool: Array[DropResource] = []

func _init() -> void:
	max_exp = exp_for_level(_lvl)


func apply_to(monster, effect:Effects):
	var effect_name:String = effect.effect_name
	print("Applying", effect_name, "to", monster.mon_name)
	emit_signal("applied", monster)
