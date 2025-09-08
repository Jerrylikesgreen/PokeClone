class_name BattleManager extends PanelContainer

signal _battle_ended_signal
@onready var battle_screen: BattleScreen = $".."

@onready var enemy_progress_bar_timer: Timer = %EnemyProgressBarTimer
@onready var enemy_progress_bar: ProgressBar = %EnemyProgressBar
@onready var enemy_health_bar: ProgressBar = %EnemyHealthBar
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var player_progress_bar_timer: Timer = %PlayerProgressBarTimer
@onready var player_progress_bar: ProgressBar = %PlayerProgressBar
@onready var attack_menu_buttons: AttackMenuButtons = %AttackMenuButtons
@onready var battle_menu: Panel = %BattleMenu
## Will grab from globals - currently hard codded. 
@export var enemy_mon_resource: MonsResource
@export var player_mon_resource: MonsResource
@onready var battle_menu_buttons: GridContainer = %BattleMenuButtons
@onready var enemy_mons: EnemyMons = %EnemyMons
@onready var player_mons: PlayerMons = %PlayerMons

var enemy_mons_org: EnemyMons
var _player_attack_selected:Moves
var _player_can_attack:bool = false
var _enemy_can_attack:bool = false
var _trainer_resource: TrainerResource
var _battle_ended: bool = false

func _ready() -> void:
	_player_health_setup()
	_enemy_health_setup()
	Events.target_health_changed_signal.connect(_on_target_health_changed)
	enemy_mons.enemy_mon_resource = enemy_mon_resource
	enemy_mons.enemy_move_chosen.connect(_on_enemy_move_chosen)
	player_mons.player_mon_resource = player_mon_resource
	enemy_mons.battle_over.connect(_on_battle_over)


func _on_battle_over()->void:
	_enemy_can_attack = false
	_battle_ended = true
	enemy_progress_bar_timer.stop()
	emit_signal("_battle_ended_signal")


func _on_enemy_move_chosen(move:Moves)->void:
	if !battle_screen._battling:
		return
	if move == null:
		return
	enemy_attack_selected(move)
	print("move Chose")

func _on_target_health_changed(target: MonsResource, previous: int, current: int) -> void:
	if target._player:
		print("Target is player, skipped")
		return
	enemy_health_bar.min_value = 0
	enemy_health_bar.max_value = target.max_health  
	enemy_health_bar.value = clampf(current, enemy_health_bar.min_value, enemy_health_bar.max_value)
	var new_text = "HP change: %s %d → %d | bar=%d/%d" % [
	target.mon_name, previous, current,
	int(enemy_health_bar.value), int(enemy_health_bar.max_value)
]

	battle_screen.debug_lable.set_text(new_text)
	
	

func _player_health_setup()->void:
	player_progress_bar_timer.timeout.connect(_on_player_turn_tick)
	player_progress_bar.value = player_mon_resource.speed * 1.5
	player_health_bar.max_value = player_mon_resource.max_health
	player_health_bar.value = player_mon_resource.health

func _enemy_health_setup()->void:
	enemy_progress_bar_timer.timeout.connect(_on_enemy_turn_tick)
	enemy_progress_bar.value = enemy_mon_resource.speed * 1.5
	enemy_health_bar.max_value = enemy_mon_resource.health
	enemy_health_bar.value = enemy_mon_resource.health
	

func _on_enemy_turn_tick() -> void:
	if !battle_screen._battling:
		return
	if _enemy_can_attack:
		return
	var maxv := enemy_progress_bar.max_value
	enemy_progress_bar.step = 0.0

	enemy_progress_bar.value = clamp(
		enemy_progress_bar.value + enemy_mon_resource.speed * 1.5,
		enemy_progress_bar.min_value,
		maxv
	)

	if enemy_progress_bar.value >= maxv:
		print("Enemy can attack")
		_enemy_can_attack = true
		enemy_mons.attack()



func _on_player_turn_tick() -> void:
	if !battle_screen._battling:
		return
	if _player_can_attack:
		return
	var maxv := player_progress_bar.max_value
	player_progress_bar.step = 0.0

	player_progress_bar.value = clamp(
		player_progress_bar.value + player_mon_resource.speed * 1.5,
		player_progress_bar.min_value,
		maxv
	)

	if player_progress_bar.value >= maxv:
		print("Player can attack")
		_player_can_attack = true
		battle_menu_buttons.visible = true

func enemy_attack_selected(move:Moves)->void:
	if !battle_screen._battling:
		print("Passed enemy attack selected signal. Not battling")
		return
		
	_enemy_can_attack = false
	enemy_progress_bar.value = 0
	var dmg_calculated:int = move.power 
	battle_screen.debug_lable.append_text(" \n Enemy Attacked with " + str(move.power) + " and player has " + str(player_mon_resource.health) )
	if move._heal:
		_heal_enemy_mons(dmg_calculated)
		return

	_damage_to_player(player_mon_resource, move)
	

func _heal_enemy_mons(dmg_calculated: int)->void:
	enemy_mon_resource.health += dmg_calculated
	enemy_health_bar.value = enemy_mon_resource.health


func _damage_to_player(target:MonsResource, move_used:Moves)->void:
	print("_damage_to_player")
	var _dmg:int = move_used.power
	var _def:int = target.defence
	var _dmg_calculation:int = _def * .5 * _dmg * .2
	Events.damage_done(_dmg_calculation, target)
	player_health_bar.value = target.health
	print("Damage done to player ", _dmg_calculation)
	print("player health ", target.health)


func player_attack_selected(move_selected:Moves)->void:
	_player_can_attack = false
	player_progress_bar.value = 0
	_player_attack_selected = move_selected
	attack_menu_buttons.visible = false
	
