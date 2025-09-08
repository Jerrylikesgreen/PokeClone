# EnemyMons.gd
class_name EnemyMons
extends AnimatedSprite2D
@onready var battle_manager: BattleManager = %BattleManager

signal enemy_move_chosen(move: Moves)
signal battle_over
var enemy_mon_resource

@export var fallback_move: Moves  # e.g., "Struggle" (optional)

@onready var _rng := RandomNumberGenerator.new()

var _has_mons_available:bool = false

func _ready() -> void:
	_rng.randomize()
	Events.target_ko.connect(_on_ko)

func _on_ko(target:MonsResource)->void:
	print("_on_ko")
	if !target._player:
		_check_if_battle_over()
	else:
		return

func attack() -> void:
	var move := _pick_random_move()
	emit_signal("enemy_move_chosen", move)  # Let BattleManager resolve it
	print(move.name, "Move Signal Emit")

func _pick_random_move() -> Moves:
	if enemy_mon_resource == null:
		print("EnemyMons: enemy_mon_resource not set.")
		return fallback_move

	var pool: Array[Moves] = enemy_mon_resource.move_pool
	if pool.is_empty():
		return fallback_move

	var available: Array[Moves] = []
	for m: Moves in pool:
		if m != null and m.pp > 0:
			available.append(m)

	if available.is_empty():
		return fallback_move
	
	
	return available[_rng.randi_range(0, available.size() - 1)]


func _check_if_battle_over()->void:
	print("_check_if_battle_over")
	if !_has_mons_available:
		Events.show_dialog("Battle is over")
		emit_signal("battle_over")
		pass
	pass
