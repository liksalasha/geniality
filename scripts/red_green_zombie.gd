extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0
@export var player: Node2D  # arraste o player aqui no editor
var life = 5
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@export var enemy_id: String = "rzombie_01"

func _ready() -> void:
	if enemy_id in Global.defeated_enemies:
		queue_free()
	animated_sprite_2d.play("run")
	area_2d.area_entered.connect(_on_area_entered)
	
	
func _on_area_entered(area):
	if area.is_in_group("projects"):
		life -= Global.damage
	if area.is_in_group("magics"):
		life -= Global.super_damage
	print("zumbi vermelho levou dano! Vida: ", life)
	if life <= 0:
		Global.defeated_enemies.append(enemy_id)  # Use um ID único
		queue_free()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * SPEED
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0

	move_and_slide()
