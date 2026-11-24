extends TextureButton

var item: String = "SP_potion"

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	print("Potion Button Initialized")
	
func _on_pressed() -> void:
	UiAudio.play_click()
	consumeItem()
	update_tooltip()
	
func _on_mouse_entered() -> void:
	if GameManager.player.sp >= GameManager.player.max_sp:
		self_modulate = Color(1.0, 0.6, 0.6)
	else:
		self_modulate = Color(0.6, 0.6, 1.0)
	
func _on_mouse_exited() -> void:
	self_modulate = Color(1.0, 1.0, 1.0)
	
func press_flash_blue():
	self_modulate = Color(0.5, 0.5, 1.0)
	await get_tree().create_timer(0.2).timeout
	_on_mouse_entered()
	
func press_flash_red():
	self_modulate = Color(1.0, 0.5, 0.5)
	await get_tree().create_timer(0.2).timeout
	_on_mouse_entered()

func consumeItem():
	GameManager.inventory_manager.consume_potion()
	
func update_tooltip():
	tooltip_text = "SP Potion: Recovers 30 SP.
	Remaining Amount: %d" % [GameManager.inventory_manager.inventory[item]]
