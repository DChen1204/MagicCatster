extends Node

# Game Manager: The object that controls the game. 
# It is currently the only global variable.

# The game over screen 
var game_over_screen: Control
# The turn manager 
var turn_manager: Node

# The characters
var player: Node
var enemy: Node

# Game over event notifier
signal game_over(victor: String)

# Make important objects register themselves with the GameManager.
# Crucial to ensure everything load before the game starts. 
func register_player(p: Node):
	player = p
	_try_start()
func register_enemy(e: Node):
	enemy = e
	_try_start()
func register_turn_manager(t: Node):
	turn_manager = t
	_try_start()
func register_game_over_screen(s: Node):
	game_over_screen = s
	_try_start()
	
# Start game once every object is registered
func _try_start():
	if turn_manager and game_over_screen and player and enemy:
		turn_manager.initialize()

# Broadcast game_over event when the player or enemy is dead 
func register_dead(d: Node):
	if d == enemy:
		game_over.emit("Player")
	else:
		game_over.emit("Enemy")
		
# Reset the game
func reset_game():
	turn_manager.reset()
	player.reset()
	enemy.reset()
