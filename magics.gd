extends Node

var magics: Dictionary = {}

func _ready() -> void:
	SaveManager.load_game()  # <- Adicione isso aqui

func add_item(item_name: String, amount: int = 1) -> void:
	if magics.has(item_name):
		magics[item_name] += amount
	else:
		magics[item_name] = amount

func remove_item(item_name: String, amount: int = 1) -> void:
	if magics.has(item_name):
		magics[item_name] -= amount
	else:
		magics[item_name] = amount


func get_item_count(item_name: String) -> int:
	return magics.get(item_name, 0)
