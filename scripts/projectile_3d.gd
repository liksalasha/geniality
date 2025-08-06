extends Area3D

@export var speed: float = 250.0
var direction: Vector3 = Vector3.ZERO

func _process(delta):
	if direction != Vector3.ZERO:
		global_position += direction.normalized() * speed * delta
