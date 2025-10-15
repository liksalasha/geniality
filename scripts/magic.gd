extends Area2D

@export var speed := 200.0
var direction := Vector2.RIGHT
@onready var anim: AnimatedSprite2D = $anim
var life = 5

func _ready() -> void:
	anim.play("idle")
	add_to_group("magics")
	
func _process(delta):
	position += direction * speed * delta
	
func _on_body_entered(_body: Node2D) -> void:
	life -= 1
	if life <= 0:
		queue_free() 
		
func _on_area_entered(_area):
	life -= 1
	if life <= 0:
		queue_free()
