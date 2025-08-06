extends MeshInstance3D

@onready var dialogue: Sprite2D = $CanvasLayer/Dialogue
@onready var label: Label = $CanvasLayer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.visible = false
	label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += deg_to_rad(30) * delta  # gira 30 graus por segundo


func _on_area_3d_body_entered(body: Node3D) -> void:
	dialogue.visible = true
	label.visible = true
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	dialogue.visible = false
	label.visible = false
