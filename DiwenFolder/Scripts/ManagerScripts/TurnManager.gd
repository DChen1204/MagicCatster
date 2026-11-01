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
	if (GameManager.players != null and GameManager.enemy != null):
		# Add the characters from GameManager (players first, then the enemy)
		for p in GameManager.players:
			turn_queue.append(p)
		turn_queue.append(GameManager.enemy)
		# Start the turn system
		advance_queue()
		print("Turn Manager Initialized.")
	else:
		print("Player(s) and/or Enemy are null!")
		print("Turn Manager NOT Initialized.")

# Reset itself when game over
# Need to fix the issue where the button disappear on reset
func reset():
	active_character_index = 0
	turn_number = 1
	turn_changed.emit(turn_number)
	# advance_queue()
	
# Move to the next character in th queue and count turns
func _step_index():
	active_character_index = (active_character_index + 1) % turn_queue.size()
	
	# Increase turn number if everyone went
	if (active_character_index == 0):
		turn_number +=1
		turn_changed.emit(turn_number)

# Manage the turn system
func advance_queue():
	
	# Skip dead characters so they don't stall the queue
	var skipped = 0
	while GameManager.is_dead(turn_queue[active_character_index]):
		_step_index()
		skipped += 1
		if skipped >= turn_queue.size():
			return # Eveyone died, stop
	
	# Wait unitl the current character's turn is finished
	await turn_queue[active_character_index].play_turn()
	
	# Ready the next character in the queue
	_step_index()
	
	# Recursion
	advance_queue()
	
