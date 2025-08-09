extends Node2D

const G29_ID = 1
@export var next_scene_path: String
var scene_changed := false

func _input(event):
	if scene_changed:
		return

	if event.is_action_pressed("change") and next_scene_path != "":
		scene_changed = true  # evita loop
		call_deferred("_change_scene")

	if event is InputEventJoypadButton and event.device != G29_ID:
		pass

func _change_scene():
	var next_scene = load(next_scene_path)
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
