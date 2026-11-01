extends Button

# This script switches scene to goldfish level
# THIS DOES NOW WORK RIGHT NOW

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://DiwenFolder/Scene2.tscn")
