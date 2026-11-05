extends Character

# This is the script for the Goldfish Enemy of the game.
# It should be relatively weak as a early game boss. 

"""
Stats of the Goldfish
Base Attack = 200
Base Defense = 10
Base Health = 400
Play Character = false
SP = 0
Character Name = Poseidon
"""

# The dialogue box of this character.
@onready var dialogue_box: RichTextLabel = $"GoldfishDialogueBox"

# The target of this character

# Whether the goldfish used heal the previous turn
# var used_heal: bool

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(200, 10, 400, false)
	super.set_character_name("Poseidon")
	# used_heal = false
	
	health_changed.emit()
	dialogue_box.text = "How dare you fight me!"
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Poseidon registered!")
	
# Reset itself when called
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	dialogue_box.text = "How dare you fight me!"

# Play its turn
func play_turn():
	# Pause for some time to pretend thinking
	dialogue_box.text = "Poseidon is summoning water..."
	await get_tree().create_timer(1.5).timeout
	# Do action
	decide_action()
	
# Enemy AI deciding what to do in its turn
# For Goldfish, heal when under half hp
func decide_action():
	if (health > max_health / 2):
		goldfish_bubble_attack()
	else:
		#if used_heal:
			#goldfish_bubble_attack()
			#used_heal = false
		#else:
		goldfish_water_heal()
			#used_heal = true
		
# List of Skills
func goldfish_bubble_attack():
	print("Goldfish bubble attack.")
	GameManager.player.got_goldfish_bubble_attack(self, 2)
	dialogue_box.text = "Poseidon spewed bubbles on Catster's face!"
	
func goldfish_water_heal():
	print("Goldfish heals itself.")
	super.heal(max_health * 0.5)
	dialogue_box.text = "Poseidon used Water Heal on itself!"
		
		
# List of affected skills
func got_cat_paw_scratch(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	if damage:
		super.take_damage(damage)
