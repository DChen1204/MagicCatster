extends RichTextLabel

# This script controls the shield text of a character.

# The character that has this shield text. 
@export var target: Character

func _ready() -> void:
	# Update the text
	text = "%s Shield: %d / %d" % [target.name, target.shield, target.max_shield]
	
	# Update the text when shield changes
	target.shield_changed.connect(_on_shield_changed)
	
# Update the text when shield changes
func _on_shield_changed() -> void:
	text = "%s Shield: %d / %d" % [target.name, target.shield, target.max_shield]
	if target.shield < 1:
		hide()
	else:
		show()
		
