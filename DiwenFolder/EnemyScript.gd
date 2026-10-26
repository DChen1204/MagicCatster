extends Sprite2D

func _ready():
	GameManager.register_enemy(self)
	print("Enemy registered!")

func play_turn():
	print("Enemy turn starts.")
	await get_tree().create_timer(1.0).timeout
	print("Enemy turn ends.")
