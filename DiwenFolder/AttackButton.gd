extends Button

@export var target: Health

func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	if is_instance_valid(target):
		target.take_damage(10.0)
