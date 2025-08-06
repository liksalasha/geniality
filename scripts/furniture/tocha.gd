extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
@export var respawn_position: Vector2

func _ready() -> void:
	animated_sprite_2d.play("tocha")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.checkpoint_position = global_position
		print("Checkpoint salvo em: ", global_position)
