extends CharacterBody3D

const SPEED = 130
const JUMP_VELOCITY = 150
const GRAVITY = Vector3.DOWN * 200.0  # Mais forte que o padrão
const MOUSE_SENSITIVITY = 0.002
const ROTATION_LERP_SPEED = 8.0

var rotation_input_x := 0.0  # vertical (cima/baixo)
var rotation_input_y := 0.0  # horizontal (esquerda/direita)
var pos3d = Global.last_player_position
var is_playing_magic_animation: bool = false

@export var magic_scene: PackedScene
@export var projectile_scene: PackedScene  # arraste a cena do projétil no editor

@onready var pivot = $Pivot
@onready var camera: Camera3D = $Pivot/Camera3D  # ou $Pivot/CameraBoom/Camera3D
@onready var life_label: Label = $"../CanvasLayer/LifeLabel"
@onready var mana_label: Label = $"../CanvasLayer/mana label"
@onready var anim: AnimatedSprite3D = $anim
@onready var hurtarea: Area3D = $hurtarea
@onready var inventário: CanvasLayer = $"../inventário"
@onready var magia: CanvasLayer = $"../Magia"
@onready var control: CanvasLayer = $"../pause"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Carregando pos3D:", Global.last_player_position)
	global_position = Global.get_position_3d()
	anim.visible = false
	hurtarea.area_entered.connect(_on_area_entered)
	update_life_label()
	update_mana_label()
	
		# Timer automático a cada 2 segundos (ajuste como quiser)
	var timer = Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	inventário.visible = false
	magia.visible = false
	
func _on_timer_timeout():
	Global.set_position_from_3d(global_position)
	if Global.mana < Global.max_mana:
		update_mana_label()

func update_life_label():
	life_label.text = "Vida: %d" % Global.life

func update_mana_label():
	mana_label.text = "mana: %d" % Global.mana
	
func _on_area_entered(area):
	print("Colidiu com:", area)
	if area and area.is_in_group("LifeOrb"):
		Global.life += 1
		print("Pegou orb de vida:", Global.life)
		update_life_label()
	if area and area.is_in_group("ManaOrb"):
		Global.mana += 4
		print("Pegou orb de mana:", Global.mana)
		update_mana_label()
func respawn():
	pass
	#position = checkpoint_position
	
func _on_death():
	respawn() # Isso vai levar ele para o último checkpoint salvo


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotação do mouse
		rotation_input_y -= event.relative.x * MOUSE_SENSITIVITY
		rotation_input_x = clamp(rotation_input_x - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-40), deg_to_rad(40))

func _process(delta):
	# Suaviza rotação horizontal (Y) do corpo
	rotation.y = lerp_angle(rotation.y, rotation_input_y, delta * ROTATION_LERP_SPEED)
	
	# Suaviza rotação vertical (X) da câmera
	pivot.rotation.x = lerp_angle(pivot.rotation.x, rotation_input_x, delta * ROTATION_LERP_SPEED)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += GRAVITY * delta
	#if Input.is_action_just_pressed("ui_end"):
		#Global.last_player_position = Vector3(global_position.x, 0, global_position.z)
		
	if Input.is_action_just_pressed("shoot") and Global.mana >=1:
		shoot_projectile()

	if Input.is_action_just_pressed("magic") and Global.mana >=2 and not is_playing_magic_animation:
		#animated_sprite_2d.play("magic")
		is_playing_magic_animation = true
		
	if is_playing_magic_animation:
		velocity.x = 0
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "down", "up")
	
	# Movimenta na direção da câmera (ignora inclinação vertical)
	var cam_basis = pivot.global_transform.basis
	var cam_forward = -cam_basis.z
	var cam_right = cam_basis.x

	var direction = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
			 #Solta o mouse com ESC
	#if control.visible == true:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("ui_end"):
		inventário.visible = true
	if Input.is_action_just_pressed("ui_home"):
		inventário.visible = false
	if Input.is_action_just_pressed("ui_page_up"):
		magia.visible = true
	if Input.is_action_just_pressed("ui_page_down"):
		magia.visible = false
	
	move_and_slide()
func shoot_projectile():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		
		# Define direção e posição do projétil
		var dir: Vector3 = -camera.global_transform.basis.z  # Frente da câmera
		projectile.global_transform.origin = global_transform.origin + dir * 50.0  # Na frente do personagem

		# Define a direção se ela existir no script
		if "direction" in projectile:
			projectile.direction = dir

		Global.mana -= 1
		update_mana_label()

	
func magic():
	if magic_scene:
		var magic = magic_scene.instantiate()
		get_parent().add_child(magic)
		Global.mana -=3
		update_mana_label()
		# Define a posição do projétil na frente do player
		var dir: Vector2
		magic.direction = dir
		


func _on_area_3d_body_entered(body: Node3D) -> void:
	Global.life -= 1
	print("-hp")
	update_life_label()
	if Global.life == 0:
		_on_death()
		Global.life = 3
		Global.mana = 5
		update_life_label()
		update_mana_label()
		
func _on_hurtarea_body_entered(body: Node3D) -> void:
	Global.life -= 1
	print("-hp")
	update_life_label()
	if Global.life == 0:
		_on_death()
		Global.life = 3
		Global.mana = 5
		update_life_label()
		update_mana_label()

func _input(event):
	if event is InputEventJoypadButton:
		print("Botão pressionado: ", event.button_index, " | Controle ID: ", event.device, " | Nome: ", Input.get_joy_name(event.device))
