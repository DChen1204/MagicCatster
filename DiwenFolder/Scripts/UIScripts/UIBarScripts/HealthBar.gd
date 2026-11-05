extends ProgressBar

# This script is to control health bars. 

# The character that has this health bar. 
@export var character: Character

func _ready() -> void:
	# Sets the values of the health bar
	max_value = character.max_health
	value = character.health
	
	# Update the bar when health changes 
	character.health_changed.connect(_on_health_changed)
	
# Update the bar when health changes
func _on_health_changed() -> void:
	max_value = character.max_health
	value = character.health
