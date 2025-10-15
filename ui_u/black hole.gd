extends MeshInstance3D

@export var rotation_speed: float = -10.0 # graus por segundo

func _process(delta):
	rotate_z(deg_to_rad(rotation_speed) * delta)
	rotate_y(deg_to_rad(rotation_speed) * delta)
