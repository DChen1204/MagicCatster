extends Button

# This script plays a sound when the End Turn button is pressed

@onready var ui_button1: AudioStreamPlayer = $"../ui_Button1"  # adjust path


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ui_button1.play()
