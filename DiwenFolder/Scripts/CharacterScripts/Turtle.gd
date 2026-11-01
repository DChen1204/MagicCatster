extends Character

# This is the script for the Turtle Enemy of the game.
# It should be relatively weak as a early game boss. 

"""
Stats of the Turtle
Base Attack = 150
Base Defense = 200
Base Health = 250
Play Character = false
SP = 0
Character Name = Rock
"""

# The dialogue box of this character.
@onready var dialogue_box: RichTextLabel = $"TurtleDialogueBox"

# The shield bar of turtle
# @onready var shield_bar: ProgressBar = $"TurtleShieldBar"

var shield: float
var max_shield: float

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(150, 20, 300, false)
	super.set_character_name("Rock")

	health_changed.emit()
	
	max_shield = max_health
	shield = max_shield
	shield_changed.emit()
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Rock registered!")
	
# Reset itself when called
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	shield_changed.emit()
	

# Play its turn
func play_turn():
	decide_action()
	
# Enemy AI deciding what to do in its turn
# For Turtle, 
func decide_action():
	if (shield > 0):
		turtle_shell_attack()
	else:
		turtle_shield()
		

# List of Skills
# maybe animate it like the turtle used the shell like a she
func turtle_shell_attack():
	print("Turtle shell attack Cat.")
	GameManager.player.got_turtle_shell_attack(self, 1)
	dialogue_box.text = "Rock threw its shell at you!"
	
func turtle_shield():
	print("Turtle shield.")
	shield = max_shield
	shield_changed.emit()
	dialogue_box.text = "Rock repaired its shell!"

# List of affected skills
func got_cat_paw_scratch(attacker: Character, dmg_percentage: float):
	var total_damage = (attacker.attack / self.defense) * dmg_percentage
	# Subtract the shield first
	if shield > 0:
		if shield >= total_damage:
			shield = shield - total_damage
			total_damage = 0
		else:
			total_damage = total_damage - shield
			shield = 0
		shield_changed.emit()
	
	# Calculate health loss
	if total_damage > 0:
		super.take_damage(total_damage)
		
# Corrodes shield
func got_cat_acid_spray(attacker: Character, dmg_percentage: float):
	var total_damage = (attacker.attack / self.defense) * dmg_percentage
	var shield_damage = (2 * attacker.attack / self.defense) * dmg_percentage
	if shield > 0:
		if shield >= shield_damage:
			shield = shield - shield_damage
			total_damage = 0
		else:
			shield_damage = shield_damage - shield
			total_damage = shield_damage / 2
			shield = 0
		shield_changed.emit()
	
	# Restore normal damage to health
	# total_damage /= 2.5

	# Calculate health loss
	if total_damage > 0:
		super.take_damage(total_damage)
		
	
