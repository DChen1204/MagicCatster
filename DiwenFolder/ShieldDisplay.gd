extends RichTextLabel

@export var target: Character

func _ready() -> void:
	if target.shielded:
		text = "Enemy Shield"
	else:
		text = ""
	target.shield_changed.connect(_on_shield_changed)
	
func _on_shield_changed(new_value: bool) -> void:
	if new_value:
		text = "Enemy Shield"
	else:
		text = ""
