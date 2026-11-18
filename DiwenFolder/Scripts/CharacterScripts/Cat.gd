extends Character

# This is the script for the Cat Protagonist of the game.

#SFX for attacks
@onready var sfx_ult_scratch = get_node_or_null("sfx_ult_scratch")
@onready var sfx_pounce = get_node_or_null("sfx_pounce")
@onready var sfx_block = get_node_or_null("sfx_block")
@onready var sfx_heal1 = get_node_or_null("sfx_heal1")
@onready var sfx_heal2 = get_node_or_null("sfx_heal2")


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

const ULT_SCRATCH_COST: int = 90
const ULT_SCRATCH_POWER: float = 400.0
#const ULT_SCRATCH_COST: int = 0
#const ULT_SCRATCH_POWER: float = 2000.0

#const HYDRO_CLEANSE_COST: int = 30
const HYDRO_CLEANSE_COOLDOWN: int = 5
const HYDRO_CLEANSE_AMOUNT: float = 25
const HYDRO_CLEANSE_TURN: int = 5

#const HYDRO_PURIFY_COST: int = 30
const HYDRO_PURIFY_COOLDOWN: int = 3
const HYDRO_PURIFY_AMOUNT: float = 90

const EARTH_SHIELD_COOLDOWN: int = 5
const EARTH_SHIELD_PERCENTAGE: float = 0.5

const EARTH_DUST_DAMAGE: float = 40.0
const EARTH_DUST_TICK_DAMAGE: float = 40.0 
const EARTH_DUST_DURATION: int = 5
const EARTH_DUST_COOLDOWN: int = 5

const SP_RECOVER_RATE: int = 30

# True while Block is active (until the start of the Cat's next turn)
var is_blocking: bool = false

# Emitted when the Cat finishes its one action, which ends its turn
signal action_finished

# True once the Cat has committed to an action this turn
var has_acted: bool = false

# The buttles for goldfish abilities
var hydro_cleanse_button: Button
var hydro_purify_button: Button
# Whether we have the following abilities unlocked
var hydro_cleanse: bool = true
var hydro_purify: bool = false
# Cooldown timers
var hydro_cleanse_on: bool = false
var hydro_cleanse_current_turn: int = 1
var hydro_purify_countdown: int = HYDRO_PURIFY_COOLDOWN
var hydro_cleanse_countdown: int = HYDRO_CLEANSE_COOLDOWN
var hydro_purify_on_cooldown: bool = false
var hydro_cleanse_on_cooldown: bool = false

# Turtle abilities
var earth_shield_button: Button
var earth_shield_unlocked: bool = true
var earth_shield_countdown: int = EARTH_SHIELD_COOLDOWN
var earth_shield_on_cooldown: bool = false

var earth_dust_button: Button
var earth_dust_unlocked: bool = false
var earth_dust_countdown: int = EARTH_DUST_COOLDOWN
var earth_dust_on_cooldown: bool = false
var earth_dust_on: bool = false
var earth_dust_current_turn: int = 1

# Canary attack variable
var skip_next_turn: bool = false

@onready var sprite: Sprite2D = $CatSprite
var original_modulate: Color
var flashed_once: bool = false

# Status effect icons
@onready var cleanse_icon = get_node_or_null("CatCleanseIcon")
@onready var shield_bar = get_node_or_null("CatShieldBar")
@onready var shield_display = get_node_or_null("CatShieldDisplay")
@onready var shield_cover = get_node_or_null("CatShieldCover")
@onready var dust_icon = get_node_or_null("CatDustIcon")

# Ability buttons
@onready var block_button = get_node("BlockButton")
@onready var pounce_button = get_node("PounceButton")
@onready var ult_button = get_node("UltButton")

# Shield stats 
var shield: float
var max_shield: float

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(200, 200, 500, true, 100)
	super.set_character_name("Catster") 
	
	# Notify SP change
	restore_sp(max_sp)
	
	# Notify health change
	health_changed.emit()
	
	# Shield
	max_shield = max_health
	shield = 0
	shield_changed.emit()
	
	# Add potential chosen attack
	add_chosen_attack()
	
	# Dim itself
	sprite.modulate = Color(0.5, 0.5, 0.5) 
	original_modulate = sprite.modulate
	
	# Get the chosen attack buttons
	detect_attack_buttons()
	
	# Hide icons
	if cleanse_icon != null:
		cleanse_icon.hide()
		cleanse_icon.update_tooltip()
	if dust_icon != null:
		dust_icon.hide()
		dust_icon.update_tooltip()
		
	# Register with GameManager
	GameManager.register_player(self)
	print("Catster registered!")

	
