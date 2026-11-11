extends Character

# This is the script for the Cat Protagonist of the game.

#SFX for attacks
@onready var sfx_ult_scratch = get_node_or_null("sfx_ult_scratch")
@onready var sfx_pounce = get_node_or_null("sfx_pounce")


"""
Initial stats of the Cat
Base Attack = 200
Base Defense = 200
Max Health = 500
Play Character = true
Max SP = 100
Character Name = Catster
"""

# Skill tuning. Base Power is multiplied by POWER_SCALE to get
# the damage multiplier (50 -> 5.0)
# const POWER_SCALE: float = 0.1

const BLOCK_COST: int = 10
const BLOCK_DAMAGE_MULT: float = 0.5

const POUNCE_COST: int = 30
const POUNCE_POWER: float = 100.0

const ULT_SCRATCH_COST: int = 70
const ULT_SCRATCH_POWER: float = 500.0

const HYDRO_CLEANSE_COST: int = 30
const HYDRO_CLEANSE_AMOUNT: float = 50
const HYDRO_CLEANSE_TURN: int = 5
var hydro_cleanse_on: bool = false
var hydro_cleanse_current_turn: int = 1

const HYDRO_PURIFY_COST: int = 30
const HYDRO_PURIFY_AMOUNT: float = 175

const SP_RECOVER_RATE: int = 30

# True while Block is active (until the start of the Cat's next turn)
var is_blocking: bool = false

# Emitted when the Cat finishes its one action, which ends its turn
signal action_finished

# True once the Cat has committed to an action this turn
var has_acted: bool = false

# The text for goldfish heal ability
var water_cleanse_text: RichTextLabel
var water_purify_text: RichTextLabel

# Whether we have the following abilities unlocked
var water_cleanse: bool = false
var water_purify: bool = false

@onready var sprite: Sprite2D = $CatSprite
var original_modulate: Color
var flashed_once: bool = false

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(200, 200, 500, true, 100)
	super.set_character_name("Catster") 
	
	# Notify SP change
	restore_sp(max_sp)
	
	# Notify health change
	health_changed.emit()
	
	# Add potential chosen attack
	add_chosen_attack()
	
	# Dim itself
	sprite.modulate = Color(0.5, 0.5, 0.5) 
	
	# Register with GameManager
	GameManager.register_player(self)
	print("Catster registered!")
	
	detect_attack_texts()
	
	original_modulate = sprite.modulate
	
	
# Reset the character when resetting the game
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character, max_sp)
	_set_blocking(false)
	restore_sp(max_sp)
	health_changed.emit()
	detect_attack_texts()

# Called when it's its turn
func play_turn():
	
	# Undim when it is its turn
	sprite.modulate = Color(1, 1, 1,) 
	
	has_acted = false
	# Block from the last turn wears off
	_set_blocking(false)
	# Refills SP every turn 
	restore_sp(SP_RECOVER_RATE)
	
	# Apply Goldfish Water Cleanse
	#if water_cleanse and hydro_cleanse_on:
	#	cat_resolve_hydro_cleanse()
	if hydro_cleanse_on:
		cat_resolve_hydro_cleanse()
			
	# Water Purify is to negate debuff
	# It is a temp effect, and not implemented yet.
	
	# The turn ends as soon as the one action finishes
	await action_finished
	
	# Dim itself after its turn
	await get_tree().create_timer(1.0).timeout
	sprite.modulate = Color(0.5, 0.5, 0.5)
	
	
# Skill Lists
# Block: Costs 10 SP, halves damage taken until the next playable turn
func cat_block():
	if not _begin_action(BLOCK_COST):
		return
	_set_blocking(true)
	print("Catster blocks.")
	GameManager.turn_log.animate("Catster is blocking...", 0.5)
	#_play_sfx(block)
	await get_tree().create_timer(1.0).timeout
	_end_action()

# Pounce: Costs 10 SP, Base Power 50
func cat_pounce(target: Character):
	if not _begin_action(POUNCE_COST):
		return
	await get_tree().create_timer(0.5).timeout
	target.got_cat_pounce(self, POUNCE_POWER)
	_play_sfx(sfx_pounce)
	print("Catster pounced onto enemy.")
	GameManager.turn_log.animate("Catster pounced onto the enemy.", 1.0)
	await get_tree().create_timer(2.0).timeout
	_end_action()
		
