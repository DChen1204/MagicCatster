extends Node

# Game Manager: The object that controls the game. 
# It is a global variable.

# The game over music controller 
var game_over_music: Control
# The turn manager 
var turn_manager: Node
# The turn log 
var turn_log: Node

# The characters
# var players: Array[Node] = []
var enemy: Character
var player: Character

# Characters that have died (cleared or reset)
# var dead_characters: Array[Node]

# Prevents the game from starting more than once
var _start_queued: bool = false

# Game over event notifier
signal game_over(victor: String)

# Make important objects register themselves with the GameManager.
# Crucial to ensure everything load before the game starts. 
func register_player(p: Node):
	# players.append(p)
	player = p
	_try_start()
func register_enemy(e: Node):
	enemy = e
	_try_start()
func register_turn_manager(t: Node):
	turn_manager = t
	_try_start()
func register_game_over_screen(s: Node):
	game_over_music = s
	_try_start()
func register_turn_log(l: Node):
	turn_log = l
	_try_start()
	
# Start game once every object is registered
# Every player is registered before the tunr queue is built
func _try_start():
	if _start_queued:
		return
	if turn_manager and turn_log and game_over_music and player and enemy:
		_start_queued = true
		call_deferred("_start_game")
		
func _start_game():
	turn_manager.initialize()
	
#Check whether a character has died
func is_dead(c: Character) -> bool:
	return c.is_dead

# Broadcast game_over event when the player or enemy is dead 
func register_dead(d: Node):
	if d == enemy:
		game_over.emit("Player")
	elif d == player:
		game_over.emit("Enemy")
		
# Reset the game
func reset_game():
	player.reset()
	enemy.reset()
	turn_manager.reset()
	turn_log.reset()
	
	# Choices that carry over between fights
var chosen_attack: String = ""

# Clear everything tied to the current battle scene
func clear_battle_state():
	player = null
	enemy = null
	turn_manager = null
	game_over_music = null
	turn_log = null
	_start_queued = false

# Use this instead of calling change_scene_to_file directly
func go_to_scene(path: String):
	clear_battle_state()
	get_tree().change_scene_to_file(path)
	
	# The start screen scene. Change this if you save it somewhere else.
const START_SCREEN: String = "res://DiwenFolder/StartScreen.tscn"

# Begin a fresh run from the start screen
func start_new_game(first_scene: String):
	chosen_attack = ""
	go_to_scene(first_scene)

# Leave the current fight and return to the start screen (restarts the game)
func go_to_start_screen():
	chosen_attack = ""
	go_to_scene(ProjectSettings.get_setting("application/run/main_scene"))
	
func get_turn_number() -> int:
	return turn_manager.turn_number
