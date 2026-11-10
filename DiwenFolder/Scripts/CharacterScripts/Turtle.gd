extends Character

# This is the script for the Turtle Enemy of the game.
# It has the earth element magic and focuses on shield. 

"""
Stats of the Turtle
Base Attack = 150
Base Defense = 25
Base Health = 400
Play Character = false
SP = 0
Character Name = Rock
"""

# Constants 
const BITE_DUST_DAMAGE: float = 20.0		# Initial damage of Bite Dust
const BITE_DUST_TICK_DAMAGE: float = 20.0 	# Tick damage of Bite Dust per turn
const BITE_DUST_DURATION: int = 5			# Number of turns Bite Dust ticks

const CRAZY_DIAMOND_SHEILD_REPAIR: float = 0.25		# The percentage of every shield repair
const CRAZY_DIAMOND_SHIELD_TURN: int = 3			# Number of turns before shield repair

const EMERALD_SPLASH_EMERALD_DAMAGE: float = 25
const EMERALD_SPLASH_EMERALD_COUNT: int = 4

#SFX for attacks
@onready var sfx_basicAttack2 = $sfx_basicAttack2

# The dialogue box of this character.
@onready var dialogue_box: RichTextLabel = $"TurtleDialogueBox"

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
	
	dialogue_box.text = "Baby don't hurt me!"
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Rock registered!")
	
# Reset itself when called
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	shield = 0
	shield_changed.emit()
	dialogue_box.text = "Baby don't hurt me!"
	

# Play its turn
func play_turn():
	# Pause for some time to pretend thinking
	dialogue_box.text = "Rock is preparing to attack..."
	await get_tree().create_timer(1.5).timeout
	decide_action()
	
# Enemy AI deciding what to do in its turn
# For Turtle, 
func decide_action():
	
	# Use Crazy Diamond when half hp
	if health <= max_health / 2 and !crazy_diamond_used:
		turtle_crazy_diamond()
		return
	
	# Shielded actions
	if shield > 0:
		if crazy_diamond_current_turn == CRAZY_DIAMOND_SHIELD_TURN:
			dialogue_box.text = "Rock repairs its shield!"
			shield += max_shield * CRAZY_DIAMOND_SHEILD_REPAIR
			crazy_diamond_current_turn = 0
		else:
			crazy_diamond_current_turn += 1
			turtle_emerald_splash()
		return
		
	# If play is dusted, resolve tick damage and do emerald spash
	if player_dusted:
		# Resolve tick damage 
		print("Turtle uses tick.")
		GameManager.player.got_turtle_tick_damage(self, BITE_DUST_TICK_DAMAGE)
		player_dusted_duration += 1
		if player_dusted_duration >= BITE_DUST_DURATION:
			player_dusted = false
		# Do Emerald Splash
		turtle_emerald_splash()
	else:
		turtle_bite_dust()

# List of Skills

# Skill 'Bite Dust'
# Turtle deals a small damage and inflict a tick damage debuff 'Dusted' to the player. 
# Dusted: Take BITE_DUST_TICK_DAMAGE damage per turn for BITE_DUST_DURATION turns
func turtle_bite_dust():
	print("Turtle uses Bite Dust.")
	dialogue_box.text = "Rock uses Bite Dust! Some dust got into Catster's eyes."
	GameManager.player.got_turtle_bite_dust(self, BITE_DUST_DAMAGE)
	player_dusted = true
	player_dusted_duration = 0
	sfx_basicAttack2.play()
	
# Skill "Crazy Diamond'
# Activated once under w% HP; may only be used once throughout the entire fight.
# Turtle retreat to its shell and gain max shield. Then enters defense mode.
# Removes 'Dusted'.
# In defense mode, turtle repairs x% of shield every y turn. 
# Defense mode is removed once the shield is completely broken. 
# And the turtle is stunt (can not take action) for the next z turns.
func turtle_crazy_diamond():
	print("Turtle uses Crazy Diamond.")
	dialogue_box.text = "Rock uses Crazy Diamond! Now it is shielded."
	shield = max_shield
	shield_changed.emit()
	player_dusted = false
	crazy_diamond_used = true
	

# Skill 'Emerald Splash'
# Deals a total of 100% damage across multiple emeralds 
func turtle_emerald_splash():
	print("Turtle uses Emerald Splash.")
	dialogue_box.text = "Rock uses Emerald Splash! It shoots Catster with emeralds."
	for i in range(EMERALD_SPLASH_EMERALD_COUNT):
		await get_tree().create_timer(0.3).timeout
		GameManager.player.got_turtle_emerald_splash(self, EMERALD_SPLASH_EMERALD_DAMAGE)
	sfx_basicAttack2.play()	
	
	
# List of affected skills
		
# Corrodes shield
func got_cat_pounce(attacker: Character, dmg_percentage: float):
	var total_damage = (attacker.attack / self.defense) * dmg_percentage
	var shield_damage = (attacker.attack / self.defense) * dmg_percentage
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
		print("Turtle takes %f damage." % total_damage)
		super.take_damage(total_damage)
		

func got_cat_ult_scratch(attacker: Character, dmg_percentage: float):
	var total_damage = (attacker.attack / self.defense) * dmg_percentage
	var shield_damage = (attacker.attack / self.defense) * dmg_percentage
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
		print("Turtle takes %f damage." % total_damage)
		super.take_damage(total_damage)
		
	
