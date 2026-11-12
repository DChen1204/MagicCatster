extends CanvasLayer

# The scene to load after the player picks (choose it in the Inspector)
@export_file("*.tscn") var next_scene: String

@onready var message: Label = $Panel/VBox/Message
@onready var option_a: Button = $Panel/VBox/OptionA
@onready var option_b: Button = $Panel/VBox/OptionB

func _ready() -> void:
	hide()
	message.text = "Victory! Poseidon will aid you in future fights"
	message.text = "Choose a new skill that Poseidon will perform for you in future fights"
	option_a.text = "Hydro Cleanse"
	option_b.text = "Hydro Purify"
	
	# Hover text describing what each attack does
	option_a.tooltip_text = "Hydro Cleanse: Heals the player by 50 HP for 5 turns 30 SP"
	option_b.tooltip_text = "Hydro Purify: Heals once for 175 HP Cost 30 SP"
	
	option_a.pressed.connect(_choose.bind("hydro_cleanse"))
	option_b.pressed.connect(_choose.bind("hydro_purify"))
	GameManager.game_over.connect(_on_game_over)

# Only appear when the player side wins
func _on_game_over(victor: String) -> void:
	if victor == "Player":
		show()

func _choose(attack_id: String) -> void:
	UiAudio.play_click()
	GameManager.chosen_attack = attack_id
	print("Player chose: ", attack_id)
	GameManager.go_to_scene(next_scene)
