extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var letter: Sprite2D = $Letter
@onready var guarda: Sprite2D = $guarda
@onready var dialogue: Sprite2D = $Dialogue

func _ready() -> void:
	animation_player.play("parte 1")

func _on_x_pressed() -> void:
	letter.visible = false
	guarda.visible = false
	dialogue.visible = false
