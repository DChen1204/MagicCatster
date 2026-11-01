extends ProgressBar

# This script is to control SP bar. 

# The health component of the character that has this health bar. 
@export var character: Character

func _ready() -> void:
	# Sets the values of the health bar
	max_value = character.max_sp
	value = character.sp
	
	# Update the bar when health changes 
	character.sp_changed.connect(_on_sp_changed)
	
# Update the bar when health changes
func _on_sp_changed() -> void:
	max_value = character.max_sp
	value = character.sp
	
