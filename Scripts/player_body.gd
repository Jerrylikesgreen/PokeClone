class_name PlayerBody
extends CharacterBody2D

@export var SPEED := 200.0
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var foot: Area2D = %FootSensor

signal tile_triggered(tilemap: TileMapLayer, cell: Vector2i)
var tilemap: TileMapLayer

const DEADZONE := 0.01

func _ready() -> void:
	if not foot.body_entered.is_connected(_on_foot_entered):
		foot.body_entered.connect(_on_foot_entered)

func _on_foot_entered(_body: Node) -> void:
	if tilemap == null: return
	var cell := tilemap.local_to_map(tilemap.to_local(foot.global_position))
	var td := tilemap.get_cell_tile_data(cell)   # TileMapLayer API
	if td and td.has_custom_data("trigger") and td.get_custom_data("trigger"):
		emit_signal("tile_triggered", tilemap, cell)

func _physics_process(_dt: float) -> void:
	var dir := Input.get_vector("Left", "Right", "Up", "Down")
	animated_sprite_2d.play( "Idle" if dir.length() <= DEADZONE else "Moving")
	if absf(dir.x) > DEADZONE:
		animated_sprite_2d.flip_h = dir.x < 0.0
	velocity = dir * SPEED
	move_and_slide()
