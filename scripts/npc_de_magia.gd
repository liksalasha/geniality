extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var loja_de_magia: CanvasLayer = $"loja de magia"
var player_na_area: bool = false
@onready var intrar: Label = $intrar

func _ready() -> void:
	loja_de_magia.visible = false
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	intrar.visible = false
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		player_na_area = true
		intrar.visible = true
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_na_area = false
		intrar.visible = false
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_na_area:
		print("entrou")
		loja_de_magia.visible = true
		intrar.visible = false
	if not player_na_area:
		loja_de_magia.visible = false
