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
@onready var status: Label = %Status

@export var player_status_tracker: Array[Effects]
@export var enemy_status_tracker: Array[Effects]

var enemy_mons_org: EnemyMons
var _player_attack_selected:Moves
var _player_can_attack:bool = false
var _enemy_can_attack:bool = false
var _trainer_resource: TrainerResource
var _battle_ended: bool = false

func _ready() -> void:
	_player_health_setup()
	Events.target_health_changed_signal.connect(_on_target_health_changed)
	player_mons.player_mon_resource = player_mon_resource

func battle_start()->void:
	_enemy_health_setup()
	enemy_mons.enemy_mon_resource = enemy_mon_resource
	enemy_mons.enemy_move_chosen.connect(_on_enemy_move_chosen)
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
	enemy_health_bar.max_value = target.stats.max_health  
	enemy_health_bar.value = clampf(current, enemy_health_bar.min_value, enemy_health_bar.max_value)
	var new_text = "HP change: %s %d → %d | bar=%d/%d" % [
	
	target.mon_name, previous, current,
	int(enemy_health_bar.value), int(enemy_health_bar.max_value)
]

	
	
	

func _player_health_setup()->void:
	player_progress_bar_timer.timeout.connect(_on_player_turn_tick)
	player_progress_bar.value = player_mon_resource.stats.speed * 1.5
	player_health_bar.max_value = player_mon_resource.stats.max_health
	player_health_bar.value = player_mon_resource.stats.health

func _enemy_health_setup()->void:
	enemy_progress_bar_timer.timeout.connect(_on_enemy_turn_tick)
	enemy_progress_bar.value = enemy_mon_resource.stats.speed * 1.5
	enemy_health_bar.max_value = enemy_mon_resource.stats.health
	enemy_health_bar.value = enemy_mon_resource.stats.health
	

func _on_enemy_turn_tick() -> void:
	if !battle_screen._battling:
		return
	if _enemy_can_attack:
		return
	var maxv := enemy_progress_bar.max_value
	enemy_progress_bar.step = 0.0

	enemy_progress_bar.value = clamp(
		enemy_progress_bar.value + enemy_mon_resource.stats.speed * 1.5,
		enemy_progress_bar.min_value,
		maxv
	)

	if enemy_progress_bar.value >= maxv:
		print("Enemy can attack")
		_enemy_can_attack = true
		enemy_mons.attack()

func _check_player_status_effect() -> void:
	var current_player_status_conditions: Array = player_mons.current_status
	if current_player_status_conditions.is_empty():
		return

	# Iterate backwards so we can safely remove expired statuses
	for i in range(current_player_status_conditions.size() - 1, -1, -1):
		var condition: Effects = current_player_status_conditions[i]

		if condition.duration > 0:
			condition.duration -= 1
			
			# Apply the status effect tick here
			_apply_status_tick(player_mon_resource, condition)

			# Remove expired effect
			if condition.duration <= 0:
				current_player_status_conditions.remove_at(i)
		else:
			# Already expired, remove it
			current_player_status_conditions.remove_at(i)
		_apply_status_tick(player_mon_resource, condition)

func _apply_status_tick(target: MonsResource, condition: Effects) -> void:
	# Only handling HP ticks here; extend for others as needed
	if condition.target_stat != Effects.Stat.HEALTH:
		return

	# Block player damage at the source
	if target._player:
		print("Player tick ignored")
		return

	var stats := target.stats
	var max_hp := float(stats.get("max_health"))
	var cur_hp := float(stats.get("health"))

	# Positive multiplier -> damage (e.g., 0.05 = 5% max HP)
	# Negative multiplier -> heal (e.g., -0.05 = +5% max HP)
	var amount := max_hp * condition.multiplier
	var new_hp := clampf(cur_hp - amount, 0.0, max_hp)

	# Write & signal once
	if not is_equal_approx(new_hp, cur_hp):
		stats.set("health", new_hp)
		Events.target_health_changed_signal.emit(target, cur_hp, new_hp)

	# Optional: if this is only for UI/logs, keep it; if it also applies damage, REMOVE it.
	if Events.has_signal("damage_done"):
		Events.damage_done(amount, target)

	# Flavor text (rounded for readability)
	var shown := int(round(absf(amount)))
	if amount > 0.0:
		Events.show_dialog("%s takes %d damage from %s." % [target.mon_name, shown, condition.effect_name])
	elif amount < 0.0:
		Events.show_dialog("%s heals %d from %s." % [target.mon_name, shown, condition.effect_name])



