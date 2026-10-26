extends RichTextLabel

@export var target: Character

func _ready() -> void:
	if target.shielded:
		text = "Enemy Shielded!"
	else:
		text = ""
	target.shield_changed.connect(_on_shield_changed)
	
func _on_shield_changed(new_value: bool) -> void:
	if new_value:
		text = "Enemy Shielded!"
	else:
		text = ""
