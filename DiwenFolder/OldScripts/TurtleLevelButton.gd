extends Button

# This script switches the scene to Turtle Level
# THIS DOES NOT WORK RIGHT NOW

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://DiwenFolder/Scene3.tscn")
