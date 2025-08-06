extends Sprite2D

@export var speed := 20.0  # velocidade da nuvem (positiva)
@export var reset_x := -200.0  # onde ela reaparece à direita
@export var start_x := 800.0   # posição onde ela aparece novamente

func _process(delta: float) -> void:
	position.x -= speed * delta  # ← esquerda

	if position.x < reset_x:
		position.x = start_x
