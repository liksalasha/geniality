extends CharacterBody3D


const SPEED = 30.0
const JUMP_VELOCITY = -400.0
@export var player: Node3D  # arraste o player aqui no editor
var life = 7
@onready var area_3d: Area3D = $Area3D
const GRAVITY = Vector3.DOWN * 200.0  # Mais forte que o padrão
@onready var raycast: RayCast3D = $RayCast3D
@export var enemy_id: String = "bzombie_01"

func _ready() -> void:
	if enemy_id in Global.defeated_enemies:
		queue_free()
	#animated_sprite_2d.play("run")
	#area_2d.area_entered.connect(_on_area_entered)
	
	
func _on_area_entered(area):
	if area.is_in_group("projects"):
		life -= Global.damage
	if area.is_in_group("magics"):
		life -= Global.super_damage
	print("zumbi azul levou dano! Vida: ", life)
	if life <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta
		
	if player:
		var direction_to_player = (player.global_position - global_position).normalized()
		direction_to_player.y = 0  # Não considera altura
		direction_to_player = direction_to_player.normalized()
		velocity = direction_to_player * SPEED
	#if velocity.x != 0:
		#animated_sprite_2d.flip_h = velocity.x < 0
	if raycast.is_colliding():
		velocity.y = JUMP_VELOCITY
	move_and_slide()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("projects"):
		life -= 1
		#animated_sprite_2d.play("hurt")
	if area.is_in_group("magics"):
		life -= 4
		#animated_sprite_2d.play("hurt")
	print("blue green zombie3d levou dano! Vida: ", life)
	if life <= 0:
		Global.defeated_enemies.append(enemy_id)  # Use um ID único
		queue_free()
