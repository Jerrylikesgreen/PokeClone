class_name MonsResource extends Resource


@export_category("--- Name / Sprite ---")
@export var mon_name: String = ""
@export var sprite: Texture2D

@export_category("--- Level/XP ---")
var _lvl: int = 1
@export var lvl: int:
	get: return _lvl
	set(value):
		_lvl = max(1, value)
		max_exp = exp_for_level(_lvl)  # keep in sync

@export var exp: int = 0
@export var max_exp: int = 10  # will be synced in _init()

static func exp_for_level(level: int) -> int:
	return 10 * level  # tweak your formula here

func gain_exp(amount: int) -> void:
	exp += max(0, amount)
	while exp >= max_exp:
		exp -= max_exp
		lvl += 1  # setter updates max_exp
		
@export_category("--- HP/Stats ---")
@export var max_health: int = 100
var _health: int = 100
@export var health: int:
	get: return _health
	set(value):
		_health = clamp(value, 0, max_health)

@export var attack: int = 10
@export var s_attack: int = 10
@export var defence: int = 10
@export var s_defence: int = 10
@export var speed: int = 10

@export_category("--- Move Pool ---")
@export var move_pool: Array[Moves] = []  

@export_category("--- Drop Pool ---")
@export var drop_pool:Array[DropResource]

func _init() -> void:
	max_exp = exp_for_level(_lvl)
	_health = clamp(_health, 0, max_health)
