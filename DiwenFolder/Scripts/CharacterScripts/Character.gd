
class_name Character
extends Node2D

# Base class of all characters

# Base attack
var attack: float

# Base defense
var defense: float

# Max hp
var max_health: float

# health
var health: float

# True if controlled by the player
var is_play_character: bool

# Max SP
var max_sp: int = 0

# SP (applicable when controlled by player)
var sp: int = 0

# whether the character is shielding
# var shielded: bool

# the name of the character
var character_name: String = "DEFAULT NAME"

# whether dead or not
var is_dead: bool

# SP change event notifier
signal sp_changed(current_sp: int, max_sp: int)

# Shield change event notifier
signal shield_changed(new_shield: bool)

# Health change event notifier
signal health_changed(new_value: float)

# Character is dead event notifier
# signal become_dead(new_value: bool)

# Assign stats to the character
func assign_stats(att: float, def: float, max_hp: float, is_play: bool, new_max_sp: int = 0):
	attack = att
	defense = def
	max_health = max_hp
	health = max_health
	is_play_character = is_play
	max_sp = new_max_sp
	sp = 0
	is_dead = false

# Assign name to the character
func set_character_name(new_name: String):
	character_name = new_name
	
# Handle death of the character
func on_dead():
	is_dead = true
	print("%s is dead!" % character_name)
	# Tell the GameManager
	GameManager.register_dead(self)
	
# Called when a character takes damager
func take_damage(amount: float) -> void:
	health -= amount;
	health = clampf(health, 0, max_health)
	if (health <= 1):
		on_dead()
	# Tell the healthbar the new health
	health_changed.emit()
	
# Damage this character takes from an attack of the given power
#func calc_damage(attacker: Character, power: float) -> float:
	#return (attacker.attack / defense) * power
		
# Called when a character is healed
func heal(amount: float) -> void:
	health += amount;
	health = clampf(health, 0, max_health)
	health_changed.emit()
	
"""
Shakes the sprite a few times; for acting getting attacked
- sprite: the sprite of the character to shake
- times: the number of times to randomly jump, default is 10
- amount: max offset from the center when jump, default is 5.0
- step: seconds between each jump, default is 0.05
"""
func shake_sprite(sprite: Sprite2D, times: int = 10, amount: float = 5.0, step: float = 0.05) -> Tween:
	# Record the sprite's original position
	var origin := sprite.offset
	
	# Create the tween and set the easing curve to sine (looks less snappy)
	var tween := sprite.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	# Randomly jump the sprite several times
	for i in times:
		var jitter = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		tween.tween_property(sprite, "offset", origin + jitter, step)
		
	# Restore the sprite to original posisition and return tween
	tween.tween_property(sprite, "offset", origin, step)
	return tween
	
