extends RichTextLabel

# This script controls the text popup for enemy shield. 

# The enemy that has this shield text
@export var target: Character

func _ready() -> void:
	# Adjust the text depending on whether the enemy has shield
	if target.shielded:
		text = "Enemy Shield"
	else:
		text = ""
		
	# Update the text when shield changes
	target.shield_changed.connect(_on_shield_changed)
	
# Update the text when shield changes
func _on_shield_changed(new_value: bool) -> void:
	if new_value:
		text = "Enemy Shield"
	else:
		text = ""
