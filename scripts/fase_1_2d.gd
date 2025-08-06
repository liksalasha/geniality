extends Node2D

const G29_ID = 1  # suponha que o G29 seja o device 1
@export var next_scene_path: String

func _input(event):
	if event.is_action_pressed("change") and next_scene_path != "":
		var next_scene = load(next_scene_path)
		if next_scene:
			get_tree().change_scene_to_packed(next_scene)
	if event is InputEventJoypadButton and event.device != G29_ID:
		# Processa apenas botões do controle Xbox
		pass
	
