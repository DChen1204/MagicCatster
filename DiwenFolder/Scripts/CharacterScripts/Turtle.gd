extends Character

# This is the script for the Turtle Enemy of the game.
# It has the earth element magic and focuses on shield. 

"""
Stats of the Turtle
Base Attack = 150
Base Defense = 500
Base Health = 500
Play Character = false
SP = 0
Character Name = Rock
"""

# Constants 
const BITE_DUST_DAMAGE: float = 20.0		# Initial damage of Bite Dust
const BITE_DUST_TICK_DAMAGE: float = 20.0 	# Tick damage of Bite Dust per turn
const BITE_DUST_DURATION: int = 5			# Number of turns Bite Dust ticks

const CRAZY_DIAMOND_SHEILD_REPAIR: float = 0.10		# The percentage of every shield repair
const CRAZY_DIAMOND_SHIELD_TURN: int = 4			# Number of turns before shield repair

const EMERALD_SPLASH_EMERALD_DAMAGE_LOW: float = 15 	# Lowest damage for one emerald
const EMERALD_SPLASH_EMERALD_DAMAGE_HIGH: float = 25	# Highest damage for one emerald
const EMERALD_SPLASH_EMERALD_COUNT: int = 4				# The number of emeralds shot in one emerald splash

const STUN_TURN: int = 3	# The number of turns the turtle is stunt after shield down
var stun_counter: int = 1
var stunned: bool = false

#SFX for attacks
@onready var sfx_basicAttack2 = $sfx_basicAttack2

# Sprite variables
@onready var sprite: Sprite2D = $TurtleSprite
var original_modulate: Color

# UI elements
@onready var crazy_diamond_icon = get_node("TurtleCrazyDiamondIcon")
@onready var stun_icon = get_node("TurtleStunIcon")
@onready var dust_icon = get_node("TurtleDustIcon")
@onready var shield_cover = get_node("TurtleShieldCover")
var shield_modulate: Color
@onready var shield_bar = get_node("TurtleShieldBar")
@onready var shield_display = get_node("TurtleShieldDisplay")

# Shield stats 
var shield: float
var max_shield: float

# Bite Dust Variables
var player_dusted: bool = false
var player_dusted_duration: int = 0

# Crazy Diamond Variables
var crazy_diamond_used: bool = false
var crazy_diamond_current_turn: int = 0

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(150, 500, 500, false)
	super.set_character_name("Rock")

	health_changed.emit()
	
	# The shield is based on max health
	# No shield at the beginning 
	max_shield = max_health
	shield = 0
	shield_changed.emit()
	
	# Dim itself
	sprite.modulate = Color(0.5, 0.5, 0.5) 
	original_modulate = sprite.modulate
	shield_modulate = shield_cover.modulate
	
	# Hide icons and UI
	crazy_diamond_icon.update_tooltip()
	crazy_diamond_icon.hide()
	stun_icon.update_tooltip()
	stun_icon.hide()
	dust_icon.update_tooltip()
	dust_icon.hide()
	shield_cover.hide()
	shield_bar.hide()
	shield_display.hide()
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Rock registered!")
	
	
# Reset itself when called
func reset():
	# reset basic stats 
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	
	# reset shield
	shield = 0
	shield_changed.emit()
	
	# reset other stats
	stun_counter = 1
	stunned = false
	player_dusted = false
	player_dusted_duration = 0
	crazy_diamond_used = false
	crazy_diamond_current_turn = 0
	

# Play its turn
func play_turn():
	# Undim when it is its turn
	sprite.modulate = Color(1, 1, 1) 
	
	# Pause for some time to pretend thinking
	GameManager.turn_log.animate("Rock is preparing to attack...", 1.0)
	await get_tree().create_timer(1.5).timeout
	decide_action()
	
	# update icon tooltips
	# crazy_diamond_icon.update_tooltip()
	stun_icon.update_tooltip()
	dust_icon.update_tooltip()
	
	# Dim itself after its turn
	await get_tree().create_timer(3.2).timeout
	sprite.modulate = Color(0.5, 0.5, 0.5)  
	
	
