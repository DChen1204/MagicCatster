extends Button

# This script is to control Cat Skills. Pick which skill in the Inspector.

enum Skill { BLOCK, POUNCE, ULT, CLEANSE, PURIFY }

@export var skill: Skill = Skill.POUNCE
@export var attacker: Character
@export var target: Character

func _ready() -> void:
	pressed.connect(_on_pressed)
	# Hover text comes from Cat.gd, so costs always match its constants
	if is_instance_valid(attacker):
		tooltip_text = attacker.get_skill_tooltip(Skill.keys()[skill].to_lower())

func _on_pressed() -> void:
	UiAudio.play_click()
	if not (is_instance_valid(attacker) and is_instance_valid(target)):
		return
	# Only act during the attacker's own turn
	if not GameManager.turn_manager.get_active_character(attacker):
		return
	match skill:
		Skill.BLOCK:
			attacker.cat_block()
		Skill.POUNCE:
			attacker.cat_pounce(target)
		Skill.ULT:
			attacker.cat_ult_scratch(target)
		Skill.CLEANSE:
			attacker.cat_hydro_cleanse()
		Skill.PURIFY:
			attacker.cat_hydro_purify()
