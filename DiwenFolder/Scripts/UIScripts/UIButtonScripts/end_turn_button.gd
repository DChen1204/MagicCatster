extends Button

# This script plays a sound when the End Turn button is pressed



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	UiAudio.play_click()
