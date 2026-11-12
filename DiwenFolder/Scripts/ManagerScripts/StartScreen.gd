extends Control

# The first fight, loaded when the player presses Start
@export var first_scene: PackedScene

@onready var start_button: Button = $Center/VBox/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	# Lets Enter or Space press Start
	start_button.grab_focus()
	print("Start Screen Initialized")

func _on_start_pressed() -> void:
	UiAudio.play_click()
	GameManager.start_new_game(first_scene.resource_path)
