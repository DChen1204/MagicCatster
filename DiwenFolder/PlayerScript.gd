extends Character

@export var end_turn_button: Button
@export var health_object: Node

func _ready():
	super.assign_stats(10, 10, 100, true, 10)
	health_object.max_health_point = health
	health_object.health_point = health
	sp_changed.emit(sp)
	GameManager.register_player(self)
	print("Player registered!")

func play_turn():
	sp = 10
	sp_changed.emit(sp)
	await end_turn_button.pressed
	
func light_attack(target: Character):
	if (sp >= 3):
		sp -= 3
		sp_changed.emit(sp)
		print("Player light-attack enemy.")
		target.got_light_attacked(self)
		
func heavy_attack(target: Character):
	if (sp >= 4):
		sp -= 4
		sp_changed.emit(sp)
		print("Player heavy-attack enemy.")
		target.got_heavy_attacked(self)
	
func got_light_attacked(actor: Character):
	if actor.attack > self.defense:
		var damage = actor.attack - self.defense
		self.health = self.health - damage
		health_object.take_damage(damage)
