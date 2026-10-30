extends Node

# Game Manager: The object that controls the game. 
# It is currently the only global variable.

# The game over screen 
var game_over_screen: Control
# The turn manager 
var turn_manager: Node

# The characters
var players: Array[Node] = []
var enemy: Node

# Characters that have died (cleared or reset)
var dead_characters: Array[Node]

# Prevents the game from starting more than once
var _start_queued: bool = false

# Game over event notifier
signal game_over(victor: String)

# Make important objects register themselves with the GameManager.
# Crucial to ensure everything load before the game starts. 
func register_player(p: Node):
	players.append(p)
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
# Every player is registered before the tunr queue is built
func _try_start():
	if _start_queued:
		return
	if turn_manager and game_over_screen and players.size() > 0 and enemy:
		_start_queued = true
		call_deferred("_start_game")
		
func _start_game():
	turn_manager.initialize()
	
	#Check whether a character has died
func is_dead(c: Node) -> bool:
	return c in dead_characters

# Broadcast game_over event when the player or enemy is dead 
func register_dead(d: Node):
	if not (d in dead_characters):
		dead_characters.append(d)
	if d == enemy:
		game_over.emit("Player")
	elif players.all(func(p): return p in dead_characters):
		game_over.emit("Enemy")
		
# Reset the game
func reset_game():
	dead_characters.clear()
	for p in players:
		p.reset()
	enemy.reset()
	turn_manager.reset()
