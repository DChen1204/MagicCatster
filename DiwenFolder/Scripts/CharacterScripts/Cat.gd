extends Character

# This is the script for the Cat Protagonist of the game.

# End turn button
@onready var end_turn_button: Button = $"../TurnManager/EndTurnButton"

#SFX for attacks
@onready var sfx_basicAttack1 = $sfx_basicAttack1


"""
Initial stats of the Cat
Base Attack = 300
Base Defense = 10
Max Health = 300
Play Character = true
Max SP = 10
Character Name = Catster
"""

# The toggle for goldfish heal ability
var goldfish_heal_toggle: CheckButton

# The toggle for turtle block ability
var turtle_block_toggle: CheckButton

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(300, 10, 300, true, 10)
	super.set_character_name("Catster") 
	
	# Notify SP change
	restore_sp(0)
	
	# Notify health change
	health_changed.emit()
	
	# Get abilities if avaliable
	goldfish_heal_toggle = get_node_or_null("GoldfishHealToggle")
	turtle_block_toggle = get_node_or_null("TurtleBlockToggle")
	
	# Register with GameManager
	GameManager.register_player(self)
	print("Catster registered!")
	
# Reset the character when resetting the game
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character, max_sp)
	restore_sp(5)
	health_changed.emit()

# Called when it's its turn
func play_turn():
	# Refills SP every turn (alternable design choice) 
	restore_sp(5)
	
	# Apply Goldfish heal
	if goldfish_heal_toggle != null && goldfish_heal_toggle.button_pressed:
		if GameManager.get_turn_number() % 3 == 0:
			super.heal(max_health * 0.1)

	# Its turn would not end until end turn button is pressed
	await end_turn_button.pressed 
	
	
# Skill Lists
# The Cat's First Skill: Paw Attack, 500% Damage
func cat_paw_scratch(target: Character):
	if (sp >= 5):
		sp -= 5
		sp_changed.emit()
		print("Cat paw scratch enemy.")
		target.got_cat_paw_scratch(self, 5)
		sfx_basicAttack1.play()

# Second skill: acid spray, corrodes shield, 300% Damage
func cat_acid_spray(target: Character):
	if (sp >= 5):
		sp -= 5
		sp_changed.emit()
		print("Cat acid spray enemy.")
		target.got_cat_acid_spray(self, 3)

# Got affected by skills list
func got_goldfish_bubble_attack(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	# Blocked by turtle ability
	if turtle_block_toggle != null && turtle_block_toggle.button_pressed:
		if randf() < 0.25:
			return
	if damage:
		super.take_damage(damage)
		
func got_turtle_shell_attack(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	# Blocked by turtle ability
	if turtle_block_toggle != null && turtle_block_toggle.button_pressed:
		if randf() < 0.25:
			return
	if damage:
		super.take_damage(damage)
		
# Restore SP function
func restore_sp(amount: int):
	sp += amount;
	sp = clamp(sp, 0, max_sp)
	sp_changed.emit()
