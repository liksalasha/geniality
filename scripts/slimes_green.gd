extends CharacterBody2D

var BASE_SPEED = 70.0
var JUMP_SPEED = 800.0
var JUMP_FORCE = -200.0
var SPEED = BASE_SPEED

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@export var player: Node2D  # arraste o player aqui no editor
var has_jumped = false
@onready var jump_timer: Timer = $JumpTimer
var can_jump = true
@onready var anim: AnimatedSprite2D = $anim
var life = 2
@onready var area_2d: Area2D = $Area2D
@export var enemy_id: String = "slime_01"

func _ready() -> void:
	if enemy_id in Global.defeated_enemies:
		queue_free()
	animated_sprite_2d.play("run")
	jump_timer.wait_time = 1.0  # tempo entre pulos (em segundos)
	anim.visible = false
	area_2d.area_entered.connect(_on_area_entered)
	print(area_2d)
	print(life)
	jump_timer.wait_time = 3.0  # tempo entre pulos
	jump_timer.timeout.connect(_on_jump_timer_timeout)

func _on_area_entered(area):
	if area.is_in_group("projects"):
		life -= Global.damage
		flash_red()
	if area.is_in_group("magics"):
		life -= Global.super_damage
		flash_red()
	print("Slime levou dano! Vida: ", life)
	if life <= 0:
		Global.defeated_enemies.append(enemy_id)  # Use um ID único
		queue_free()

func flash_red() -> void:
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
		
func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		SPEED = BASE_SPEED
		anim.visible = false

	# Só pula se puder, e se o raycast detectar chão
	if raycast.is_colliding() and can_jump:
		can_jump = false
		has_jumped = true
		anim.visible = true
		anim.play("Oh")

		# Aplica impulso vertical
		velocity.y = JUMP_FORCE  # força pra cima
		SPEED = BASE_SPEED * 1.5  # move mais rápido no pulo, se quiser
		jump_timer.start()
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * 100  # impulso pra frente no pulo

	# Detecta direção do player DEPOIS de mudar o SPEED
	if player:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * SPEED

	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		raycast.target_position.x = sign(velocity.x) * abs(raycast.target_position.x)

	move_and_slide()

	
func _on_jump_timer_timeout():
	can_jump = true
