extends Node

# Right now, it is just a cycle between the player and one enemy.

# The player and enemy objects

# Variables
var active_character_index: int = 0
var turn_queue: Array
var turn_number: int = 1

# Notify other scripts
signal turn_number_changed(new_value: int)

func _ready() -> void:
	GameManager.register_turn_manager(self)
	print("Turn Manager registered!")


func initialize():
	if (GameManager.player != null and GameManager.enemy != null):
		turn_queue.append(GameManager.player)
		turn_queue.append(GameManager.enemy)
		advance_queue()
		print("Turn Manager Initialized.")
	else:
		print("Player and/or Enemy are null!")
		print("Turn Manager NOT Initialized.")

func reset():
	active_character_index = 0
	turn_number = 1
	turn_number_changed.emit(turn_number)

# Manage the turns 
func advance_queue():
	
	# Wait the current character's turn to finish
	await turn_queue[active_character_index].play_turn()
	
	# Ready the next character's turn
	active_character_index = (active_character_index + 1) % turn_queue.size()
	
	# Increase turn number if everyone went once
	if (active_character_index == 0):
		print("\n")
		turn_number += 1
		turn_number_changed.emit(turn_number)
		
	# Recursion
	advance_queue()
	
