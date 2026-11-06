extends Character

# This is the script for the Cat Protagonist of the game.

# End turn button
@onready var end_turn_button: Button = $"../TurnManager/EndTurnButton"

#SFX for attacks
@onready var sfx_basicAttack1 = $sfx_basicAttack1
@onready var sfx_basicAttack2 = $sfx_basicAttack2


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
var water_cleanse_text: RichTextLabel
var water_purify_text: RichTextLabel

# The toggle for turtle block ability
var turtle_block_toggle: CheckButton

# Whether we have the following abilities unlocked
var water_cleanse: bool = false
var water_purify: bool = false

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
	
	# Add potential chosen attack
	add_chosen_attack()
	
	# Register with GameManager
	GameManager.register_player(self)
	print("Catster registered!")
	
	detect_attack_texts()
	
	
# Reset the character when resetting the game
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character, max_sp)
	restore_sp(0)
	health_changed.emit()
	detect_attack_texts()

# Called when it's its turn
func play_turn():
	# Refills SP every turn 
	restore_sp(5)
	
	# Apply Goldfish Water Cleanse
	if water_cleanse:
		if GameManager.get_turn_number() % 4 == 0:
			super.heal(max_health * 0.1)
			
	# Water Purify is to negate debuff
	# It is a temp effect, and not implemented yet.

	# Its turn would not end until end turn button is pressed
	await end_turn_button.pressed 
	
	
# Skill Lists
# The Cat's First Skill: Paw Attack, 500% Damage
func cat_paw_scratch(target: Character):
	if (sp >= 5):
		sp -= 5
		sp_changed.emit()
		print("Cat paw scratch enemy.")
		await get_tree().create_timer(1).timeout
		target.got_cat_paw_scratch(self, 5)
		sfx_basicAttack1.play()

# Second skill: Pounce, breaks down shields, 300% Damage
func cat_pounce(target: Character):
	if (sp >= 4):
		sp -= 4
		sp_changed.emit()
		print("Cat pounced onto enemy.")
		await get_tree().create_timer(1).timeout
		target.got_cat_pounce(self, 3)
		sfx_basicAttack2.play()

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
	
# Read and add chosen attack
func add_chosen_attack():
	var attack_to_add = GameManager.chosen_attack
	if !attack_to_add.is_empty():
		print("Adding attack %s." % attack_to_add)
		if attack_to_add == "water_cleanse":
			water_cleanse = true
		elif attack_to_add == "water_purify":
			water_purify = true
		
# Display ability texts
func detect_attack_texts():
	water_cleanse_text = get_node_or_null("WaterCleanseLabel")
	if water_cleanse_text != null:
		if water_cleanse:
			water_cleanse_text.show()
		else:
			water_cleanse_text.hide()
		
	water_purify_text = get_node_or_null("WaterPurifyLabel")
	if water_purify_text != null:
		if water_purify:
			water_purify_text.show()
		else:
			water_purify_text.hide()
