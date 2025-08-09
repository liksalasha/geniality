extends CanvasLayer

@onready var player: CharacterBody2D = $"../../player"
@onready var control: CanvasLayer = $"."
@onready var resume: Button = $resume
@onready var scene_to_instance : PackedScene = load("res://ui_u/main menu.tscn")
@onready var cut_player: CharacterBody2D = $"../cut_player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	control.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		control.visible = true
		resume.grab_focus()
		get_tree().paused = true

	# Modo do mouse baseado em estado atual
	if control.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif player is CharacterBody2D and player.is_inside_tree():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif cut_player is CharacterBody2D and cut_player.is_inside_tree():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _on_resume_pressed() -> void:
	control.visible = false
	get_tree().paused = false

func _on_main_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(scene_to_instance)
	print("menu")
