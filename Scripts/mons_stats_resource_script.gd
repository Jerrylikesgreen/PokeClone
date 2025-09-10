
extends Resource
class_name Stats

@export var max_health: int = 100
@export var health: int = 100
@export var attack: int = 10
@export var s_attack: int = 10
@export var defence: int = 10
@export var s_defence: int = 10
@export var speed: int = 10
@export var hit: float = 1.0


func has_property(prop: StringName) -> bool:
	return prop in get_property_list().map(func(p): return p.name)