func _on_player_turn_tick() -> void:
	if !battle_screen._battling:
		return
	if _player_can_attack:
		return
	var maxv := player_progress_bar.max_value
	player_progress_bar.step = 0.0

	player_progress_bar.value = clamp(
		player_progress_bar.value + player_mon_resource.stats.speed * 1.5,
		player_progress_bar.min_value,
		maxv
	)

	if player_progress_bar.value >= maxv:
		_player_can_attack = true
		battle_menu_buttons.visible = true

func enemy_attack_selected(move:Moves)->void:
	if !battle_screen._battling:
		print("Passed enemy attack selected signal. Not battling")
		return
		
	_enemy_can_attack = false
	enemy_progress_bar.value = 0
	var dmg_calculated:int = move.power 
	battle_screen.debug_lable.append_text(" \n Enemy Attacked with " + str(move.power) + " and player has " + str(player_mon_resource.stats.health) )
	if move._heal:
		_heal_enemy_mons(dmg_calculated)
		return

	_damage_to_player(player_mon_resource, move)
	_apply_effect(player_mon_resource, move)
	

func _heal_enemy_mons(dmg_calculated: int)->void:
	enemy_mon_resource.health += dmg_calculated
	enemy_health_bar.value = enemy_mon_resource.stats.health

func _apply_effect(target: MonsResource, move_used: Moves) -> void:
	print("Applying effects to ", target.mon_name, " due to ", move_used.name)
	print("Current statuses:", str(target.current_status))
	Events.show_dialog("Applying effects to " + target.mon_name + " due to " + move_used.name)
	var move_effects: Array[Effects] = move_used.effects
	if move_effects.is_empty():
		return

	for effect: Effects in move_effects:
		print("Effect in move:", effect, "Name:", effect.effect_name)

		if _has_status_by_name(target, effect.effect_name) != -1:
			print("Effect already applied: ", effect.effect_name)
			continue

		var stat_name: StringName = effect._get_stat_name(effect.target_stat)
		if stat_name == "":
			push_warning("Effect '%s' maps to empty stat name." % effect.effect_name)
			continue

		var stats_res: Resource = target.stats
		if not stats_res.has_property(stat_name):
			push_warning("Target has no stat named '%s'" % stat_name)
			continue

		var old_val := float(stats_res.get(stat_name))
		var new_val := old_val * effect.multiplier
		stats_res.set(stat_name, new_val)

		# Deep copy so duration/applied data are per-target
		var effect_instance: Effects = effect.duplicate(true)
		target.current_status.append(effect_instance)

		# UI: rebuild from source of truth (current_status)
		if is_instance_valid(status):
			status.text = _rebuild_status_label_text(target)

		# Emit accurate signals
		if String(stat_name) == "health":
			Events.target_health_changed_signal.emit(target, old_val, new_val)
			
		elif Events.has_signal("target_stat_changed_signal"):
			Events.target_stat_changed_signal.emit(target, String(stat_name), old_val, new_val)

		print(" -", stat_name, ":", old_val, "→", new_val)
		_apply_status_tick(target, effect_instance)


func _has_status_by_name(target: MonsResource, effect_name: String) -> int:
	for i in target.current_status.size():
		var e: Effects = target.current_status[i]
		if e.effect_name == effect_name:
			return i
	return -1


func _rebuild_status_label_text(target: MonsResource) -> String:
	var names: Array[String] = []
	for e: Effects in target.current_status:
		names.append(e.effect_name)
	return " ".join(names)






func _damage_to_player(target:MonsResource, move_used:Moves)->void:
	print("_damage_to_player")
	var _dmg:int = move_used.power
	var _def:int = target.stats.defence
	var _dmg_calculation:int = _def * .5 * _dmg * .2
	Events.damage_done(_dmg_calculation, target)
	player_health_bar.value = target.stats.health
	print("Damage done to player ", _dmg_calculation)
	print("player health ", target.stats.health)


func player_attack_selected(move_selected:Moves)->void:
	_player_can_attack = false
	player_progress_bar.value = 0
	_player_attack_selected = move_selected
	attack_menu_buttons.visible = false
	
