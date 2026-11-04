extends Control

# This script to control the game over screen.
# Right now the game over screen has a popup and a restart button.

# Set to false in scenes where another popup handles victory (Scene2)
@export var show_on_victory: bool = true

# Victory Music
@onready var victory_music: AudioStreamPlayer = $VictoryMusic

# Defeat Music
@onready var defeat_music: AudioStreamPlayer = $DefeatMusic

# The battle music to stop when the fight ends (assign in the Inspector)
@export var battle_music: AudioStreamPlayer

func _ready():
	# Make itself invisible at the start of the game
	self.hide()
	
	# Sign up for the game_over event from GameManager
	GameManager.game_over.connect(_on_game_over)
	
	# Call _on_restart() when the restart button is pressed
	get_node("RestartButton").pressed.connect(_on_restart)
	
	# Register itself with the GameManager (makes sure it loads)
	GameManager.register_game_over_screen(self)
	print("Game Over Screen registered!")

# Appear when game over
func _on_game_over(victor: String):
	#Stop the battle music when the fight ends
	if battle_music:
		battle_music.stop()
	# Set the text for the popup
	if victor == "Player":
		victory_music.play()
		get_node("VictoryText").text = "VICTORY!"
	else:
		defeat_music.play()
		get_node("VictoryText").text = "DEFEAT!"
	
	# Make itself visibile
	self.show()
		

# Notify the GameManager to reset the game
func _on_restart():
	self.hide()
	GameManager.reset_game()
	if battle_music:
		battle_music.play()
	
	
