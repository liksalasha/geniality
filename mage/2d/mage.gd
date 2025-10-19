extends CharacterBody2D

# === Nodes ===
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var anim: AnimatedSprite2D = $anim
@onready var hurtarea: Area2D = $hurtarea
@onready var life_label: Label = $"../CanvasLayer/LifeLabel"
@onready var mana_label: Label = $"../CanvasLayer/mana label"
@onready var inventário: CanvasLayer = $"../inventário"
@onready var magia: CanvasLayer = $"../Magia"
@onready var playercam2d: Camera2D = $Camera2D
@onready var camera_2d: Camera2D = $change/Camera2D

# === Exported Scenes ===
@export var projectile_scene: PackedScene
@export var magic_scene: PackedScene

# === Variables ===
var SPEED = 200.0
var checkpoint_position: Vector2
var can_teleport: bool = false
var teleport_target: Node2D = null
var is_playing_magic_animation: bool = false
var main_joypad_id := -1
var projectile_path: String = ""
var magic_path: String = ""
var current_projectile_name := ""
var current_magic_name := ""
var noclip := false
var state: PlayerState = PlayerState.IDLE
var is_dashing = false

const JUMP_VELOCITY = -500.0

# === Enums ===
enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	DASH,
	MAGIC
}

# === Ready ===
func _ready() -> void:
	raycast.enabled = true
	#raycast.target_position.x = flip_h_direction() * 300
	anim.visible = false
	hurtarea.area_entered.connect(_on_area_entered)

	update_life_label()
	update_mana_label()
	global_position = Global.get_position_2d()

	var timer = Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	inventário.visible = false
	magia.visible = false

	SaveManager.set_player_reference(self)
	SaveManager.load_game()

# === Timer ===
func _on_timer_timeout():
	Global.set_position_from_2d(global_position)
	Global.last_player_position.y = Global.last_player_position.y
	if Global.mana < Global.max_mana:
		update_mana_label()

# === UI Updates ===
func update_life_label():
	life_label.text = "Vida: %d" % Global.all_life

func update_mana_label():
	mana_label.text = "mana: %d" % Global.mana

# === Respawn & Death ===
func respawn():
	position = checkpoint_position

func _on_death():
	respawn()
	Global.all_life = Global.life
	Global.mana = 5
	update_life_label()
	update_mana_label()

# === Pickups ===
func _on_area_entered(area):
	if area.is_in_group("LifeOrb"):
		Global.all_life += 1
		update_life_label()
	elif area.is_in_group("ManaOrb"):
		Global.mana += 4
		update_mana_label()

# === Flip Direction ===
func flip_h_direction() -> int:
	return -1 if animated_sprite_2d.flip_h else 1

# === Projectiles & Magic ===
func shoot_projectile():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		Global.mana -= 1
		update_mana_label()

		var dir = Vector2.LEFT if animated_sprite_2d.flip_h else Vector2.RIGHT
		projectile.global_position = global_position + dir * 16
		projectile.direction = dir

func magic():
	if magic_scene:
		var magic = magic_scene.instantiate()
		get_parent().add_child(magic)
		Global.mana -= 3
		update_mana_label()

		var dir = Vector2.LEFT if animated_sprite_2d.flip_h else Vector2.RIGHT
		magic.global_position = global_position + dir * 16
		magic.direction = dir

# === Dash ===
func dash():
	if is_dashing:
		return

	is_dashing = true
	state = PlayerState.DASH
	animated_sprite_2d.play("dash", true)
	SPEED = 500

	var tempo = Timer.new()
	tempo.wait_time = 0.2
	tempo.one_shot = true
	tempo.timeout.connect(func ():
		is_dashing = false
		SPEED = 200
		state = PlayerState.IDLE
	)
	add_child(tempo)
	tempo.start()

func _on_tempo_timeout():
	SPEED = 200

