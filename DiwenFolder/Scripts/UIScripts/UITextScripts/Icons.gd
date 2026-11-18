extends TextureRect

# This script to organize the tool tip of the status effect icons

enum Icon {
	CAT_CLEANSE, CAT_DUST,
	GOLDFISH_HEALING_TIDE, 
	TURTLE_CRAZY_DIAMOND, TURTLE_STUN, TURTLE_DUST,
	CANARY_SWAY_BEAT,
}

@export var icon: Icon
@export var target: Character

func _ready() -> void:
	if is_instance_valid(target):
		tooltip_text = target.get_icon_tooltip(Icon.keys()[icon].to_lower())

func update_tooltip() -> void:
	if is_instance_valid(target):
		tooltip_text = target.get_icon_tooltip(Icon.keys()[icon].to_lower())
