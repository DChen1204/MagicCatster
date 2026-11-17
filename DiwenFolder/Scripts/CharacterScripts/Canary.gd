extends Character

# This is the script for the Canary Enemy of the game.
# It has the air element magic and focuses on attacking. 

"""
Stats of the Canary
Base Attack = 300
Base Defense = 200
Base Health = 500
Play Character = false
SP = 0
Character Name = Songbird
"""

# Sprite variables
@onready var sprite: Sprite2D = $CanarySprite
var original_modulate: Color

# Set up
func _ready():
	# Assign stats and name to itself
	super.assign_stats(300, 200, 500, false)
	super.set_character_name("Songbird")
	
	health_changed.emit()
	
	# Dim itself
	sprite.modulate = Color(0.5, 0.5, 0.5) 
	original_modulate = sprite.modulate
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Songbird registered!")
	
# Reset itself when called
func reset():
	# reset basic stats 
	super.assign_stats(attack, defense, max_health, is_play_character)
	health_changed.emit()
	
