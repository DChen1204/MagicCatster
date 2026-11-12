extends Button

func _ready() -> void:
	print("Exit Button Initialized")
	pressed.connect(_on_pressed)
	

func _on_pressed() -> void:
	UiAudio.play_click()
	GameManager.go_to_start_screen()
