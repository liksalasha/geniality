extends Node2D

@export var fase: PackedScene  # Agora é possível selecionar a cena no editor

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if fase:
		get_tree().change_scene_to_packed(fase)
