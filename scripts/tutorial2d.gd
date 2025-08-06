extends Area2D

@onready var dialogue: Sprite2D = $CanvasLayer/Dialogue
@onready var label: Label = $CanvasLayer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.visible = false
	label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	dialogue.visible = true
	label.visible = true


func _on_body_exited(body: Node2D) -> void:
	dialogue.visible = false
	label.visible = false
