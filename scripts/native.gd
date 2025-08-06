extends Sprite2D

@onready var oh_native: Sprite2D = $CanvasLayer/OhNative
@onready var dialogue: Sprite2D = $CanvasLayer/Dialogue
@onready var label: Label = $CanvasLayer/Label
@onready var area_2d: Area2D = $Area2D
@export var reset_x := -50.0
@export var speed := 3500.0

var timer: Timer = null
var mover_nuvem := false
var ja_executou := false

func _ready() -> void:
	oh_native.visible = false
	dialogue.visible = false
	label.visible = false

func _process(delta: float) -> void:
	if mover_nuvem and oh_native:
		oh_native.position.x -= speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if ja_executou:
		return  # já fez tudo uma vez, não executa mais

	ja_executou = true  # marca que já passou por aqui

	if timer == null:
		timer = Timer.new()
		timer.wait_time = 0.5
		timer.one_shot = false
		timer.autostart = true
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
	else:
		timer.start()

	oh_native.visible = true
	mover_nuvem = true

func _on_timer_timeout():
	dialogue.visible = true
	label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if timer:
		timer.stop()

	mover_nuvem = false

	if dialogue:
		dialogue.queue_free()
		dialogue = null

	if label:
		label.queue_free()
		label = null

	if oh_native:
		oh_native.queue_free()
		oh_native = null
	
	area_2d.queue_free()
