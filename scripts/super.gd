extends Area2D

@export var speed := 200.0
var direction := Vector2.RIGHT
@onready var anim: AnimatedSprite2D = $animm

func _ready() -> void:
	anim.play("idle")
	add_to_group("projects")

func _process(delta):
	position += direction * speed * delta
