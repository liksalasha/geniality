extends Node2D

const G29_ID = 1
@export var next_scene_path: String
var scene_changed := false
@onready var change: AnimationPlayer = $player/change
@onready var cpu_particles_2d: CPUParticles2D = $player/change/CPUParticles2D

func _input(event):
	if scene_changed:
		return
	cpu_particles_2d.emitting = false
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
