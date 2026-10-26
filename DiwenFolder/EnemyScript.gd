extends Character

@export var health_object: Node

var total_defense 

func _ready():
	super.assign_stats(20, 5, 100, false)
	health_object.max_health_point = health
	health_object.health_point = health
	total_defense = defense
	shield_changed.emit(false)
	GameManager.register_enemy(self)
	print("Enemy registered!")

func play_turn():
	shielded = false
	total_defense = defense
	shield_changed.emit(false)
	decide_action()
	
# Enemy AI deciding what to do in its turn
func decide_action():
	if randf() < 0.5:
		light_attack(GameManager.player)
	else:
		shield()
	
func light_attack(target: Character):
	print("Enemy light-attack player.")
	target.got_light_attacked(self)
	
func shield():
	print("Enemy has shield itself.")
	shielded = true;
	total_defense = defense + 3
	shield_changed.emit(true)
	
func got_light_attacked(actor: Character):
	if actor.attack > self.total_defense:
		var damage = actor.attack - self.total_defense
		self.health = self.health - damage
		health_object.take_damage(damage)
		
func got_heavy_attacked(actor: Character):
	# break shield
	if shielded:
		shielded = false
		total_defense = defense
		shield_changed.emit(false)
		print("Enemy shield broken!")
	
	# take damage 
	if actor.attack > self.total_defense:
		var damage = actor.attack - self.total_defense
		self.health = self.health - damage
		health_object.take_damage(damage)
	
