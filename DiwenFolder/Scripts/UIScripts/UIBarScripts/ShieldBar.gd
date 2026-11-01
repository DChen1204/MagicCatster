extends ProgressBar

# This script is to control shield bars. 

# The health component of the character that has this shield bar. 
@export var character: Character

func _ready() -> void:
	# Sets the values of the shield bar
	max_value = character.max_shield
	value = character.shield
	
	# Update the bar when shield changes 
	character.shield_changed.connect(_on_shield_changed)
	
# Update the bar when shield changes
func _on_shield_changed() -> void:
	max_value = character.max_shield
	value = character.shield
	if value < 1:
		hide()
	else:
		show()
