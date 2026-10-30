extends Character

# The first enemy character script. 

# The health object of this character.
@export var health_object: Node

# Used when resolving attacks
var total_defense 

func _ready():
	# Assign stats to itself
	super.assign_stats(20, 5, 100, false)
	
	# Connect to health object
	connect_to_health_object()
	
	# Reset shield 
	change_shield(false)
	
	# Register itself with GameManager
	GameManager.register_enemy(self)
	print("Enemy 1 registered!")

# Reset itself when called
func reset():
	super.assign_stats(20, 5, 100, false)
	connect_to_health_object()
	change_shield(false)
	
# Play its turn	
func play_turn():
	change_shield(false)
	decide_action()
	
# Enemy AI deciding what to do in its turn
# Right, it is random 50/50 attacking and shielding
func decide_action():
	if randf() < 0.5:
		var target = pick_target()
		# If no player is alive, there is nothing to attack
		if target != null:
			light_attack(target)
	else:
		shield()
	# Pick a randome player that is still alive
func pick_target() -> Character:
		var living_players: Array = []
		for p in GameManager.players:
			if not GameManager.is_dead(p):
				living_players.append(p)
		if living_players.is_empty():
			return null
		return living_players.pick_random()
# Light attack
func light_attack(target: Character):
	print("Enemy light-attack player.")
	target.got_light_attacked(self)
	
# Shield
func shield():
	print("Enemy has shield itself.")
	change_shield(true, 3)
	
# Got light attack
func got_light_attacked(actor: Character):
	if actor.attack > self.total_defense:
		var damage = actor.attack - self.total_defense
		self.health = self.health - damage
		health_object.take_damage(damage)
		
# Got heavey attack (breaks shield)
func got_heavy_attacked(actor: Character):
	# break shield
	if shielded:
		change_shield(false)
		print("Enemy shield broken!")
	
	# take damage 
	if actor.attack > self.total_defense:
		var damage = actor.attack - self.total_defense
		self.health = self.health - damage
		health_object.take_damage(damage)

# Notify GameManager when dead
func _on_dead(new_value: bool):
	GameManager.register_dead(self)
	
# Connect to the health object
func connect_to_health_object():
	health_object.max_health_point = health
	health_object.health_point = health
	health_object.become_dead.connect(_on_dead)
	health_object.is_dead = false
	health_object.take_damage(0)
	
# Change the shield status
func change_shield(shield: bool, extra_defense: int = 0):
	total_defense = defense + extra_defense
	shielded = shield
	shield_changed.emit(shield)
	
	
