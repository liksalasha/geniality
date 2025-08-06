extends Area2D

@onready var label: Label = $CanvasLayer/Label
@onready var dialogue: Sprite2D = $CanvasLayer/Dialogue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	dialogue.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	label.visible = true
	dialogue.visible = true

func _on_body_exited(body: Node2D) -> void:
	label.visible = false
	dialogue.visible = false
