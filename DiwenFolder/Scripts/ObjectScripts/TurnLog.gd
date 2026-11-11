extends RichTextLabel

func _ready():
	# Register with GameManager
	GameManager.register_turn_log(self)
	print("Turn Log registered!")
	text = ""
	
# Make the sentence appear letter by letter in the turn log
# content is the text to be animated, duration is the total time for the animation
func animate(content: String, duration: float):
	text = content
	visible_ratio = 0.0
	create_tween().tween_property(self, "visible_ratio", 1.0, duration)
	
	
