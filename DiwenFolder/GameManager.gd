extends Node

# class_name GameManager

# @onready var player: Sprite2D = %Player
var turn_manager: Node
var player: Node
var enemy: Node

func register_player(p: Node):
	player = p
	_try_start()

func register_enemy(e: Node):
	enemy = e
	_try_start()
	
func register_turn_manager(t: Node):
	turn_manager = t
	_try_start()
	
func _try_start():
	if turn_manager and player and enemy:
		turn_manager.initialize()
