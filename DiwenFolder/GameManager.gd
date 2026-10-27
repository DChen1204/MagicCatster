extends Node

# class_name GameManager

var game_over_screen: Control

# @onready var player: Sprite2D = %Player
var turn_manager: Node

var player: Node
var enemy: Node

signal game_over(victor: String)

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
	
func _try_start():
	if turn_manager and game_over_screen and player and enemy:
		turn_manager.initialize()

# Reset the game when one enemy is dead(for now) 
func register_dead(d: Node):
	if d == enemy:
		game_over.emit("Player")
	else:
		game_over.emit("Enemy")
		
func reset_game():
	turn_manager.reset()
	player.reset()
	enemy.reset()
