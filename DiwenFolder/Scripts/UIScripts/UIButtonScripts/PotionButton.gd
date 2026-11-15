extends TextureButton

var item: String = "SP_potion"

func _ready() -> void:
	pressed.connect(_on_pressed)
	print("Potion Button Initialized")
	
func _on_pressed() -> void:
	UiAudio.play_click()
	consumeItem()
	update_tooltip()
	
func consumeItem():
	GameManager.inventory_manager.consume_potion()
	
func update_tooltip():
	tooltip_text = "SP Potion: Recovers 50 SP.
	Remaining Amount: %d" % [GameManager.inventory_manager.inventory[item]]
