extends Node

signal health_changed(new_value: float)
signal become_dead(new_value: bool)

@export var max_health_point: float = 100.0
@export var health_point: float = 100.0
var is_dead: bool = false


# Call the following methods when taking damage and healing
func take_damage(amount: float) -> void:
	if !is_dead:
		health_point -= amount;
		health_point = clampf(health_point, 0, max_health_point)
		if (health_point <= 0):
			is_dead = true
			print("Someone is dead!")
			become_dead.emit(true)
		health_changed.emit(health_point)
		
		
func heal(amount: float) -> void:
	if !is_dead:
		health_point += amount;
		health_point = clampf(health_point, 0, max_health_point)
		health_changed.emit(health_point)
