extends RichTextLabel

# This script controls the health text of a character.

# The character that has this health text. 
@export var target: Character

func _ready() -> void:
	# Update the text
	text = "%s HP: %d / %d" % [target.character_name, target.health, target.max_health]
	
	# Update the text when sp changes
	target.health_changed.connect(_on_hp_changed)
	
# Update the text when health changes
func _on_hp_changed() -> void:
	text = "%s HP: %d / %d" % [target.character_name, target.health, target.max_health]
