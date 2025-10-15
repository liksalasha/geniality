extends Node

var save_path := "user://save_game.json"  # Use 'user://' para poder salvar de verdade no disco do jogador
var player_scene: PackedScene = load("res://mage/2d/mage.tscn")
var player: Node = player_scene.instantiate()

func save_game():
	if player == null:
		print("Jogador não foi referenciado no save.")
		return

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var data = {
		"inventory": Inventário.inventory,
		"magic": Magics.magics,
		"projectile_path": player.projectile_path,
		"magic_path": player.magic_path,
		"current_projectile_name": player.current_projectile_name,
		"current_magic_name": player.current_magic_name
	}
	file.store_string(JSON.stringify(data))

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		if result == OK:
			var data = json.data
			if data.has("inventory"):
				Inventário.inventory = data["inventory"]
			if data.has("magic"):
				Magics.magics = data["magic"]
			if player:
				if data.has("projectile_path"):
					player.projectile_path = data["projectile_path"]
					player.projectile_scene = load(player.projectile_path)

				if data.has("magic_path"):
					player.magic_path = data["magic_path"]
					player.magic_scene = load(player.magic_path)
				if data.has("current_projectile_name"):
					player.current_projectile_name = data["current_projectile_name"]

				if data.has("current_magic_name"):
					player.current_magic_name = data["current_magic_name"]

				if data.has("projectile_path"):
					player.set_projectile(data["current_projectile_name"], data["projectile_path"])

				if data.has("magic_path"):
					player.set_magic(data["current_magic_name"], data["magic_path"])

func set_player_reference(player_ref: Node) -> void:
	player = player_ref
