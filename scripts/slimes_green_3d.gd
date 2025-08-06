extends CharacterBody3D

var SPEED = 50.0
const JUMP_VELOCITY = -100.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@export var player: Node3D  # arraste o player aqui no editor
var has_jumped = false
@onready var jump_timer: Timer = $JumpTimer
var can_jump = true
#@onready var anim: AnimatedSprite2D = $anim
var life = 2
@onready var area_2d: Area2D = $Area2D
@export var enemy_id: String = "slime_01"

func _ready() -> void:
	if enemy_id in Global.defeated_enemies:
		queue_free()
	#animated_sprite_2d.play("run")
	#jump_timer.wait_time = 1.0  # tempo entre pulos (em segundos)
	#anim.visible = false
	#area_2d.area_entered.connect(_on_area_entered)
	print(area_2d)
	print(life)
func _on_JumpTimer_timeout():
	can_jump = true  # libera o próximo pulo


func _on_area_entered(area):
	if area.is_in_group("projects"):
		life -= Global.damage
		#animated_sprite_2d.play("hurt")
	if area.is_in_group("magics"):
		life -= Global.super_damage
		#animated_sprite_2d.play("hurt")
	print("Slime levou dano! Vida: ", life)
	if life <= 0:
		Global.defeated_enemies.append(enemy_id)  # Use um ID único
		queue_free()
func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * SPEED
	#if velocity.x != 0:
		#animated_sprite_2d.flip_h = velocity.x < 0

	# Pulo com controle de uma vez só
	#if raycast.is_colliding() and not has_jumped and can_jump:
		#velocity.y = JUMP_VELOCITY
		#SPEED = 600
		#has_jumped = true
		#can_jump = false
		#jump_timer.start()
		#anim.visible = true
		#anim.play("Oh")
	#elif not raycast.is_colliding():
		#has_jumped = true
		#can_jump = false
		#SPEED = 70
		#anim.visible = false
	# Libera novo pulo quando encosta no chão
	#if is_on_floor():
		#has_jumped = false
		#can_jump = true
		
	#if velocity.x != 0:
		#animated_sprite_2d.flip_h = velocity.x < 0
		#raycast.target_position.x = sign(velocity.x) * abs(raycast.target_position.x)
		
	
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("projects"):
		life -= 1
		#animated_sprite_2d.play("hurt")
	if area.is_in_group("magics"):
		life -= 4
		#animated_sprite_2d.play("hurt")
	print("Slime levou dano! Vida: ", life)
	if life <= 0:
		Global.defeated_enemies.append(enemy_id)  # Use um ID único
		queue_free()
