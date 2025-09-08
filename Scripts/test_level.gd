class_name TestLevel
extends Node2D

const PLAYER = preload("res://Scenes/player.tscn")
@onready var spawn_area_detection: Area2D = %SpawnAreaDetection
var player = PLAYER.instantiate()
@onready var battle_screen: BattleScreen = %BattleScreen

@export var monster_pool: Array[MonsResource]

func _ready() -> void:
	randomize()
	add_child(player)
	spawn_area_detection.body_entered.connect(_on_body_entered)
	spawn_area_detection.body_exited.connect(_on_body_exit)
	player.body.battle_started_triggered.connect(_on_battle)

func _on_body_exit(body)->void:
	if body.is_in_group("Player"):
		print("Player leaving area")
		player.body.is_in_spawn_area = false

func _on_body_entered(body)->void:
	if body.is_in_group("Player"):
		print("Player Detected")
		player.body.is_in_spawn_area = true

func _on_battle()->void:
	var mon_spawn:MonsResource = monster_pool.pick_random()
	var mon_copy = mon_spawn.duplicate(true)
	Events.battle_started(mon_copy)
	print("Mons ", mon_spawn.mon_name, 
	  "  Copy mons ", mon_copy.mon_name)
