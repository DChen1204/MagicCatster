extends Node

# The health object of the characters. 

# Health change event notifier
signal health_changed(new_value: float)

# Character is dead event notifier
signal become_dead(new_value: bool)

@export var max_health_point: float = 100.0
@export var health_point: float = 100.0
var is_dead: bool = false

# Called when a character takes damager
func take_damage(amount: float) -> void:
	if !is_dead:
		health_point -= amount;
		health_point = clampf(health_point, 0, max_health_point)
		if (health_point <= 0):
			is_dead = true
			print("A character is dead!")
			# Tell the characters they are dead
			become_dead.emit(true)
		# Tell the healthbar the new health
		health_changed.emit(health_point)
		
# Called when a character is healed
# Not in any use right now		
func heal(amount: float) -> void:
	if !is_dead:
		health_point += amount;
		health_point = clampf(health_point, 0, max_health_point)
		health_changed.emit(health_point)
