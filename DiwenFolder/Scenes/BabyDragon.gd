extends Character


# This is the script for the Baby Dragon boss of the game.
# Phase 1 (grounded): Fire Breath (2-turn charge, burns), Scale Armor, Dragon's Spirit.
# Phase 2 (flying): the same skills plus Aerial Strike (2-4 hits).

"""
Stats of the Baby Dragon
Base Attack = 200
Base Defense = 350
Base Health = 750 (per HP bar, two bars)
Play Character = false
SP = 0
Character Name = Baby Dragon
"""
# Tuning (placeholder numbers, not balance-tested yet)
const PHASE_HEALTH: float = 700.0

const PHASE_TW0_HEALTH: float = 800.0

const FIRE_BREATH_POWER: float = 100.0 # Strong hit when the charge is released

const ARMOR_SHIELD_PERCENT: float = 0.12 # Shield gained per use (share of max HP)
const ARMOR_COOLDOWN: int = 3 # Usable once every 3 turns
const ARMOR_CHANCE: float = 0.5 # Chance to use it when off cooldown

const MEND_THRESHOLD: float = 0.5 # Only at or below 50% health
const MEND_HEAL_PERCENT: float = 0.10 # Healed per tick (share of max HP)
const MEND_TICKS: int = 2 # Number of heals

const AERIAL_HIT_POWER: float = 50.0 # Damage power of each hit
const AERIAL_MIN_HITS: int = 2
const AERIAL_MAX_HITS: int = 4
const AERIAL_CHANCE: float = 0.5 # Chance to pick it over Fire Breath (phase 2)

# Sprites: assign the flying texture in the Inspector
@export var flying_texture: Texture2D
@onready var sprite: Sprite2D = $DragonSprite
var grounded_texture: Texture2D
var original_modulate: Color

# sfx for attacks
#@onready var sfx_fire = get_node_or_null("sfx_fire")
#@onready var sfx_claw = get_node_or_null("sfx_air_strike")

# Shield stats
var shield: float
var max_shield: float

# Battle state
var phase: int = 1
var announce_phase_two: bool = false
var charging_fire: bool = false
var armor_cooldown: int = 0
var mend_used: bool = false
var mend_ticks_left: int = 0

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(200, 350, PHASE_HEALTH, false)
	super.set_character_name("Baby Dragon")
	health_changed.emit()
	
	# The shield bar is scaled to max health. No shield at the start.
	max_shield = max_health
	shield = 0
	shield_changed.emit()
	
	grounded_texture = sprite.texture
	
	# Dim itself until its turn
	sprite.modulate = Color(0.5, 0.5, 0.5)
	original_modulate = sprite.modulate
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Baby Dragon registered!")
	
	

# Reset itself when called
func reset():
	super.assign_stats(attack, defense, PHASE_HEALTH, is_play_character)
	_reset_skill_state()
	phase = 1
	announce_phase_two = false
	sprite.texture = grounded_texture
	health_changed.emit()
	shield_changed.emit()
	max_shield = max_health
	GameManager.turn_log.text = ""
	
# Clear shield, charge, cooldown and heal state (reset and phase change)
func _reset_skill_state():
	shield = 0
	charging_fire = false
	armor_cooldown = 0
	mend_used = false
	mend_ticks_left = 0
	
	
# Play its turn	
func play_turn():
	# Undim when it is its turn
	sprite.modulate = Color(1, 1, 1)
	
	# Cooldown ticks down at the start of every turn
	armor_cooldown = maxi(0, armor_cooldown - 1)
	
	# What the log says before the dragon acts
	var intro := "Baby Dragon eyes Catster..."
	var intro_wait := 1.5
	if announce_phase_two:
		announce_phase_two = false
		intro = "Baby Dragon takes to the sky with a roar! Its wounds are gone!"
		intro_wait = 2.5
	elif mend_ticks_left > 0:
		mend_ticks_left -= 1
		super.heal(max_health * MEND_HEAL_PERCENT)
		intro = "Embers close Baby Dragon's wounds..."
	GameManager.turn_log.animate(intro, 1.0)
	await get_tree().create_timer(intro_wait).timeout
	
	# Do action
	await decide_action()
	
	# Give the player time to read what happened, then dim itself
	await get_tree().create_timer(2.5).timeout
	sprite.modulate = Color(0.5, 0.5, 0.5)
	
	# Enemy AI deciding what to do in its turn