# Reset the character when resetting the game
func reset():
	# Reset basic stats
	super.assign_stats(attack, defense, max_health, is_play_character, max_sp)
	_set_blocking(false)
	restore_sp(max_sp)
	health_changed.emit()
	
	# reset shield
	shield = 0
	shield_changed.emit()
	
	# Hide icons
	if cleanse_icon != null:
		cleanse_icon.hide()
		cleanse_icon.update_tooltip()
	if dust_icon != null:
		dust_icon.hide()
		dust_icon.update_tooltip()
	
	# Reset other stats
	hydro_cleanse_on = false
	hydro_cleanse_current_turn = 1
	flashed_once = false
	earth_shield_countdown = EARTH_SHIELD_COOLDOWN
	earth_shield_on_cooldown = false
	hydro_purify_countdown = HYDRO_PURIFY_COOLDOWN
	hydro_cleanse_countdown = HYDRO_CLEANSE_COOLDOWN
	hydro_purify_on_cooldown = false
	hydro_cleanse_on_cooldown = false
	is_blocking = false
	has_acted = false
	earth_dust_countdown = EARTH_DUST_COOLDOWN
	earth_dust_on_cooldown = false
	earth_dust_on = false
	earth_dust_current_turn = 1
	skip_next_turn = false
	detect_attack_buttons()
	
	# Enable buttons
	disable_buttons(false)

# Called when it's its turn
func play_turn():
	
	# Undim when it is its turn
	sprite.modulate = Color(1, 1, 1,) 
	
	if skip_next_turn:
		await get_tree().create_timer(1.0).timeout
		GameManager.turn_log.animate("Catster lost her balance! Her turn is skipped.", 1.0)
		await get_tree().create_timer(2.0).timeout
		skip_next_turn = false
	else:
		# Default text while the player picks an action
		await get_tree().create_timer(0.5).timeout
		GameManager.turn_log.animate("Catster prepares her next move.", 0.5)
		
		has_acted = false
		# Block from the last turn wears off
		_set_blocking(false)
		# Refills SP every turn 
		restore_sp(SP_RECOVER_RATE)
		
		# Enable buttons
		disable_buttons(false)
		
		# Resolve Goldfish Water Cleanse
		if hydro_cleanse_on:
			cat_resolve_hydro_cleanse()
			
		# Resolve Turtle Dust
		if earth_dust_on:
			cat_resolve_earth_dust()
			
		# resolve companion ability countdowns
		cat_resolve_countdowns()
		
		# Update icon tooltips
		if cleanse_icon != null:
			cleanse_icon.update_tooltip()
		if dust_icon != null:
			dust_icon.update_tooltip()
				

		await action_finished
		
		# disable buttons
		disable_buttons(true)
	
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
	_play_sfx(sfx_block)
	await get_tree().create_timer(1.0).timeout
	_end_action()

# Pounce: Costs 30 SP, Base Power 100
func cat_pounce(target: Character):
	if not _begin_action(POUNCE_COST):
		return
	GameManager.turn_log.animate("Catster pounced onto the enemy.", 1.0)
	await get_tree().create_timer(1.2).timeout
	target.got_cat_pounce(self, POUNCE_POWER)
	print("Catster pounced onto enemy!")
	_play_sfx(sfx_pounce)
	await get_tree().create_timer(1.0).timeout
	_end_action()
		
# Ultimate Scratch: Costs 90 SP, Base Power 400
func cat_ult_scratch(target: Character):
	if not _begin_action(ULT_SCRATCH_COST):
		return
	GameManager.turn_log.animate("Catster unleashed her Ultimate Scratch!", 1.0)
	await get_tree().create_timer(1.2).timeout
	target.got_cat_ult_scratch(self, ULT_SCRATCH_POWER)
	print("Catster unleashed Ultimate Scratch!")
	_play_sfx(sfx_ult_scratch)
	await get_tree().create_timer(1.0).timeout
	_end_action()
	
# Hydro Cleanse: Heal hp over time
func cat_hydro_cleanse():
	if hydro_cleanse_on_cooldown:
		return
	await get_tree().create_timer(0.5).timeout
	hydro_cleanse_on = true
	super.heal(HYDRO_CLEANSE_AMOUNT)
	hydro_cleanse_current_turn = 1
	hydro_cleanse_on_cooldown = true
	print("Cat used hydro cleanse.")
	GameManager.turn_log.animate("Catster called Poseidon for Hydro Cleanse.", 1.0)
	_play_sfx(sfx_heal2)
	await get_tree().create_timer(2.0).timeout
	hydro_cleanse_button.disabled = true
	cleanse_icon.show()
	cleanse_icon.update_tooltip()
	_end_action()
	
