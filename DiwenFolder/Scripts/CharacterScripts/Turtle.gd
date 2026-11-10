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

#SFX for attacks
@onready var sfx_basicAttack2 = $sfx_basicAttack2

# The dialogue box of this character.
@onready var dialogue_box: RichTextLabel = $"TurtleDialogueBox"

# Shield stats 
var shield: float
var max_shield: float

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(150, 20, 300, false)
	super.set_character_name("Rock")

	health_changed.emit()
	
	# The shield is based on max health
	max_shield = max_health
	shield = max_shield
	shield_changed.emit()
	
	dialogue_box.text = "Baby don't hurt me!"
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Rock registered!")
	
# Reset itself when called
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	shield_changed.emit()
	dialogue_box.text = "Baby don't hurt me!"
	

# Play its turn
func play_turn():
	# Pause for some time to pretend thinking
	dialogue_box.text = "Rock is digging up earth..."
	await get_tree().create_timer(1.5).timeout
	decide_action()
	
# Enemy AI deciding what to do in its turn
# For Turtle, 
func decide_action():
	if (shield > 0):
		turtle_shell_attack()
	else:
		turtle_shield()
		

# List of Skills
func turtle_shell_attack():
	print("Rock Crystal Pillars.")
	GameManager.player.got_turtle_shell_attack(self, 1)
	sfx_basicAttack2.play()
	dialogue_box.text = "Rock struck Catster with Crystal Pillars!"
	
func turtle_shield():
	print("Turtle shield.")
	shield = max_shield
	shield_changed.emit()
	dialogue_box.text = "Rock reinforced its shell!"

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
func got_cat_pounce(attacker: Character, dmg_percentage: float):
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
		

func got_cat_ult_scratch(attacker: Character, dmg_percentage: float):
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
		
	# Calculate health loss
	if total_damage > 0:
		super.take_damage(total_damage)
		
	
