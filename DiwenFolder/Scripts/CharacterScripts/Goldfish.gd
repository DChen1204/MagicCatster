extends Character

# This is the script for the Goldfish Enemy of the game.
# It should be relatively weak as a early game boss. 

"""
Stats of the Goldfish
Base Attack = 200
Base Defense = 200
Base Health = 800
Play Character = false
SP = 0
Character Name = Poseidon
"""

# Tuning. Heal amounts are a percentage of max health
const BUBBLE_POWER: float = 70.0

const GIFT_HEAL_PERCENT: float = 0.25	# Gift of the Seas: instant heal
const GIFT_COOLDOWN: int = 5		# usable once every 5 turns
const GIFT_THRESHOLD: float = 0.5	# only at or below 50% health

const TIDE_HEAL_PERCENT: float = 0.05	# Healing Tide: heal per turn
const TIDE_DURATION: int = 3		# for 3 turns
const TIDE_COOLDOWN: int = 6		# usable once every 6 turns
const TIDE_THRESHOLD: float = 0.8	# only at or below 80% health

# Heal state
var gift_cooldown: int = 0
var tide_cooldown: int = 0
var tide_turns_left: int = 0


#SFX for attacks
@onready var sfx_basicAttack1 = get_node_or_null("sfx_basicAttack1")
@onready var sfx_heal1 = get_node_or_null("sfx_heal1")
@onready var sfx_heal2 = get_node_or_null("sfx_heal2")

# Sprite variables
@onready var sprite: Sprite2D = $GoldfishSprite
var original_modulate: Color


# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(200, 200, 800, false)
	super.set_character_name("Poseidon")
	# used_heal = false
	
	health_changed.emit()
	
	# Dim itself until its turn
	sprite.modulate = Color(0.5, 0.5, 0.5)
	original_modulate = sprite.modulate
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Poseidon registered!")
	
	
# Reset itself when called
func reset():
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	gift_cooldown = 0
	tide_cooldown = 0
	tide_turns_left = 0
	GameManager.turn_log.text = ""

# Play its turn
func play_turn():
	# Undim when it is its turn
	sprite.modulate = Color(1, 1, 1)
	
		# Cooldowns tick down at the start of every turn
	gift_cooldown = maxi(0, gift_cooldown - 1)
	tide_cooldown = maxi(0, tide_cooldown - 1)
	
	# Healing Tide restores health at the start of its turn
	if tide_turns_left > 0:
		tide_turns_left -= 1
		super.heal(max_health * TIDE_HEAL_PERCENT)
		GameManager.turn_log.animate("The Healing Tide mends Poseidon's wounds...", 1.0)
	else:
		GameManager.turn_log.animate("Poseidon is summoning water...", 1.0)
		await get_tree().create_timer(1.5).timeout
		
	
	# Do action
	decide_action()
	# Give the player time to read what happened, then dim itself
	await get_tree().create_timer(2.5).timeout
	sprite.modulate = Color(0.5, 0.5, 0.5)
	
# Enemy AI deciding what to do in its turn
# For Goldfish, heal when under half hp
func decide_action():
	if gift_cooldown == 0 and health <= max_health * GIFT_THRESHOLD:
		goldfish_water_heal()
	elif tide_cooldown == 0 and tide_turns_left == 0 and health <= max_health * TIDE_THRESHOLD:
		goldfish_healing_tide()
	else:
		goldfish_bubble_attack()
		
# List of Skills
func goldfish_bubble_attack():
	print("Goldfish attacked with bubbles")
	GameManager.player.got_goldfish_bubble_attack(self, BUBBLE_POWER)
	# sfx_basicAttack1.play()
	GameManager.turn_log.animate("Poseidon spewed bubbles on Catster's face!", 1.5)
	_play_sfx(sfx_basicAttack1)
	await get_tree().create_timer(1.5).timeout
	
func goldfish_water_heal():
	print("Goldfish used Gift of the Seas (HEALS).")
	super.heal(max_health * GIFT_HEAL_PERCENT)
	gift_cooldown = GIFT_COOLDOWN
	GameManager.turn_log.animate("Poseidon used Gift of the Seas on itself!", 1.5)
	_play_sfx(sfx_heal1)
	await get_tree().create_timer(1.5).timeout

# Healing Tide: a little healing every turn for a few turns
func goldfish_healing_tide():
	print("Goldfish used Healing Tide.(HEALS)")
	tide_turns_left = TIDE_DURATION
	tide_cooldown = TIDE_COOLDOWN
	GameManager.turn_log.animate("Poseidon called the Healing Tide! Its wounds begin to close.", 1.5)
	_play_sfx(sfx_heal2)
	await get_tree().create_timer(1.5).timeout

# Play a sound if that node exists
func _play_sfx(sfx):
	if sfx != null:
		sfx.play()
		

# Got hit "animation"
func got_hit_effect():
	for i in 2:
		sprite.modulate = Color(3, 3, 3)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate
		await get_tree().create_timer(0.1).timeout		
		
# List of affected skills
func got_cat_pounce(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	if damage > 0:
		print("Goldfish takes %f damage." % damage)
		super.take_damage(damage)
		got_hit_effect()

func got_cat_ult_scratch(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	if damage > 0:
		print("Goldfish takes %f damage." % damage)
		super.take_damage(damage)
		got_hit_effect()
	if tide_turns_left > 0:
		tide_turns_left = 0
		print("Healing Tide cancelled.")
		GameManager.turn_log.animate("Catster's Ultimate Scratch tore through the Healing Tide!", 1.5)
