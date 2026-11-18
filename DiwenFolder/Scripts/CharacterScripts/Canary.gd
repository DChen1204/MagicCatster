extends Character

# This is the script for the Canary Enemy of the game.
# It has the air element magic and focuses on attacking. 

"""
Stats of the Canary
Base Attack = 300
Base Defense = 300
Base Health = 1000
Play Character = false
SP = 0
Character Name = Songbird
"""

# Constants
const BUBBLE_BOMB_DAMAGE_COUNTS: int = 3
const BUBBLE_BOMB_DAMAGE_LOW: float = 30
const BUBBLE_BOMB_DAMAGE_HIGH: float = 50

const LUX_ARROW_DAMAGE: float = 400
const LUX_ARROW_COOLDOWN: int = 4
var lux_arrow_countdown: int = 3
var lux_arrow_on_cooldown: bool = true

const SWAY_BEAT_ATTACK_INCREASE: float = 20
const SWAY_BEAT_COOLDOWN: int = 3
var sway_beat_countdown: int = 1
var sway_beat_on_cooldown: bool = true
var sway_beat_total_attack_increased: float = 0

const WHIRLWIND_COOLDOWN: int = 4
var whirlwind_countdown: int = 4
var whirlwind_on_cooldown: bool = true
# var whirlwind_allowed: bool = false

# Sprite variables
@onready var sprite: Sprite2D = $CanarySprite
var original_modulate: Color

# UI elements
@onready var sway_beat_icon = get_node("CanarySwayBeatIcon")
@onready var lux_arrow_cover = get_node("CanaryArrowCover")

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(300, 300, 1000, false)
	super.set_character_name("Songbird")
	
	health_changed.emit()
	
	# Dim itself
	sprite.modulate = Color(0.5, 0.5, 0.5) 
	original_modulate = sprite.modulate
	
	# Hide icons and UI
	sway_beat_icon.update_tooltip()
	sway_beat_icon.hide()
	lux_arrow_cover.hide()
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Songbird registered!")
	
	
# Reset itself when called
func reset():
	# reset basic stats 
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	
	# reset other variables
	lux_arrow_countdown = 3
	lux_arrow_on_cooldown = true
	sway_beat_countdown = 1
	sway_beat_on_cooldown = true
	sway_beat_total_attack_increased = 0
	whirlwind_countdown = 4
	whirlwind_on_cooldown = true
	# whirlwind_allowed = false
	attack = 300
	
	# Hide icons
	sway_beat_icon.update_tooltip()
	sway_beat_icon.hide()
	lux_arrow_cover.hide()
	
# Play its turn
func play_turn():
	# Undim when it is its turn
	sprite.modulate = Color(1, 1, 1) 
	
	# Pause for some time to pretend thinking
	GameManager.turn_log.animate("Songbird is preparing to attack...", 1.0)
	await get_tree().create_timer(1.5).timeout
	decide_action()
	
	# Update Icon tooltip
	# sway_beat_icon.update_tooltip()
	
	# Dim itself after its turn
	await get_tree().create_timer(3.2).timeout
	sprite.modulate = Color(0.5, 0.5, 0.5)  
	
	
# Songbird AI deciding what to do in its turn
func decide_action():
	
	# Shoot lux arrow if possble
	if lux_arrow_on_cooldown == false:
		canary_lux_arrow()
		
	# use whirlwin if possible (not the turn before lux arrow)
	elif whirlwind_on_cooldown == false:
		canary_whirlwind()
	
	# Sway beat if possible
	elif sway_beat_on_cooldown == false:
		canary_sway_beat()
	
	# Use Bubble bomb if possible
	else:
		resolve_sway_beat_countdown()
		resolve_whirlwind_countdown()
		if resolve_lux_arrow_countdown():
			canary_bubble_bomb()
	
# Basic attack
# Deal a few medium damages 
func canary_bubble_bomb():
	print("Canary used Bubble Bomb.")
	GameManager.turn_log.animate("Songbird used Bubble Bomb! Some air bombs exploded near Catster.", 1.5)
	for i in range(BUBBLE_BOMB_DAMAGE_COUNTS):
		await get_tree().create_timer(0.3).timeout
		var this_bubble_bomb_damage = randf_range(BUBBLE_BOMB_DAMAGE_LOW, BUBBLE_BOMB_DAMAGE_HIGH)
		GameManager.player.got_canary_bubble_bomb(self, this_bubble_bomb_damage)
	GameManager.player.flashed_once = false
	
# Ultimate attack
# Deal a very high damage
func canary_lux_arrow():
	print("Canary used Lux Arrow.")
	GameManager.turn_log.animate("Sonbird shot a devastating Sky-Shattering Lux Arrow!", 1.5)
	GameManager.player.got_canary_lux_arrow(self, LUX_ARROW_DAMAGE)
	lux_arrow_countdown = LUX_ARROW_COOLDOWN
	lux_arrow_on_cooldown = true
	lux_arrow_cover.hide()
	# whirlwind_allowed = true

# Attack Increase Move
func canary_sway_beat():
	print("Canary used Sway Beat.")
	GameManager.turn_log.animate("Songbird used Sway to My Beat! Her attack is increased permanently.", 1.5)
	attack += SWAY_BEAT_ATTACK_INCREASE
	sway_beat_total_attack_increased += SWAY_BEAT_ATTACK_INCREASE
	sway_beat_countdown = SWAY_BEAT_COOLDOWN
	sway_beat_on_cooldown = true
	sway_beat_icon.show()
	sway_beat_icon.update_tooltip()
	
# Skip turn move
func canary_whirlwind():
	print("Canary used Whirl Wind.")
	GameManager.turn_log.animate("Songbird flapped some whirlwind! Catster lost her balance.", 1.5)
	GameManager.player.got_canary_whirlwind(self)
	whirlwind_countdown = WHIRLWIND_COOLDOWN
	whirlwind_on_cooldown = true

# Resolve lux arrow countdown
# Return true if still in cooldown
func resolve_lux_arrow_countdown():
	lux_arrow_countdown -= 1
	if lux_arrow_countdown < 1:
		lux_arrow_on_cooldown = false
		GameManager.turn_log.animate("Canary is preparing the Sky-Shattering Lux Arrow...", 1.5)
		#whirlwind_allowed = false
		lux_arrow_cover.show()
		super.shake_rect(lux_arrow_cover, 99999)
		return false
	return true
	
# Resolve sway beat countdown
func resolve_sway_beat_countdown():
	sway_beat_countdown -= 1
	if sway_beat_countdown < 1:
		sway_beat_on_cooldown = false
	
# Resolve whirlwind countdown
func resolve_whirlwind_countdown():
	whirlwind_countdown -= 1
	if whirlwind_countdown < 1:
		whirlwind_on_cooldown = false

# List of affected skills
func got_cat_pounce(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
func got_cat_ult_scratch(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
func got_cat_earth_dust(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
func got_cat_earth_dust_tick(attacker: Character, dmg_percentage: float):
	_receive_hit(attacker, dmg_percentage)
	
func _receive_hit(attacker: Character, dmg_percentage: float):
	var damage = (attacker.attack / self.defense) * dmg_percentage
	if damage > 0:
		print("Canary takes %f damage." % damage)
		super.take_damage(damage)
		got_hit_effect()
	
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
		
func get_icon_tooltip(icon_name: String) -> String:
	match icon_name:
		"canary_sway_beat":
			return "Sway Beat: Attack increased by %d permanently." % [sway_beat_total_attack_increased]
	return "ICON TOOLTIP NOT FOUND"
