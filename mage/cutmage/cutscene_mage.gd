extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var inventário: CanvasLayer = $"../inventário"
@onready var magia: CanvasLayer = $"../Magia"

var SPEED = 200.0
const JUMP_VELOCITY = -500.0
var checkpoint_position: Vector2
var can_teleport: bool = false
var teleport_target: Node2D = null
var life = 3
var mana = 5
var is_playing_magic_animation: bool = false

func _ready() -> void:
	#raycast.enabled = true
	#raycast.target_position.x = flip_h_direction() * 160
	print("Raycast ativado!")
	#anim.visible = false
	# Timer automático a cada 2 segundos (ajuste como quiser)
	var timer = Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	inventário.visible = false
	magia.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_timer_timeout():
	var pos_2d = global_position
	print("Salvando pos2D:", global_position)
	Global.set_position_from_2d(pos_2d)
	Global.last_player_position.y = Global.last_player_position.y  # ou simplesmente não altere nada

func flip_h_direction() -> int:
	return -1 if animated_sprite_2d.flip_h else 1

func _physics_process(delta: float) -> void:
	# Adiciona gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not is_playing_magic_animation:
			animated_sprite_2d.play("jump")
	else:
		var direction := Input.get_axis("ui_left", "ui_right")
		if not is_playing_magic_animation:
			if direction != 0:
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("idle")

	# Pular
	#if Input.is_action_just_pressed("pulo") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("inventario"):
		inventário.visible = !inventário.visible

	if Input.is_action_just_pressed("magias"):
		magia.visible = !magia.visible
	# Movimento horizontal e virar sprite
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