# Ultimate Scratch: Costs 50 SP, Base Power 100, pierces through shields
func cat_ult_scratch(target: Character):
	if not _begin_action(ULT_SCRATCH_COST):
		return
	await get_tree().create_timer(0.5).timeout
	target.got_cat_ult_scratch(self, ULT_SCRATCH_POWER)
	_play_sfx(sfx_ult_scratch)
	print("Catster unleashed Ultimate Scratch!")
	GameManager.turn_log.animate("Catster unleashed Ultimate Scratch!", 1.0)
	await get_tree().create_timer(2.0).timeout
	_end_action()
	
# Hydro Cleanse: Heal hp over time
func cat_hydro_cleanse():
	if not _begin_action(HYDRO_CLEANSE_COST):
		return
	await get_tree().create_timer(0.5).timeout
	hydro_cleanse_on = true
	super.heal(HYDRO_CLEANSE_AMOUNT)
	hydro_cleanse_current_turn = 1
	print("Cat used hydro cleanse.")
	GameManager.turn_log.animate("Catster called Poseidon for Hydro Cleanse.", 1.0)
	await get_tree().create_timer(2.0).timeout
	_end_action()
	
func cat_hydro_purify():
	if not _begin_action(HYDRO_PURIFY_COST):
		return
	await get_tree().create_timer(0.5).timeout
	super.heal(HYDRO_PURIFY_AMOUNT)
	print("Cat used hydro purify.")
	GameManager.turn_log.animate("Catster called Poseidon for Hydro Pruify.", 1.0)
	await get_tree().create_timer(2.0).timeout
	_end_action()
	

# Hover text for the skill buttons
func get_skill_tooltip(skill_name: String) -> String:
	match skill_name:
		"block":
			return "Cost: %d SP\nHalves the damage you take until your next turn." % BLOCK_COST
		"pounce":
			return "Cost: %d SP\nPower: %d\nA quick strike that does damage." % [POUNCE_COST, POUNCE_POWER]
		"ult":
			return "Cost: %d SP\nPower: %d\nA devastating scratch with big damage." % [ULT_SCRATCH_COST, ULT_SCRATCH_POWER]
		"cleanse":
			return "Cost: %d SP\nHeal %d HP over %d turns." % [HYDRO_CLEANSE_COST, HYDRO_CLEANSE_AMOUNT, HYDRO_CLEANSE_TURN]
		"purify":
			return "Cost: %d SP\nHeal %d HP." % [HYDRO_PURIFY_COST, HYDRO_PURIFY_AMOUNT]
	return ""
	
# Starts an action. Allowed once per turn, and only with enough SP.
# Return false (and changes nothing) if it can't be taken, so a failed
# click doesn't use up the turn
func _begin_action(cost: int) -> bool:
	if has_acted or sp < cost:
		return false
	has_acted = true
	sp -= cost
	sp_changed.emit()
	return true
	
# Finish the action, which ends the Catster's turn
func _end_action():
	action_finished.emit()

# Got affected by skills list
# Goldfish list
func got_goldfish_bubble_attack(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
	got_hit_effect()
	
func cat_resolve_hydro_cleanse():
	hydro_cleanse_current_turn += 1
	if hydro_cleanse_current_turn >= HYDRO_CLEANSE_TURN:
		hydro_cleanse_on = false
	print("Cat continue cleanse.")
	super.heal(HYDRO_CLEANSE_AMOUNT)

# Turtle list
func got_turtle_bite_dust(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
	got_hit_effect()
func got_turtle_tick_damage(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
	got_hit_effect()
func got_turtle_emerald_splash(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
	if !flashed_once:
		got_hit_effect()
		flashed_once = true

# Shared damage handling for every enemy attack
func _receive_hit(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	# Blocked by turtle ability
	#if turtle_block_toggle != null && turtle_block_toggle.button_pressed:
	#	if randf() < 0.25:
	#		return
	# Catster's block halves the damage
	if is_blocking:
		damage *= BLOCK_DAMAGE_MULT
	if damage:
		print("Cat takes %f damages." % damage)
		take_damage(damage)


# Turn Block on or off, and tint the sprite so the player can see it
func _set_blocking(on: bool):
	is_blocking = on
	var sprite = get_node_or_null("CatSprite")
	if sprite:
		sprite.modulate = Color(0.6, 0.8, 1.0) if on else Color(1, 1, 1)

# Play a sound if that node exists
func _play_sfx(sfx):
	if sfx != null:
		sfx.play()
		
# Flash effect for getting hit
func got_hit_effect():
	for i in 2:
		sprite.modulate = Color(3, 3, 3)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate
		await get_tree().create_timer(0.1).timeout
		
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
