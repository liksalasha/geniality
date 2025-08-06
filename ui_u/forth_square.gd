extends Node3D


# Called when the node enters the scene tree for the first time.

var rotation_speed_x = 20.0  # graus por segundo no eixo X
var rotation_speed_y = 20.0  # graus por segundo no eixo Y

func _process(delta):
	rotate_x(deg_to_rad(rotation_speed_x) * delta)
	rotate_y(deg_to_rad(rotation_speed_y) * delta)
	rotate_z(deg_to_rad(20.0) * delta)
