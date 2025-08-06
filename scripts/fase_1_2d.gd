extends Node2D

@export var scene_to_instance : PackedScene
const G29_ID = 1  # suponha que o G29 seja o device 1

func _ready():
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change"):
		get_tree().change_scene_to_packed(scene_to_instance)
		print("Cena trocada")
	# Salva a posição 2D como Vector3 (Z = 0)
	
func _input(event):
	if event is InputEventJoypadButton and event.device != G29_ID:
		# Processa apenas botões do controle Xbox
		pass
