extends Character

# This is the first player character script.

# End turn button
@export var end_turn_button: Button

# The health object of this character. 
@export var health_object: Node

# Set up
func _ready():
	# Assign stats to itself
	super.assign_stats(10, 10, 100, true, 10)
	
	# Connect to health object
	connect_to_health_object()
	
	# Notify SP change
	sp_changed.emit(sp)
	
	# Register with GameManager
	GameManager.register_player(self)
	print("Player 1 registered!")

# Reset the character when reseting the game
func reset():
	super.assign_stats(10, 10, 100, true, 10)
	connect_to_health_object()
	sp_changed.emit(sp)
	
# Called when it's its turn
func play_turn():
	# Refills SP every turn (alternable design choice) 
	sp = 10
	sp_changed.emit(sp)
	# Its turn would not end until end turn button is pressed
	await end_turn_button.pressed
	
# The character's light attack
# Need SP to do
func light_attack(target: Character):
	if (sp >= 3):
		sp -= 3
		sp_changed.emit(sp)
		print("Player light-attack enemy.")
		target.got_light_attacked(self)
		
# The character's heavy attack
# Need SP to do
func heavy_attack(target: Character):
	if (sp >= 4):
		sp -= 4
		sp_changed.emit(sp)
		print("Player heavy-attack enemy.")
		target.got_heavy_attacked(self)
	
# Called by other characters to resolve the attack
func got_light_attacked(actor: Character):
	if actor.attack > self.defense:
		var damage = actor.attack - self.defense
		self.health = self.health - damage
		health_object.take_damage(damage)
		
# Notify the GameManager when dead
func _on_dead(new_status: bool):
	GameManager.register_dead(self)

# Connect to the health object 
func connect_to_health_object():
	health_object.max_health_point = health
	health_object.health_point = health
	health_object.is_dead = false
	health_object.take_damage(0)
	# Sign up for the dead event (when hp drops to zero) 
	health_object.become_dead.connect(_on_dead)
	
