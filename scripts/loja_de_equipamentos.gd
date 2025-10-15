extends CanvasLayer

@onready var inventário: CanvasLayer = $"../../../inventário"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_life_potion_pressed() -> void:
	Inventário.add_item("life_potion", 1)
	inventário.update_label()
	SaveManager.save_game()
	print("Comprou uma poção. Total agora:", Inventário.get_item_count("life_potion"))


func _on_mana_potion_pressed() -> void:
	Inventário.add_item("mana_potion", 1)
	inventário.update_label()
	SaveManager.save_game()
	print("Comprou uma poção. Total agora:", Inventário.get_item_count("mana_potion"))
