extends Node

# This manages the inventory of the player

var inventory: Dictionary[String, int]

@onready var potion_button = get_node("PotionButton")
const SP_POTION_RESTORE_AMOUNT: int = 50

func _ready() -> void:
	
	# Register with the Game Manager
	GameManager.register_inventory_manager(self)
	print("Inventory Manager registered.")
	
	# Add initial items to the inventory
	add_to_inventory("SP_potion", 0)
	inventory["SP_potion"] =  GameManager.sp_potion_on_record
	potion_button.update_tooltip()
	
func reset():
	inventory["SP_potion"] =  GameManager.sp_potion_on_record

# Handle potion consumption
func consume_potion():
	if inventory["SP_potion"] > 0:
		remove_from_inventory("SP_potion", 1)
		GameManager.player.restore_sp(SP_POTION_RESTORE_AMOUNT)
		
	
# Add items to the inventory
func add_to_inventory(item: String, amount: int = 1):
	if not inventory.has(item):
		inventory[item] = 0
	inventory[item] = inventory.get(item, 0) + amount
	
# Remove items from the inventory
func remove_from_inventory(item: String, amount: int = 1):
	if not inventory.has(item):
		inventory[item] = 0
	var new_amount = inventory.get(item, 0) - amount
	inventory[item] = clamp(new_amount, 0, new_amount)
	
