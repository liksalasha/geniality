extends Node

var last_player_position: Vector3 = Vector3.ZERO  # Guarda a posição padrão no formato 3D

#player
var all_life = 0
var life = 3
var mana = 5
var max_mana: int = 10  # limite de mana
var defence = 0
var damage = 1
var super_damage = 3
var xp = 0
var necessary_xp = 100

var defeated_enemies := []
var next_scene: PackedScene = null

func _on_level_up():
	life += 1
	defence += 5
	damage += 1
	necessary_xp += 100
	super_damage += 1
# Salva posição do 2D para o formato 3D
func set_position_from_2d(pos_2d: Vector2):
	last_player_position.x = pos_2d.x
	last_player_position.y = -pos_2d.y  # Inverte o Y aqui
	last_player_position.z = 0

# Converte para 2D (desinverte o Y)
func get_position_2d() -> Vector2:
	return Vector2(last_player_position.x, -last_player_position.y)

# Se quiser manter o Y real do personagem 3D:
func get_position_3d() -> Vector3:
	return last_player_position

func set_position_from_3d(pos_3d: Vector3):
	last_player_position = pos_3d

func _ready():
	# Timer automático a cada 2 segundos (ajuste como quiser)
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	all_life = life + defence
func _on_timer_timeout():
	if mana < max_mana:
		mana += 1
		print("Mana regenerada:", mana)

func on_enemy_defeated(enemy_id: String):
	if enemy_id not in Global.defeated_enemies:
		Global.defeated_enemies.append(enemy_id)
