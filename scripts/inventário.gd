extends Node

var inventory: Dictionary = {}

func _ready() -> void:
	SaveManager.load_game()  # <- Adicione isso aqui

func add_item(item_name: String, amount: int = 1) -> void:
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount

func remove_item(item_name: String, amount: int = 1) -> void:
	if inventory.has(item_name):
		inventory[item_name] -= amount
	else:
		inventory[item_name] = amount


func get_item_count(item_name: String) -> int:
	return inventory.get(item_name, 0)
