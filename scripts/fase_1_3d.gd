extends Node3D

const G29_ID = 1
@export var next_scene_path: String
var scene_changed := false
@onready var change: AnimationPlayer = $player3d/change
@export var tilemap_2d: TileMap
@export var block_scene: PackedScene  # cena de um bloco 3D (ex: cubo com textura)

func _ready():
	var cell_size = tilemap_2d.tile_set.tile_size

	for cell in tilemap_2d.get_used_cells(0):
		var block = block_scene.instantiate()
		var pos_2d = tilemap_2d.map_to_local(cell)

		# Corrige o espelhamento vertical
		block.position = Vector3(pos_2d.x, -pos_2d.y + 16, 0)
		block.rotation_degrees = Vector3(0, 0, 0)
		
		add_child(block)


func _input(event):
	if scene_changed:
		return

	if event.is_action_pressed("change") and next_scene_path != "":
		change.play("change")
	if event is InputEventJoypadButton and event.device != G29_ID:
		pass

func _change_scene():
	var next_scene = load(next_scene_path)
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)

func _on_change_animation_finished(change) -> void:
	scene_changed = true  # evita loop
	call_deferred("_change_scene")
