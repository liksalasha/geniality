extends Area2D

@export var speed := 250.0
var direction := Vector2.RIGHT
@onready var animm: AnimatedSprite2D = $animm

func _ready() -> void:
	animm.play("idle")
	add_to_group("projects")

func _process(delta):
	position += direction * speed * delta

func _on_area_entered(_area):
	queue_free()  # destrói ao colidir, se quiser


func _on_body_entered(_body: Node2D) -> void:
	queue_free() 