# === Physics Process ===
func _physics_process(delta: float) -> void:
	match state:
		PlayerState.IDLE:
			animated_sprite_2d.play("idle")
		PlayerState.RUN:
			animated_sprite_2d.play("run")
		PlayerState.JUMP:
			animated_sprite_2d.play("jump")
		PlayerState.DASH:
			animated_sprite_2d.play("dash")
		PlayerState.MAGIC:
			animated_sprite_2d.play("magic")

	# Noclip
	if Input.is_action_just_pressed("no") and Input.is_action_just_pressed("clip"):
		noclip = !noclip
		$CollisionShape2D.disabled = noclip
		print("No clip´ativado")

	if noclip:
		velocity -= get_gravity() * delta
		var dir = Vector2.ZERO
		if Input.is_action_pressed("ui_up"): dir.y -= 1
		if Input.is_action_pressed("ui_down"): dir.y += 1
		if Input.is_action_pressed("ui_left"): dir.x -= 1
		if Input.is_action_pressed("ui_right"): dir.x += 1
		global_position += dir.normalized() * SPEED * delta

	# Dash
	if Input.is_action_just_pressed("dash"):
		dash()

	# Level up
	if Global.xp >= Global.necessary_xp:
		Global._on_level_up()

	# Shoot
	if Input.is_action_just_pressed("shoot") and Global.mana >= 1:
		shoot_projectile()

	# Magic
	if Input.is_action_just_pressed("magic") and Global.mana >= 3 and not is_playing_magic_animation:
		is_playing_magic_animation = true
		state = PlayerState.MAGIC
	
	if is_playing_magic_animation:
		velocity.x = 0
		move_and_slide()
		return

	# Raycast direction
	raycast.target_position.x = flip_h_direction() * 300

	# Teleport detection
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		if obj and obj.is_in_group("teleportable"):
			can_teleport = true
			teleport_target = obj
		else:
			can_teleport = false
			teleport_target = null
	else:
		can_teleport = false
		teleport_target = null

	# Teleport
	if Input.is_action_just_pressed("interact") and can_teleport and teleport_target:
		position = teleport_target.global_position

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not is_playing_magic_animation and not is_dashing:
			state = PlayerState.JUMP
	else:
		var direction := Input.get_axis("left", "right")
		if not is_dashing and not is_playing_magic_animation:
			if direction != 0:
				state = PlayerState.RUN
			else:
				state = PlayerState.IDLE

	# Jump
	if Input.is_action_just_pressed("pulo") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state = PlayerState.JUMP

	# Move & flip
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Inventário & Magia menu
	if Input.is_action_just_pressed("inventario"):
		inventário.visible = !inventário.visible

	if Input.is_action_just_pressed("magias"):
		magia.visible = !magia.visible

	# Teleport raycast anim
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		anim.play("default")
		if obj and obj.is_in_group("teleportable"):
			can_teleport = true
			teleport_target = obj
			anim.visible = true
		else:
			can_teleport = false
			teleport_target = null
			anim.visible = false
	else:
		can_teleport = false
		teleport_target = null
		anim.visible = false

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Camera change
	if Input.is_action_just_pressed("change"):
		camera_2d.make_current()
		var time = Timer.new()
		time.wait_time = 4
		time.one_shot = false
		time.autostart = true
		time.timeout.connect(_on_time_timeout)
		add_child(time)

	move_and_slide()

# === Camera ===
func _on_time_timeout():
	playercam2d.make_current()

# === Damage & Death ===
func _on_hurtarea_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Enemys"):
		Global.all_life -= 1
		update_life_label()
		flash_red()

	if Global.all_life == 0:
		_on_death()

func flash_red() -> void:
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)

# === Inputs ===
func _input(event):
	if event is InputEventJoypadButton:
		print("Botão pressionado: ", event.button_index, " | Controle ID: ", event.device, " | Nome: ", Input.get_joy_name(event.device))

# === Magic Selection ===
func _on_ice_projectile_pressed() -> void:
	set_projectile("ice_pro", "res://blueprints/enemys/Ice Projectile.tscn")
	Magics.add_item("ice_pro", 1)

func _on_fire_projectile_pressed() -> void:
	set_projectile("fire_pro", "res://blueprints/enemys/Projectile.tscn")
	Magics.add_item("fire_pro", 1)

func _on_ice_magic_pressed() -> void:
	set_magic("ice_ma", "res://blueprints/enemys/Ice magic.tscn")
	Magics.add_item("ice_ma", 1)

func _on_fire_magic_pressed() -> void:
	set_magic("fire_ma", "res://blueprints/enemys/magic.tscn")
	Magics.add_item("fire_ma", 1)

func set_projectile(name: String, path: String) -> void:
	projectile_path = path
	projectile_scene = load(path)
	current_projectile_name = name

func set_magic(name: String, path: String) -> void:
	magic_path = path
	magic_scene = load(path)
	current_magic_name = name

# === Rope & Out of Bounds ===
func _on_rope_body_entered(_body: Node2D) -> void:
	velocity -= get_gravity() * 0.2

func _on_out_body_entered(_body: Node2D) -> void:
	_on_death()

# === Animation Finished ===
func _on_animated_sprite_2d_animation_finished():
	print("Animação finalizada:", animated_sprite_2d.animation)
	if animated_sprite_2d.animation == "magic":
		magic()
		is_playing_magic_animation = false
		state = PlayerState.IDLE
		SPEED = 200
	elif animated_sprite_2d.animation == "dash":
		state = PlayerState.IDLE
