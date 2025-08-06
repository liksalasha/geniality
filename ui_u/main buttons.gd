extends CanvasLayer

@onready var animated_sprite_2d: AnimatedSprite2D = $ng/AnimatedSprite2D
@onready var cont: AnimatedSprite2D = $continue/cont
@onready var cred: AnimatedSprite2D = $credits/cred
@onready var ex: AnimatedSprite2D = $exit/ex
@onready var scene_to_instance: PackedScene = load("res://castle.tscn")
@onready var ng: Button = $ng
@onready var conti: Button = $continue
@onready var credits: Button = $credits
@onready var exit: Button = $exit

var pos_ng: Vector2
var pos_cont: Vector2
var pos_cred: Vector2
var pos_exit: Vector2

func _ready() -> void:
	pos_ng = ng.position
	pos_cont = conti.position
	pos_cred = credits.position
	pos_exit = exit.position
	
	animated_sprite_2d.visible = false
	cont.visible = false
	cred.visible = false
	ex.visible = false

# Novo Jogo
func _on_ng_mouse_entered() -> void:
	animated_sprite_2d.visible = true
	var tween = create_tween()
	tween.tween_property(ng, "position", pos_ng + Vector2(10, 0), 0.15)

func _on_ng_mouse_exited() -> void:
	animated_sprite_2d.visible = false
	var tween = create_tween()
	tween.tween_property(ng, "position", pos_ng, 0.15)

func _on_ng_pressed() -> void:
	get_tree().change_scene_to_packed(scene_to_instance)
	print("iniciou")

# Continuar
func _on_continue_mouse_entered() -> void:
	cont.visible = true
	var tween = create_tween()
	tween.tween_property(conti, "position", pos_cont + Vector2(10, 0), 0.15)

func _on_continue_mouse_exited() -> void:
	cont.visible = false
	var tween = create_tween()
	tween.tween_property(conti, "position", pos_cont, 0.15)

# Créditos
func _on_credits_mouse_entered() -> void:
	cred.visible = true
	var tween = create_tween()
	tween.tween_property(credits, "position", pos_cred + Vector2(10, 0), 0.15)

func _on_credits_mouse_exited() -> void:
	cred.visible = false
	var tween = create_tween()
	tween.tween_property(credits, "position", pos_cred, 0.15)

# Sair
func _on_exit_mouse_entered() -> void:
	ex.visible = true
	var tween = create_tween()
	tween.tween_property(exit, "position", pos_exit + Vector2(10, 0), 0.15)

func _on_exit_mouse_exited() -> void:
	ex.visible = false
	var tween = create_tween()
	tween.tween_property(exit, "position", pos_exit, 0.15)

func _on_exit_pressed() -> void:
	get_tree().quit()
