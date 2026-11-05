extends CanvasLayer

# The scene to load after the player picks (choose it in the Inspector)
@export_file("*.tscn") var next_scene: String

@onready var message: Label = $Panel/VBox/Message
@onready var option_a: Button = $Panel/VBox/OptionA
@onready var option_b: Button = $Panel/VBox/OptionB

func _ready() -> void:
	hide()
	message.text = "Victory! Choose a new attack to carry into the next fight."
	option_a.text = "Water Cleanse"
	option_b.text = "Water Purify"
	option_a.pressed.connect(_choose.bind("water_cleanse"))
	option_b.pressed.connect(_choose.bind("water_purify"))
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
