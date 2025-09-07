
## Defines the data for a single move/ability that a mob can use.
## Contains metadata such as name, description, type, element, power, PP, and accuracy.

class_name Moves
extends Resource

## Display name of the move.
@export var name: String
## Text description of what the move does (shown in UI/menus).

@export var description: String
## Category of the move:
## - 0 = Physical
## - 1 = Special

@export_enum("Physical", "Special") var type: int = 0
## Elemental type of the move (e.g., Fire, Water, etc.).
@export_enum("Fire", "Water", "Air", "Earth", "Dark", "Light") var element
@export var _heal:bool = false
## Base power of the move (damage or strength).
@export var power: int = 10
## Number of times this move can be used (like Pokémon PP).
@export var pp: int = 10
## Hit accuracy: 1.0 = always hits, 0.5 = 50% chance, etc.
@export var hit_chance: float = 1.0
