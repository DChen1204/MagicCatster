extends Character

# This is the script for the Turtle Enemy of the game.
# It has the earth element magic and focuses on shield. 

"""
Stats of the Turtle
Base Attack = 150
Base Defense = 25
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

const EMERALD_SPLASH_EMERALD_DAMAGE_LOW: float = 10 	# Lowest damage for one emerald
const EMERALD_SPLASH_EMERALD_DAMAGE_HIGH: float = 20	# Highest damage for one emerald
const EMERALD_SPLASH_EMERALD_COUNT: int = 4				# The number of emeralds shot in one emerald splash

const STUNT_TURN: int = 3	# The number of turns the turtle is stunt after shield down
var stunt_counter: int = 1
var stunted: bool = false

#SFX for attacks
@onready var sfx_basicAttack2 = $sfx_basicAttack2

# Sprite variables
@onready var sprite: Sprite2D = $TurtleSprite
var original_modulate: Color

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
	stunt_counter = 1
	stunted = false
	player_dusted = false
	player_dusted_duration = 0
	crazy_diamond_used = false
	crazy_diamond_current_turn = 0
	
	# reset turn log
	# GameManager.turn_log.text = ""
	

# Play its turn
func play_turn():
	# Undim when it is its turn
	sprite.modulate = Color(1, 1, 1) 
	# Pause for some time to pretend thinking
	GameManager.turn_log.animate("Rock is preparing to attack...", 1.0)
	await get_tree().create_timer(1.5).timeout
	decide_action()
	# Dim itself after its turn
	await get_tree().create_timer(1.0).timeout
	sprite.modulate = Color(0.5, 0.5, 0.5)  
	
	
# Enemy AI deciding what to do in its turn
# For Turtle, 
func decide_action():
	
	# Stunt after shield break
	if stunted:
		turtle_stunted()
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

	
# Skill "Crazy Diamond'
# Activated once under w% HP; may only be used once throughout the entire fight.
# Turtle retreat to its shell and gain max shield. Then enters defense mode.
# Removes 'Dusted'.
# In defense mode, turtle repairs x% of shield every y turn. 
# Defense mode is removed once the shield is completely broken. 
# And the turtle is stunt (can not take action) for the next z turns.
func turtle_crazy_diamond():
	print("Turtle used Crazy Diamond.")
	GameManager.turn_log.animate("Rock used Crazy Diamond! Now it has an earth shield.", 1.5)
	shield = max_shield
	shield_changed.emit()
	player_dusted = false
	crazy_diamond_used = true
	
	
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
	if crazy_diamond_current_turn == CRAZY_DIAMOND_SHIELD_TURN:
		print("Turtled repaired shield.")
		GameManager.turn_log.animate("Rock repaired its earth shield!", 1.0)
		shield += max_shield * CRAZY_DIAMOND_SHEILD_REPAIR
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
	print("Turtle used tick.")
	GameManager.player.got_turtle_tick_damage(self, BITE_DUST_TICK_DAMAGE)
	
# Stunt after shield break
func turtle_stunted():
	if stunt_counter < STUNT_TURN:
		print("Turtled stunted.")
		GameManager.turn_log.animate("Rock is still stunted from the shield break.", 1.0)
		stunt_counter += 1
	else:
		print("Turtled recovered.")
		GameManager.turn_log.animate("Rock is recovering from the stunt.", 1.0)
		stunted = false
	
# Got hit special affect
func got_hit_effect():
	for i in 2:
		sprite.modulate = Color(3, 3, 3)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate
		await get_tree().create_timer(0.1).timeout

# List of affected skills		
func got_cat_pounce(attacker: Character, dmg_percentage: float):
	var ability_damage = (attacker.attack / self.defense) * dmg_percentage
	var shield_damage = (attacker.attack / self.defense) * dmg_percentage
	var total_damage = ability_damage + shield_damage
	var health_damage = total_damage
	# When there is a shield
	if shield > 0:
		# When shield is greater than the total damage,
		# Subtract the total damage from the shield 
		# Make health_damage 0
		if shield >= total_damage:
			shield = shield - total_damage
			health_damage = 0
		else:
			if shield >= shield_damage:
				
			
			
			shield_damage = shield_damage - shield
			#total_damage = shield_damage / 2
			total_damage = shield_damage
			shield = 0
			stunted = true
		shield_changed.emit()
	

	# Calculate health loss
	if health_damage > 0:
		print("Turtle takes %f health damage." % health_damage)
		super.take_damage(health_damage)
		got_hit_effect()
		
		
func got_cat_ult_scratch(attacker: Character, dmg_percentage: float):
	var total_damage = (attacker.attack / self.defense) * dmg_percentage
	var shield_damage = (attacker.attack / self.defense) * dmg_percentage
	if shield > 0:
		if shield >= shield_damage:
			shield = shield - shield_damage
			total_damage = 0
		else:
			shield_damage = shield_damage - shield
			#total_damage = shield_damage / 2
			total_damage = shield_damage
			shield = 0
			stunted = true
		shield_changed.emit()
		
	# Calculate health loss
	if total_damage > 0:
		print("Turtle takes %f damage." % total_damage)
		super.take_damage(total_damage)
		got_hit_effect()
		

	