func cat_hydro_purify():
	if hydro_purify_on_cooldown:
		return
	await get_tree().create_timer(0.5).timeout
	super.heal(HYDRO_PURIFY_AMOUNT)
	hydro_purify_on_cooldown = true
	print("Cat used hydro purify.")
	GameManager.turn_log.animate("Catster called Poseidon for Hydro Purify.", 1.0)
	_play_sfx(sfx_heal1)
	await get_tree().create_timer(2.0).timeout
	hydro_purify_button.disabled = true
	_end_action()
	
func cat_earth_shield():
	if earth_shield_on_cooldown:
		return
	await get_tree().create_timer(0.5).timeout
	print("Cat used Earth Shield.")
	GameManager.turn_log.animate("Catster called Rock for Earth Shield.", 1.0)
	shield = max_shield * EARTH_SHIELD_PERCENTAGE
	shield = clampf(shield, shield, max_shield)
	shield_changed.emit()
	shield_bar.show()
	shield_display.show()
	shield_cover.show()
	earth_shield_on_cooldown = true
	earth_shield_button.disabled = true
	await get_tree().create_timer(2.0).timeout
	_end_action()
	
func cat_earth_dust():
	if earth_dust_on_cooldown:
		return
	await get_tree().create_timer(0.5).timeout
	print("Cat used Earth Dust.")
	GameManager.turn_log.animate("Catster called Rock for Earth Dust.", 1.0)
	earth_dust_on = true
	earth_dust_current_turn = 0
	earth_dust_on_cooldown = true
	earth_dust_button.disabled = true
	GameManager.enemy.got_cat_earth_dust(self, EARTH_DUST_DAMAGE)
	dust_icon.show()
	dust_icon.update_tooltip()
	await get_tree().create_timer(2.0).timeout
	_end_action()
	
	
# Hover text for the skill buttons
func get_skill_tooltip(skill_name: String) -> String:
	match skill_name:
		"block":
			return "Cost: %d SP\nHalves the damage you take until your next turn." % BLOCK_COST
		"pounce":
			return "Cost: %d SP\nPower: %d\nA quick strike that does damage. Do triple damage to shields."% [POUNCE_COST, POUNCE_POWER]
		"ult":
			return "Cost: %d SP\nPower: %d\nA devastating scratch with big damage.\nCan also cancel multi-turn healing" % [ULT_SCRATCH_COST, ULT_SCRATCH_POWER]
		"cleanse":
			return "Cooldown: %d turns.\nHeal %d HP over %d turns.\n Nonstacking." % [HYDRO_CLEANSE_COOLDOWN, HYDRO_CLEANSE_AMOUNT, HYDRO_CLEANSE_TURN]
		"purify":
			return "Cooldown: %d turns.\nHeal %d HP." % [HYDRO_PURIFY_COOLDOWN, HYDRO_PURIFY_AMOUNT]
		"shield":
			return "Cooldown: %d turns.\nGain a %d HP Shield." % [EARTH_SHIELD_COOLDOWN, EARTH_SHIELD_PERCENTAGE * max_shield]
		"dust":
			return "Cooldown: %d turns.\nDeal %d power damage to the enemy per turn for %d turns." % [EARTH_DUST_COOLDOWN, EARTH_DUST_DAMAGE, EARTH_DUST_DURATION]
	return ""
	
# Tooltips for icons
func get_icon_tooltip(skill_name: String) -> String:
	match skill_name:
		"cat_cleanse":
			return "Hydro Cleanse: Heal %d per turn for another %d turn(s)." % [HYDRO_CLEANSE_AMOUNT, hydro_cleanse_countdown]
		"cat_dust":
			return "Earth Dust: Take %d power damage per turn for another %d turn(s)." % [EARTH_DUST_DAMAGE, EARTH_DUST_DURATION - earth_dust_current_turn]
	return "TOOLTIP NOT FOUND"
	
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
	
# resolve the companion skill cooldowns 
func cat_resolve_countdowns():
	if hydro_cleanse and hydro_cleanse_on_cooldown:
		hydro_cleanse_countdown -= 1
		if hydro_cleanse_countdown < 1:
			hydro_cleanse_on_cooldown = false
			hydro_cleanse_countdown = HYDRO_CLEANSE_COOLDOWN
			hydro_cleanse_button.disabled = false
			cleanse_icon.hide()
	
	if hydro_purify and hydro_purify_on_cooldown:
		hydro_purify_countdown -= 1
		if hydro_purify_countdown < 1:
			hydro_purify_on_cooldown = false
			hydro_purify_countdown = HYDRO_PURIFY_COOLDOWN
			hydro_purify_button.disabled = false
			
	if earth_shield_unlocked and earth_shield_on_cooldown:
		earth_shield_countdown -= 1
		if earth_shield_countdown < 1:
			earth_shield_on_cooldown = false
			earth_shield_countdown = EARTH_SHIELD_COOLDOWN
			earth_shield_button.disabled = false
			
	if earth_dust_unlocked and earth_dust_on_cooldown:
		earth_dust_countdown -= 1
		if earth_dust_countdown < 1:
			earth_dust_on_cooldown = false
			earth_dust_countdown = EARTH_DUST_COOLDOWN
			earth_dust_button.disabled = false
			

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
		
