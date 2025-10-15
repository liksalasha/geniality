extends CanvasLayer

@onready var ice_projectile_label: Label = $"Ice projectile label"
@onready var ice_magic_label: Label = $"Ice magic label"
@onready var ice_projectile: Sprite2D = $"ice projectile"
@onready var ice_magic: Sprite2D = $"ice Magic"

func _ready() -> void:
	update_label()
	ice_projectile.visible = false
	ice_projectile_label.visible = false
	ice_magic.visible = false
	ice_magic_label.visible = false
	SaveManager.load_game()  # <- Adicione isso aqui
func update_label() -> void:
	ice_projectile_label.text = "ice projectile: " + str(Inventário.get_item_count("ice_projectile"))
	ice_magic_label.text = "ice magic: " + str(Inventário.get_item_count("ice_magic"))
func _process(_delta: float) -> void:
	if Inventário.get_item_count("ice_projectile") >= 1:
		ice_projectile.visible = true
		ice_projectile_label.visible = true
	if Inventário.get_item_count("ice_magic") >= 1:
		ice_magic.visible = true
		ice_magic_label.visible = true
	update_label()
