extends ProgressBar

# This script is to control health bars. 

# The health component of the character that has this health bar. 
@export var health: Node

func _ready() -> void:
	# Sets the values of the health bar
	max_value = health.max_health_point
	value = health.health_point
	
	# Update the bar when health changes 
	health.health_changed.connect(_on_health_changed)
	
# Update the bar when health changes
func _on_health_changed(new_value: float) -> void:
	value = new_value
