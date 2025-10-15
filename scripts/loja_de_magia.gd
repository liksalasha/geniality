extends CanvasLayer

#@onready var inventário: CanvasLayer = $"../../../inventário"
@onready var ice_projectile: Button = $"ice projectile"
@onready var ice_magic: Button = $"ice magic"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_life_potion_pressed() -> void:
	Inventário.add_item("ice_projectile", 1)
	#inventário.update_label()
	SaveManager.save_game()
	print("Comprou um projétil de gelo. Total agora:", Inventário.get_item_count("ice_projectile"))
	if Inventário.get_item_count("ice_projectile") == 1:
		ice_projectile.disabled = true

func _on_mana_potion_pressed() -> void:
	Inventário.add_item("ice_magic", 1)
	#inventário.update_label()
	SaveManager.save_game()
	print("Comprou uma projétil de gelo. Total agora:", Inventário.get_item_count("ice_magic"))
	if Inventário.get_item_count("ice_magic") == 1:
		ice_magic.disabled = true
		
		
