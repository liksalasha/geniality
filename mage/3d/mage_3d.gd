extends CharacterBody3D

# === Constantes ===
const DASH_SPEED = 400
const DASH_TIME = 0.2  # segundos
const DASH_COOLDOWN = 1.0  # segundos
const SPEED = 130
const JUMP_VELOCITY = 150
const GRAVITY = Vector3.DOWN * 200.0
const MOUSE_SENSITIVITY = 0.002
const ROTATION_LERP_SPEED = 8.0

# === Variáveis ===
var rotation_input_x := 0.0
var rotation_input_y := 0.0
var is_playing_magic_animation: bool = false
var is_dashing: bool = false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction: Vector3 = Vector3.ZERO

# === Exportados ===
@export var magic_scene: PackedScene
@export var projectile_scene: PackedScene

# === Nodes ===
@onready var pivot = $Pivot
@onready var camera: Camera3D = $Pivot/Camera3D
@onready var life_label: Label = $"../CanvasLayer/LifeLabel"
@onready var mana_label: Label = $"../CanvasLayer/mana label"
@onready var anim: AnimatedSprite3D = $anim
@onready var hurtarea: Area3D = $hurtarea
@onready var inventário: CanvasLayer = $"../inventário"
@onready var magia: CanvasLayer = $"../Magia"
@onready var control: CanvasLayer = $"../pause"
@onready var camera_3d: Camera3D = $change/Camera3D
@onready var playercam3ed: Camera3D = $Pivot/Camera3D

# === Ready ===
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	global_position = Global.get_position_3d()
	anim.visible = false
	update_life_label()
	update_mana_label()

	var timer = Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	inventário.visible = false
	magia.visible = false

# === Timer ===
func _on_timer_timeout():
	Global.set_position_from_3d(global_position)
	if Global.mana < Global.max_mana:
		update_mana_label()

# === Labels ===
func update_life_label():
	life_label.text = "Vida: %d" % Global.all_life

func update_mana_label():
	mana_label.text = "mana: %d" % Global.mana

# === Morte ===
func _on_death():
	Global.life = 3
	Global.mana = 5
	update_life_label()
	update_mana_label()
	respawn()

func respawn():
	global_position = Global.get_position_3d()

# === Input do Mouse ===
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_input_y -= event.relative.x * MOUSE_SENSITIVITY
		rotation_input_x = clamp(rotation_input_x - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-40), deg_to_rad(40))

func _process(delta):
	# Leitura do analógico direito
	var look_x := Input.get_action_strength("look_right") - Input.get_action_strength("look_left") # só se quiser esquerda-direita analógico
	var look_y := Input.get_action_strength("look_down") - Input.get_action_strength("look_up") # se tiver ações

	# Melhor mesmo é pegar diretamente os eixos do joystick (mais preciso):
	# Aqui exemplo com o primeiro joystick (ID 0)
	var joy_id = 0
	var axis_right_x = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X) # eixo horizontal do analógico direito
	var axis_right_y = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y) # eixo vertical do analógico direito

	# Ajusta a rotação da câmera com o joystick
	rotation_input_y -= axis_right_x * MOUSE_SENSITIVITY * 15 # multiplicador para ficar legal
	rotation_input_x = clamp(rotation_input_x - axis_right_y * MOUSE_SENSITIVITY * 15, deg_to_rad(-40), deg_to_rad(40))

	# Aplica suavização da rotação
	rotation.y = lerp_angle(rotation.y, rotation_input_y, delta * ROTATION_LERP_SPEED)
	pivot.rotation.x = lerp_angle(pivot.rotation.x, rotation_input_x, delta * ROTATION_LERP_SPEED)

# === Física ===
func _physics_process(delta: float) -> void:
	# Cooldown do dash
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Início do dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		var input_dir := Input.get_vector("left", "right", "down", "up")
		var cam_basis = pivot.global_transform.basis
		var cam_forward = -cam_basis.z
		var cam_right = cam_basis.x
		dash_direction = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()

		if dash_direction != Vector3.ZERO:
			is_dashing = true
			dash_timer = DASH_TIME
			dash_cooldown_timer = DASH_COOLDOWN

	# Se estiver dashando, executa o dash
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		if dash_timer <= 0:
			is_dashing = false
	else:
		# Aplica gravidade
		if not is_on_floor():
			velocity += GRAVITY * delta

		# Atira projétil
		if Input.is_action_just_pressed("shoot") and Global.mana >= 1:
			shoot_projectile()

		# Animação de magia
		if Input.is_action_just_pressed("magic") and Global.mana >= 3 and not is_playing_magic_animation:
			is_playing_magic_animation = true
			anim.play("magic")

		if is_playing_magic_animation:
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			return

		# Pulo
		if Input.is_action_just_pressed("pulo") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Movimento normal
		var input_dir := Input.get_vector("left", "right", "down", "up")
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

		# Menus e câmera
		if Input.is_action_just_pressed("inventario"):
			inventário.visible = !inventário.visible

		if Input.is_action_just_pressed("magias"):
			magia.visible = !magia.visible

		if Input.is_action_just_pressed("change"):
			camera_3d.current = true
			playercam3ed.current = false
			var time = Timer.new()
			time.wait_time = 4
			time.one_shot = true
			time.timeout.connect(_on_time_timeout)
			add_child(time)
			time.start()

		move_and_slide()


func _on_time_timeout():
	camera_3d.current = false
	playercam3ed.current = true

# === Magia & Projétil ===
func shoot_projectile():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)

		var dir: Vector3 = -camera.global_transform.basis.z
		projectile.global_transform.origin = global_transform.origin + dir * 2.0

		if "direction" in projectile:
			projectile.direction = dir

		Global.mana -= 1
		update_mana_label()

func magic():
	if magic_scene:
		var magic = magic_scene.instantiate()
		get_parent().add_child(magic)

		var dir: Vector3 = -camera.global_transform.basis.z
		magic.global_transform.origin = global_transform.origin + dir * 2.0

		if "direction" in magic:
			magic.direction = dir

		Global.mana -= 3
		update_mana_label()

# === Animação Finalizada ===
func _on_anim_animation_finished():
	if anim.animation == "magic":
		magic()
		is_playing_magic_animation = false

func _on_itens_area_entered(area: Area3D) -> void:
	if area.is_in_group("LifeOrb"):
		Global.all_life += 1
		update_life_label()
	if area.is_in_group("ManaOrb"):
		Global.mana += 4
		update_mana_label()

func _on_hurtarea_body_entered(body: Node3D) -> void:
	print("E body o inimimimim")
	if body.is_in_group("Enemys"):
		print("Dano recebido de:", body.name)
		Global.all_life -= 1
		update_life_label()

	if Global.all_life == 0:
		_on_death()
