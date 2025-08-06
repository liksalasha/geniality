extends CanvasLayer

@onready var life_potion_label: Label = $LifePotionLabel
@onready var mana_potion_label: Label = $ManaPotionLabel
@onready var poção_de_vida: Sprite2D = $PoçãoDeVida
@onready var poção_de_mana: Sprite2D = $PoçãoDeMana

func _ready() -> void:
	update_label()
	poção_de_vida.visible = false
	life_potion_label.visible = false
	poção_de_mana.visible = false
	mana_potion_label.visible = false
	SaveManager.load_game()  # <- Adicione isso aqui
func update_label() -> void:
	life_potion_label.text = "Life Potions: " + str(Inventário.get_item_count("life_potion"))
	mana_potion_label.text = "Mana Potions: " + str(Inventário.get_item_count("mana_potion"))
func _process(delta: float) -> void:
	if Inventário.get_item_count("life_potion") >= 1:
		poção_de_vida.visible = true
		life_potion_label.visible = true
	if Inventário.get_item_count("mana_potion") >= 1:
		poção_de_mana.visible = true
		mana_potion_label.visible = true
	update_label()
