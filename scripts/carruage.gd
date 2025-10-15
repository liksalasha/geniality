extends Sprite2D

@onready var mapa: CanvasLayer = $mapa

func _ready() -> void:
	mapa.visible = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	mapa.visible = true
