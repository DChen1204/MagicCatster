extends ProgressBar

# This script is to control SP bar. 

# The character that has this SP bar. 
@export var character: Character

func _ready() -> void:
	# Sets the values of the SP bar
	max_value = character.max_sp
	value = character.sp
	
	# Update the bar when SP changes 
	character.sp_changed.connect(_on_sp_changed)
	
# Update the bar when SP changes
func _on_sp_changed() -> void:
	max_value = character.max_sp
	value = character.sp
	
