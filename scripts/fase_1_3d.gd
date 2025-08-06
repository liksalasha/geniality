extends Node3D

#@export var scene_to_instance : PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change"):
		#get_tree().change_scene_to_packed(scene_to_instance)
		print("Cena trocada")
		#print(scene_to_instance)
	# Salva a posição 2D como Vector3 (Z = 0)
