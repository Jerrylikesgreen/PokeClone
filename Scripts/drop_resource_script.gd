# DropResource.gd
class_name DropResource
extends Resource

@export var name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

# What kind of drop this is
enum DropType { ITEM, EXP, MONEY, TRAINER_XP }
@export var type: DropType = DropType.ITEM

## Amount (EXP gained, MONEY awarded, or ITEM quantity)
@export_range(0, 999_999, 1, "or_greater") var value: int = 0

## if it's an item drop - item resource here. 
@export var item: Resource  # TODO, ItemResource 
