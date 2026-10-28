extends Node

# Turn Manager: The object that controls the turn system. 


# The array of characters in the scene
# Currently it has one player and one enemy character
var turn_queue: Array

# The index of the currently active character
var active_character_index: int = 0

# The turn number
var turn_number: int = 1

# Turn change event notifier
signal turn_changed(new_turn_number: int)

func _ready() -> void:
	GameManager.register_turn_manager(self)
	print("Turn Manager registered!")

func initialize():
	if (GameManager.player != null and GameManager.enemy != null):
		# Add the characters from GameManager
		turn_queue.append(GameManager.player)
		turn_queue.append(GameManager.enemy)
		# Start the turn system
		advance_queue()
		print("Turn Manager Initialized.")
	else:
		print("Player and/or Enemy are null!")
		print("Turn Manager NOT Initialized.")

# Reset itself when game over
func reset():
	active_character_index = 0
	turn_number = 1
	turn_changed.emit(turn_number)

# Manage the turn system
func advance_queue():
	
	# Wait unitl the current character's turn is finished
	await turn_queue[active_character_index].play_turn()
	
	# Ready the next character in the queue
	active_character_index = (active_character_index + 1) % turn_queue.size()
	
	# Increase turn number if everyone went once
	if (active_character_index == 0):
		print("\n")
		turn_number += 1
		turn_changed.emit(turn_number)
		
	# Recursion
	advance_queue()
	
