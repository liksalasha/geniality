extends AudioStreamPlayer2D

func _ready() -> void:
	if stream is AudioStreamWAV:
		var s = stream.duplicate() as AudioStreamWAV
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream = s
	play()
