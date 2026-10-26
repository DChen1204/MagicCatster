extends Node

signal health_changed(new_value: float)

@export var max_health_point: float = 100.0
@export var health_point: float = 100.0
var is_dead: bool = false

# func _ready():
	

# Call the following methods when taking damage and healing
func take_damage(amount: float) -> void:
	health_point -= amount;
	health_point = clampf(health_point, 0, max_health_point)
	if (health_point == 0):
		is_dead = true
	health_changed.emit(health_point)
		
func heal(amount: float) -> void:
	health_point += amount;
	health_point = clampf(health_point, 0, max_health_point)
	health_changed.emit(health_point)
