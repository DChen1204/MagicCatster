extends CanvasLayer

# The scene to load after the player picks (choose it in the Inspector)
@export_file("*.tscn") var next_scene: String

@onready var message: Label = $Panel/VBox/Message
@onready var option_a: Button = $Panel/VBox/OptionA
@onready var option_b: Button = $Panel/VBox/OptionB

func _ready() -> void:
	hide()
	if get_tree().get_current_scene().scene_file_path == "res://DiwenFolder/Scenes/Scene2.tscn":
		message.text = "Victory! Poseidon will aid you in future fights."
		message.text = "Choose a new skill that Poseidon will perform for you in future fights."
		option_a.text = "Hydro Cleanse"
		option_b.text = "Hydro Purify"
		
		# Hover text describing what each attack does
		option_a.tooltip_text = "Hydro Cleanse: Heals 25 HP per turn for 5 turns."
		option_b.tooltip_text = "Hydro Purify: Heals 90 HP. Cost. Cooldown: 3 turns."
		
		option_a.pressed.connect(_choose.bind("hydro_cleanse"))
		option_b.pressed.connect(_choose.bind("hydro_purify"))
		
	elif get_tree().get_current_scene().scene_file_path == "res://DiwenFolder/Scenes/Scene3.tscn":	
		message.text = "Victory! Rock will aid you in future fights"
		message.text = "Choose a new skill that Rock will perform for you in future fights"
		option_a.text = "Earth Shield"
		option_b.text = "Earth Dust"
		
		# Hover text describing what each attack does
		option_a.tooltip_text = "Earth Shield: Gain a 50% health shield. Cooldown: 5 turns."
		option_b.tooltip_text = "Earth Dust: Deals 40 power damage per turn for 5 turns."
		
		option_a.pressed.connect(_choose.bind("earth_shield"))
		option_b.pressed.connect(_choose.bind("earth_dust"))
	
	
	GameManager.game_over.connect(_on_game_over)

# Only appear when the player side wins
func _on_game_over(victor: String) -> void:
	if victor == "Player":
		show()

func _choose(attack_id: String) -> void:
	UiAudio.play_click()
	if get_tree().get_current_scene().scene_file_path == "res://DiwenFolder/Scenes/Scene2.tscn":
		GameManager.chosen_attack = attack_id
	elif get_tree().get_current_scene().scene_file_path == "res://DiwenFolder/Scenes/Scene3.tscn":
		GameManager.chosen_attack2 = attack_id
	print("Player chose: ", attack_id)
	GameManager.sp_potion_on_record = GameManager.inventory_manager.inventory["SP_potion"]
	GameManager.go_to_scene(next_scene)
