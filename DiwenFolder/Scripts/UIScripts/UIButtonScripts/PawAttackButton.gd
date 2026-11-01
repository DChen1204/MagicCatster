extends Button

# This script is to control Cat Paw Attack . 

# attacker: The character that does the attack
# target: The character that gets attacked
@export var attacker: Character
@export var target: Character
# @onready var ui_button1: AudioStreamPlayer = $"../../ui_Button1"

# When the button is pressed, call the _on_pressed function
func _ready() -> void:
	pressed.connect(_on_pressed)
	
# Notify the attacker to light attack the target
func _on_pressed() -> void:
	# ui_button1.play()
	if is_instance_valid(target) and is_instance_valid(attacker):
		attacker.cat_paw_scratch(target)