func decide_action():
	# 1. Release the charged Fire Breath
	if charging_fire:
		fire_breath_release()
		return
	
	# 2. Ember Mend once per HP bar when at half health
	if health <= max_health * MEND_THRESHOLD and not mend_used:
		dragon_spirit()
		return
	
	# 3. Scale Armor when off cooldown (sometimes)
	if armor_cooldown == 0 and randf() < ARMOR_CHANCE:
		scale_armor()
		return
	
	# 4. Attack. Only in the flying phase can it use Aerial Strike.
	if phase == 2 and randf() < AERIAL_CHANCE:
		await aerial_strike()
	else:
		fire_breath_charge()
		
# Tooltip text for the status icons above the boss
func get_icon_tooltip(icon_name = "") -> String:
	match str(icon_name).to_lower():
		"dragon scale armor":
			return "Scale Armor: a shield that soaks up damage before health."
		"dragon charging":
			return "Fire Breath: charging! Block next turn to halve the blast."
		"dragon heal":
			return "Dragon's Spirit: heals over 2 turns."
		_:
			return ""

# List of Skills

# Fire Breath, turn 1: gather fire (no damage). Bturn 2: Unleash hell
func fire_breath_charge():
	charging_fire = true
	print("The Dragon is charging its Fire Breath")
	GameManager.turn_log.animate("Baby Dragon is inhaling...", 1.5)
	
# Fire Breath, turn 2: Unleash hell anad burns
func fire_breath_release():
	charging_fire = false
	print("Dragon used Fire Breath")
	#_play_sfx(sfx_fire)
	GameManager.turn_log.animate("Baby Dragon unleashed Fire Breath! Catster is burning!", 1.5)
	GameManager.player.got_dragon_fire_breath(self, FIRE_BREATH_POWER)
	
# Scale Armor: adds a small shield every time
func scale_armor():
	shield = minf(shield + max_shield * ARMOR_SHIELD_PERCENT, max_shield)
	armor_cooldown = ARMOR_COOLDOWN
	shield_changed.emit()
	print("Dragon used Scale Armor.")
	GameManager.turn_log.animate("Baby Dragon hardened its scales!", 1.5)

# Dragon Spirit: heals now and again at the start of its next turn
func dragon_spirit():
	mend_used = true
	super.heal(max_health * MEND_HEAL_PERCENT)
	mend_ticks_left = MEND_TICKS - 1
	print("Dragon used Dragon Spirit.")
	GameManager.turn_log.animate("Baby Dragon bathed in embers! Its wounds begin to close.", 1.5)

# Aerial Strike (flying phase): 2-4 hits
func aerial_strike():
	var hits := randi_range(AERIAL_MIN_HITS, AERIAL_MAX_HITS)
	print("Dragon used Aerial Strike (%d hits)." % hits)
	GameManager.turn_log.animate("Baby Dragon dives from the sky!", 1.0)
	for i in hits:
		await get_tree().create_timer(0.4).timeout
		#_play_sfx(sfx_claw)
		GameManager.player.got_dragon_aerial_strike(self, AERIAL_HIT_POWER)
		if GameManager.player.is_dead:
			break
	GameManager.player.flashed_once = false
	GameManager.turn_log.animate("Baby Dragon struck Catster %d times!" % hits, 1.5)
	
# Phase change: the first time it "dies", it refills its HP bar and takes flight
func on_dead():
	if phase == 1:
		phase = 2
		_enter_flying_phase.call_deferred()
		return
	super.on_dead()

func _enter_flying_phase():
	phase = 2
	print("Baby Dragon enters the flying phase!")
	_reset_skill_state()
	health = PHASE_TW0_HEALTH
	max_shield = max_health
	health = max_health
	sprite.texture = flying_texture
	announce_phase_two = true
	health_changed.emit()
	shield_changed.emit()
	
# List of affected skills
func got_cat_pounce(attacker: Character, dmg_percentage: float):
	_take_hit((attacker.attack / self.defense) * dmg_percentage)

func got_cat_ult_scratch(attacker: Character, dmg_percentage: float):
	_take_hit((attacker.attack / self.defense) * dmg_percentage)
	
# ADD THE OTHER ABILITIES WHEN READY

# The shield absorbs damage first, the rest hits health
func _take_hit(damage: float):
	if shield > 0:
		if shield >= damage:
			shield -= damage
			damage = 0.0
		else:
			damage -= shield
			shield = 0.0
		shield_changed.emit()
	if damage > 0:
		print("Baby Dragon takes %f damage." % damage)
		super.take_damage(damage)
	got_hit_effect()

# Got hit special affect
func got_hit_effect():
	for i in 2:
		sprite.modulate = Color(3, 3, 3)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate
		await get_tree().create_timer(0.1).timeout

# Play a sound if that node exists
func _play_sfx(sfx):
	if sfx != null:
		sfx.play()