# Enemy AI deciding what to do in its turn
func decide_action():
	
	# Stunned after shield break
	if stunned:
		turtle_stunned()
		return
	
	# Use Crazy Diamond when half hp
	if health <= max_health / 2 and !crazy_diamond_used:
		turtle_crazy_diamond()
		return
	
	# Resolve the shield unqiue phase
	if shield > 0:
		turtle_has_shield()
		return
		
	# If play is dusted, resolve tick damage and do emerald sp'ash
	# Else just do emerald splash
	if player_dusted:
		turtle_resolve_tick_damage()
		turtle_emerald_splash()
	else:
		turtle_bite_dust()

# List of Skills
# Skill 'Bite Dust'
# Turtle deals a small damage and inflict a tick damage debuff 'Dusted' to the player. 
# Dusted: Take BITE_DUST_TICK_DAMAGE damage per turn for BITE_DUST_DURATION turns
func turtle_bite_dust():
	print("Turtle used Bite Dust.")
	GameManager.turn_log.animate("Rock used Bite Dust! Some dust got into Catster's eyes!", 1.5)
	player_dusted = true
	player_dusted_duration = 0
	sfx_basicAttack2.play()
	GameManager.player.got_turtle_bite_dust(self, BITE_DUST_DAMAGE)
	dust_icon.show()
	dust_icon.update_tooltip()

	
# Skill "Crazy Diamond'
# Activated once under w% HP; may only be used once throughout the entire fight.
# Turtle retreat to its shell and gain max shield. Then enters defense mode.
# Removes 'Dusted'.
# In defense mode, turtle repairs x% of shield every y turn. 
# Defense mode is removed once the shield is completely broken. 
# And the turtle is stunt (can not take action) for the next z turns.
func turtle_crazy_diamond():
	print("Turtle used Crazy Diamond.")
	GameManager.turn_log.animate("Rock used Crazy Diamond! It has retreated to its shell.", 1.5)
	shield = max_shield
	shield_changed.emit()
	player_dusted = false
	dust_icon.hide()
	crazy_diamond_used = true
	crazy_diamond_icon.show()
	shield_cover.show()
	shield_bar.show()
	shield_display.show()
	
	
# Skill 'Emerald Splash'
# Deals a total of 100% damage across multiple emeralds 
func turtle_emerald_splash():
	print("Turtle used Emerald Splash.")
	GameManager.turn_log.animate("Rock used Emerald Splash! It splashed Catster with shiny emeralds.", 1.5)
	for i in range(EMERALD_SPLASH_EMERALD_COUNT):
		await get_tree().create_timer(0.3).timeout
		sfx_basicAttack2.play()	
		var this_emerald_damage = randf_range(EMERALD_SPLASH_EMERALD_DAMAGE_LOW, EMERALD_SPLASH_EMERALD_DAMAGE_HIGH)
		GameManager.player.got_turtle_emerald_splash(self, this_emerald_damage)
	GameManager.player.flashed_once = false
	
# Decide action when turtle has shield
func turtle_has_shield():
	if crazy_diamond_current_turn >= CRAZY_DIAMOND_SHIELD_TURN and shield < max_shield:
		print("Turtled repaired shield.")
		GameManager.turn_log.animate("Rock repaired its earth shield!", 1.0)
		shield += max_shield * CRAZY_DIAMOND_SHEILD_REPAIR
		shield = clampf(shield, shield, max_shield)
		shield_changed.emit()
		crazy_diamond_current_turn = 0
	else:
		crazy_diamond_current_turn += 1
		turtle_emerald_splash()
		
# Resolve Tick damage
func turtle_resolve_tick_damage():
	player_dusted_duration += 1
	if player_dusted_duration >= BITE_DUST_DURATION:
		player_dusted = false
		dust_icon.hide()
	print("Turtle used tick.")
	GameManager.player.got_turtle_tick_damage(self, BITE_DUST_TICK_DAMAGE)
	
