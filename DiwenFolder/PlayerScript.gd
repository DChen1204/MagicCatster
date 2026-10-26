extends Sprite2D

@export var end_turn_button: Button

func _ready():
	GameManager.register_player(self)
	print("Player registered!")
	

func play_turn():
	print("Player turn begins.")
	await end_turn_button.pressed
	print("Player turn ends.")
