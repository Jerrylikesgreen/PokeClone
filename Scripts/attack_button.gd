class_name AttackButton extends Button

signal attack_pressed

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed()->void:
	emit_signal("attack_pressed")
