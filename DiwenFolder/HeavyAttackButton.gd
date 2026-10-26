extends Button

@export var actor: Character
@export var target: Character

func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	if is_instance_valid(target) and is_instance_valid(actor):
		actor.heavy_attack(target)
