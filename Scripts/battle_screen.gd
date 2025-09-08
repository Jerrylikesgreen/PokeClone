class_name BattleScreen
extends CanvasLayer
@onready var attack: AttackButton = %Attack
@onready var battle_manager: BattleManager = %BattleManager
@onready var enemy_mons: EnemyMons = %EnemyMons
@onready var enemy_progress_bar: ProgressBar = %EnemyProgressBar
@onready var enemy_health_bar: ProgressBar = %EnemyHealthBar
@onready var debug_lable: RichTextLabel = %DebugLable
@onready var enemy_mons_name: Label = %EnemyMonsName
@onready var player_health_bar: ProgressBar = %PlayerHealthBar

@onready var move_slot_1: Button = %MoveSlot1
@onready var move_slot_2: Button = %MoveSlot2
@onready var move_slot_3: Button = %MoveSlot3
@onready var move_slot_4: Button = %MoveSlot4
@onready var battle_menu_buttons: GridContainer = %BattleMenuButtons
@onready var attack_menu_buttons: AttackMenuButtons = %AttackMenuButtons
@onready var dialog_display: CanvasLayer = %DialogDisplay

const MAX_SLOTS := 4
var _move_buttons: Array[Button]
var _battling:bool = false 

func _ready() -> void:
	Events.battle_started_signal.connect(_on_battle_start)
	_move_buttons = [move_slot_1, move_slot_2, move_slot_3, move_slot_4]
	for btns in _move_buttons:
		btns.on_move_slot_pressed_signal.connect(_on_move_slot_pressed)

	attack.pressed.connect(_on_attack_button_pressed)
	_refresh_move_menu([])
	battle_manager._battle_ended_signal.connect(_on_battle_ended)




func _on_battle_ended() -> void:
	visible = false
	_battling = false
	dialog_display.get_child(0)._finish()
	dialog_display.visible = false
	Events.battle_ended_signal.emit()
	print("battle ended signal")
	


func _on_attack_button_pressed() -> void:
	battle_menu_buttons.visible = false
	attack_menu_buttons.visible = true

	var moves: Array = battle_manager.player_mon_resource.move_pool
	_refresh_move_menu(moves)
	

func _refresh_move_menu(moves: Array) -> void:
	for i in range(MAX_SLOTS):
		var btn := _move_buttons[i]
		if i < moves.size():
			var m = moves[i]
			btn.text = m.name  
			btn.set_meta("move", m) # stash the move resource onto btn 

	
func _on_move_slot_pressed(move_selected: Moves) -> void:
	if move_selected == null:
		return

	if move_selected.pp <= 0:
		Events.show_dialog("%s has no PP left!" % move_selected.move_name)
		return

	move_selected.pp = max(0, move_selected.pp - 1)
	battle_manager.player_attack_selected(move_selected)

	var text_to_display := "Player used %s and has [%d PP] left." % [
		move_selected.name, 
		move_selected.pp,
		
	]
	Events.show_dialog(text_to_display)
	if move_selected._heal:
		var _target: MonsResource = battle_manager.player_mon_resource
		_heal(_target, move_selected)
	else:
		var _target: MonsResource = battle_manager.enemy_mon_resource
		_damage(_target, move_selected)

func _heal(_target: MonsResource, move_selected: Moves)->void:
	var _dmg:int = move_selected.power
	var _def:int = _target.defence
	var _dmg_calculation:int = _def * .5 * _dmg * .2
	Events.heal_done(_dmg_calculation, _target)
	print(_dmg_calculation, "Healed")
	

func _damage(target:MonsResource, move_used:Moves)->void:
	var _dmg:int = move_used.power
	var _def:int = target.defence
	var _dmg_calculation:int = _def * .5 * _dmg * .2
	Events.damage_done(_dmg_calculation, target)
	var _debug_text = "\n%d Points of Damage done to %s" % [_dmg_calculation, target.mon_name]
	debug_lable.append_text(_debug_text)

	

func _on_battle_start(mon:MonsResource)->void:
	if _battling:
		return
	visible = true
	dialog_display.visible = true
	battle_manager.enemy_mon_resource = mon
	enemy_mons_name.set_text(mon.mon_name)
	battle_manager.enemy_progress_bar_timer.start()
	enemy_health_bar.value = mon.health
	var text:String = str(mon.health) + mon.mon_name
	debug_lable.append_text(text)
	_battling = true