# Stun after shield break
func turtle_stunned():
	if stun_counter < STUN_TURN:
		print("Turtled stunned.")
		GameManager.turn_log.animate("Rock is still stunned from the shield break.", 1.0)
		stun_counter += 1
	else:
		print("Turtled recovered.")
		GameManager.turn_log.animate("Rock is recovering from the stun.", 1.0)
		stunned = false
		stun_icon.hide()
		
# Shield flash effect
func shield_flash():
	# Flashes
	for i in 2:
		shield_cover.modulate = Color(3, 3, 3)
		await get_tree().create_timer(0.1).timeout
		shield_cover.modulate = shield_modulate
		await get_tree().create_timer(0.1).timeout
	
# Got hit special affect
func got_hit_effect():
	# Shakes
	super.shake_sprite(sprite)
	
	# Flashes
	for i in 2:
		sprite.modulate = Color(3, 3, 3)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate
		await get_tree().create_timer(0.1).timeout
		
# Tooltips for icons
func get_icon_tooltip(skill_name: String) -> String:
	match skill_name:
		"turtle_crazy_diamond":
			return "Crazy Diamond: Repair %d shield every %d turns." % [max_shield * CRAZY_DIAMOND_SHEILD_REPAIR, CRAZY_DIAMOND_SHIELD_TURN]
		"turtle_stun":
			return "Stun: Cannot take action for another %d turn(s)." % [STUN_TURN - stun_counter + 1]
		"turtle_dust":
			return "Dusted: Take %d power damage per turn for another %d turn(s)." % [BITE_DUST_DAMAGE, BITE_DUST_DURATION - player_dusted_duration]
	return "TOOLTIP NOT FOUND"

# List of affected skills		
func got_cat_pounce(attacker: Character, dmg_percentage: float):
	# Different damage types to resolve shields
	var ability_damage = (attacker.attack / self.defense) * dmg_percentage
	var shield_damage = (attacker.attack / self.defense) * dmg_percentage * 2
	var combined_damage = ability_damage + shield_damage
	var health_damage = ability_damage
	
	# When there is a shield
	if shield > 0:
		# When shield is greater or equal to than the combined damage,
		# Subtract the combined damage from the shield 
		# Make health_damage 0
		if shield >= combined_damage:
			shield = shield - combined_damage
			health_damage = 0
			shield_flash()
		
		# When the shield is smaller than the combined damage (shield break)
		# Subtract the shield damage from the shield (clamped)
		# Subtract the remaining shield from the ability damage to get health damage
		else:
			shield = shield - shield_damage
			shield = clampf(shield, 0, shield)
			health_damage = ability_damage - shield
			shield = 0
			stunned = true
			crazy_diamond_icon.hide()
			stun_icon.show()
			shield_cover.hide()
		shield_changed.emit()

	# Calculate health loss
	if health_damage > 0:
		print("Turtle takes %f health damage." % health_damage)
		super.take_damage(health_damage)
		got_hit_effect()
		
		
func got_cat_ult_scratch(attacker: Character, dmg_percentage: float):
	# Different damage types to resolve shields
	var ability_damage = (attacker.attack / self.defense) * dmg_percentage
	var health_damage = ability_damage
	
	# When there is a shield
	if shield > 0:
		# When shield is greater or equal to than the ability damage,
		# Subtract the ability damage from the shield 
		# Make health_damage 0
		if shield >= ability_damage:
			shield = shield - ability_damage
			health_damage = 0
			shield_flash()
		
		# When the shield is smaller than the ability damage (shield break)
		# Subtract the remaining shield from the ability damage to get health damage
		else:
			health_damage = ability_damage - shield
			shield = 0
			stunned = true
			crazy_diamond_icon.hide()
			stun_icon.show()
			shield_cover.hide()
		shield_changed.emit()

	# Calculate health loss
	if health_damage > 0:
		print("Turtle takes %f health damage." % health_damage)
		super.take_damage(health_damage)
		got_hit_effect()
		

	
