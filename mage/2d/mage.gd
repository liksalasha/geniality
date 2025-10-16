extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var anim: AnimatedSprite2D = $anim
@export var projectile_scene: PackedScene  # arraste a cena do projétil no editor
@onready var hurtarea: Area2D = $hurtarea
@export var magic_scene: PackedScene
@onready var life_label: Label = $"../CanvasLayer/LifeLabel"
@onready var mana_label: Label = $"../CanvasLayer/mana label"
@onready var inventário: CanvasLayer = $"../inventário"
@onready var magia: CanvasLayer = $"../Magia"
@onready var playercam2d: Camera2D = $Camera2D
@onready var camera_2d: Camera2D = $change/Camera2D

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


const JUMP_VELOCITY = -500.0

func _ready() -> void:
	raycast.enabled = true
	raycast.target_position.x = flip_h_direction() * 160
	print("Raycast ativado!")
	anim.visible = false
	hurtarea.area_entered.connect(_on_area_entered)
	update_life_label()
	update_mana_label()
	global_position = Global.get_position_2d()
	# Timer automático a cada 2 segundos (ajuste como quiser)
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
	modulate.a
	print(SaveManager)
	print(SaveManager.has_method("set_player_reference"))
func _on_timer_timeout():
	var pos_2d = global_position
	#print("Salvando pos2D:", global_position)
	Global.set_position_from_2d(pos_2d)
	Global.last_player_position.y = Global.last_player_position.y  # ou simplesmente não altere nada
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
	position = checkpoint_position
	
func _on_death():
	respawn() # Isso vai levar ele para o último checkpoint salvo

func flip_h_direction() -> int:
	return -1 if animated_sprite_2d.flip_h else 1

func shoot_projectile():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		Global.mana -= 1
		update_mana_label()
		# Define a posição do projétil na frente do player
		var dir: Vector2
		if animated_sprite_2d.flip_h:
			dir = Vector2.LEFT
		else:
			dir = Vector2.RIGHT
		projectile.global_position = global_position + dir * 16
		projectile.direction = dir
	
func magic():
	if magic_scene:
		var magic = magic_scene.instantiate()
		get_parent().add_child(magic)
		Global.mana -=3
		update_mana_label()
		# Define a posição do projétil na frente do player
		var dir: Vector2
		if animated_sprite_2d.flip_h:
			dir = Vector2.LEFT
		else:
			dir = Vector2.RIGHT
		magic.global_position = global_position + dir * 16
		magic.direction = dir
		
func _physics_process(delta: float) -> void:
	
	if Global.xp >= Global.necessary_xp:
		Global._on_level_up()
	
	#if Input.is_action_just_pressed("ui_end"):
		## Salva a posição 2D como Vector3 (Z = 0)
		#Global.last_player_position = Vector3(global_position.x, global_position.y, 0)
	
	if Input.is_action_just_pressed("shoot") and Global.mana >=1:
		shoot_projectile()
		
	if Input.is_action_just_pressed("magic") and Global.mana >=3 and not is_playing_magic_animation:
		animated_sprite_2d.play("magic")
		is_playing_magic_animation = true
		
	if is_playing_magic_animation:
		velocity.x = 0
		move_and_slide()
		return
		
		# Atualiza o RayCast pra seguir a direção do personagem
# Atualiza direção do RayCast (pra onde o player está virado)
	raycast.target_position.x = flip_h_direction() * 160

	# Detecta objeto teleportável
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

	# Teleporta se estiver olhando e apertar a tecla
	if Input.is_action_just_pressed("interact") and can_teleport and teleport_target:
		position = teleport_target.global_position
		print("Teleportado para: ", teleport_target.name)

	# Adiciona gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not is_playing_magic_animation:
			animated_sprite_2d.play("jump")
	else:
		var direction := Input.get_axis("left", "right")
		if not is_playing_magic_animation:
			if direction != 0:
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("idle")

	# Pular
	if Input.is_action_just_pressed("pulo") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento horizontal e virar sprite
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("inventario"):
		inventário.visible = !inventário.visible

	if Input.is_action_just_pressed("magias"):
		magia.visible = !magia.visible
	#_______________________________________________________
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		#print("Raycast colidiu com:", obj.name)
		anim.play("default")
		if obj and obj.is_in_group("teleportable"):
			print("Objeto teleportável detectado:", obj.name)
			can_teleport = true
			teleport_target = obj
			anim.visible = true
		else:
			can_teleport = false
			teleport_target = null
			anim.visible = false
	else:
		#print("Raycast não colidiu com nada")
		can_teleport = false
		teleport_target = null
		anim.visible = false
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#_________________________________________________
	if Input.is_action_just_pressed("change"):
		camera_2d.make_current()
		var time = Timer.new()
		time.wait_time = 4
		time.one_shot = false
		time.autostart = true
		time.timeout.connect(_on_time_timeout)
		add_child(time)
	
	move_and_slide()
	
func _on_time_timeout():
		playercam2d.make_current()
func _on_hurtarea_body_entered(_body: Node2D) -> void:
	modulate.r
	Global.all_life -= 1
	print("-hp")
	print(Global.all_life)
	update_life_label()
	if Global.all_life == 0:
		_on_death()
		Global.all_life = Global.life
		Global.mana = 5
		update_life_label()
		update_mana_label()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "magic":
		magic()
		is_playing_magic_animation = false
		SPEED = 200

func _input(event):
	if event is InputEventJoypadButton:
		print("Botão pressionado: ", event.button_index, " | Controle ID: ", event.device, " | Nome: ", Input.get_joy_name(event.device))

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


func _on_rope_body_entered(_body: Node2D) -> void:
	#if Input.is_action_pressed("down"):
		velocity -= get_gravity() * .2


func _on_out_body_entered(_body: Node2D) -> void:
	_on_death()
