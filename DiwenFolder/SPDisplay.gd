extends RichTextLabel

@export var target: Character

func _ready() -> void:
	text = "Player SP %d" % target.sp
	target.sp_changed.connect(_on_sp_changed)
	
func _on_sp_changed(new_value: int) -> void:
	text = "Player SP %d" % new_value
