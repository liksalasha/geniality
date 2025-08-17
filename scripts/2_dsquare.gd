extends Sprite2D

var rotation_speed = 90.0  # graus por segundo

func _process(delta):
	rotate(deg_to_rad(rotation_speed) * delta)
