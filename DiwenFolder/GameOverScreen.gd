extends Control

func _ready():
	self.hide()
	GameManager.game_over.connect(_on_game_over)
	get_node("RestartButton").pressed.connect(_on_restart)
	GameManager.register_game_over_screen(self)
	print("Game Over Screen registered!")

func _on_game_over(victor: String):
	# Set text
	if victor == "Player":
		get_node("VictoryText").text = "VICTORY!"
	else:
		get_node("VictoryText").text = "DEFEAT!"
	self.show()
		
func _on_restart():
	self.hide()
	GameManager.reset_game()
	
