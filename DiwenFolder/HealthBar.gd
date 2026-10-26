extends ProgressBar
@export var target: Health

func _ready() -> void:
	max_value = target.max_health_point
	value = target.health_point
	target.health_changed.connect(_on_health_changed)
	
func _on_health_changed(new_value: float) -> void:
	value = new_value
