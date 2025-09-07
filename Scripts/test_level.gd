class_name TestLevel
extends Node2D

const PLAYER = preload("res://Scenes/player.tscn")

@onready var map: TileMapLayer = %Map  # <- it's a TileMapLayer

func _ready() -> void:
	var player = PLAYER.instantiate()
	map.add_child(player)  # fine; TileMapLayer is a Node2D
	player.player_body.tilemap = map
	player.player_body.tile_triggered.connect(_on_player_tile_triggered)

func _on_player_tile_triggered(layer: TileMapLayer, cell: Vector2i) -> void:
	print("Tile triggered at ", cell, " on node ", layer.name)
	# Example: consume it
	# layer.set_cell(cell, -1)