func cat_resolve_earth_dust():
	earth_dust_current_turn += 1
	if earth_dust_current_turn >= EARTH_DUST_DURATION:
		earth_dust_on = false
		dust_icon.hide()
	print("Cat continue Dust.")
	GameManager.enemy.got_cat_earth_dust_tick(self, EARTH_DUST_TICK_DAMAGE)
		
# Canary list
func got_canary_bubble_bomb(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
	if !flashed_once:
		got_hit_effect()
		flashed_once = true
func got_canary_lux_arrow(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
	got_hit_effect()
func got_canary_whirlwind(attacker: Character):
	skip_next_turn = true

# Shared damage handling for every enemy attack
func _receive_hit(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	if is_blocking:
		damage *= BLOCK_DAMAGE_MULT
	var health_damage = damage	
	
	# When there is a shield
	if shield > 0:
		# When shield is greater or equal to than the ability damage,
		# Subtract the ability damage from the shield 
		# Make health_damage 0
		if shield >= damage:
			shield = shield - damage
			health_damage = 0
		
		# When the shield is smaller than the ability damage (shield break)
		# Subtract the remaining shield from the ability damage to get health damage
		else:
			health_damage = damage - shield
			shield = 0
			shield_cover.hide()
		shield_changed.emit()

	if health_damage:
		print("Cat takes %f damages." % health_damage)
		take_damage(health_damage)


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
	# Shake
	super.shake_sprite(sprite)
	
	# Flash
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
	disable_buttons(false)
	
# Read and add chosen attack
func add_chosen_attack():
	var attack_to_add_1 = GameManager.chosen_attack
	var attack_to_add_2 = GameManager.chosen_attack2
	if !attack_to_add_1.is_empty():
		print("Adding attack %s." % attack_to_add_1)
		if attack_to_add_1 == "hydro_cleanse":
			hydro_cleanse = true
		elif attack_to_add_1 == "hydro_purify":
			hydro_purify = true
	if !attack_to_add_2.is_empty():
		print("Adding attack %s." % attack_to_add_2)
		if attack_to_add_2 == "earth_shield":
			earth_shield_unlocked = true
		elif attack_to_add_2 == "earth_dust":
			earth_dust_unlocked = true

# Display ability texts
func detect_attack_buttons():
	hydro_cleanse_button = get_node_or_null("CleanseButton")
	if hydro_cleanse_button != null:
		if hydro_cleanse:
			hydro_cleanse_button.show()
		else:
			hydro_cleanse_button.hide()
		
	hydro_purify_button = get_node_or_null("PurifyButton")
	if hydro_cleanse_button != null:
		if hydro_purify:
			hydro_purify_button.show()
		else:
			hydro_purify_button.hide()
			
	earth_shield_button = get_node_or_null("ShieldButton")
	if earth_shield_button != null:
		if earth_shield_unlocked:
			earth_shield_button.show()
		else:
			earth_shield_button.hide()
		shield_bar.hide()
		shield_display.hide()
		shield_cover.hide()
		earth_shield_button.update_tooltip()
		
	earth_dust_button = get_node_or_null("DustButton")
	if earth_dust_button != null:
		if earth_dust_unlocked:
			earth_dust_button.show()
		else:
			earth_dust_button.hide()		
		earth_dust_button.update_tooltip()
			
# Disable buttons, for turn transition and sp cost
func disable_buttons(disable_button: bool):
	if disable_button == false:
		if sp >= BLOCK_COST:
			block_button.disabled = false
		if sp >= POUNCE_COST:
			pounce_button.disabled = false
		if sp >= ULT_SCRATCH_COST:
			ult_button.disabled = false
	else:
		block_button.disabled = true
		pounce_button.disabled = true
		ult_button.disabled = true
	
	if hydro_cleanse_button != null:
		if hydro_cleanse_on_cooldown == false:
			hydro_cleanse_button.disabled = disable_button
	
	if hydro_purify_button != null:
		if hydro_purify_on_cooldown == false:
			hydro_purify_button.disabled = disable_button
	
	if earth_shield_button != null:
		if earth_shield_on_cooldown == false:
			earth_shield_button.disabled == disable_button
			
	if earth_dust_button != null:
		if earth_dust_on_cooldown == false:
			earth_dust_button.disabled == disable_button		
