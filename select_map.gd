extends CanvasLayer

var crystal_city = preload("res://maps/city/crystal city.tscn")
var fase2 = preload("res://maps/experiments/fase2.tscn")

func _on_utilities_experiments_pressed() -> void:
	get_tree().change_scene_to_packed(fase2)
func _on_crystal_city_pressed() -> void:
	get_tree().change_scene_to_packed(crystal_city)
