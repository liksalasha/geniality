extends Node3D

#func _on_area_3d_body_entered(body: Node3D) -> void:
	#if body.has_method("respawn"):
		#body.checkpoint_position = global_position
		#print("Checkpoint salvo em: ", global_position)
