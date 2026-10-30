extends RichTextLabel

# This scripts controls the turn number display text.

# The turn manager that has the turn number. 
@export var turn_manager: Node

func _ready() -> void:
	# Update the text
	text = "Turn %d" % turn_manager.turn_number
	
	# Update the text when turn changes
	turn_manager.turn_changed.connect(_on_turn_number_changed)
	
# Update the text when turn changes
func _on_turn_number_changed(new_value: int) -> void:
	text = "Turn %d" % new_value
