extends RichTextLabel

# This script controls the sp text of a character.

# The character that has this sp text. 
@export var target: Character

func _ready() -> void:
	# Update the text
	text = "SP: %d / %d" % [target.sp, target.max_sp]
	
	# Update the text when sp changes
	target.sp_changed.connect(_on_sp_changed)
	
# Update the text when sp changes
func _on_sp_changed() -> void:
	text = "SP: %d / %d" % [target.sp, target.max_sp]
