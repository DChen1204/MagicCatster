extends RichTextLabel

@export var target: Node

func _ready() -> void:
	text = "Turn %d" % target.turn_number
	target.turn_number_changed.connect(_on_turn_number_changed)
	
func _on_turn_number_changed(new_value: int) -> void:
	text = "Turn %d" % new_value
