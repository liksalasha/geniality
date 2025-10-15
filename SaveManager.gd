extends Node

var save_path := "user://save_game.json"
var player_scene: PackedScene = load("res://mage/2d/mage.tscn")
var player: Node = player_scene.instantiate()

func save_game():
	if player == null:
		print("⚠ Jogador não foi referenciado no save.")
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
	print("💾 Jogo salvo com sucesso em:", save_path)


func load_game():
	if not FileAccess.file_exists(save_path):
		print("⚠ Nenhum arquivo de save encontrado.")
		return

	var file = FileAccess.open(save_path, FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	if result != OK:
		print("❌ Erro ao carregar JSON de save.")
		return

	var data = json.data
	if data.has("inventory"):
		Inventário.inventory = data["inventory"]
	if data.has("magic"):
		Magics.magics = data["magic"]

	if player:
		# ───────────────────────────────────────────────
		# Carrega projéteis e magias apenas se o caminho for válido
		# ───────────────────────────────────────────────
		if data.has("projectile_path") and data["projectile_path"] != "" and data["projectile_path"] != "res://":
			player.projectile_path = data["projectile_path"]
			player.projectile_scene = load(player.projectile_path)
			if data.has("current_projectile_name"):
				player.current_projectile_name = data["current_projectile_name"]
				player.set_projectile(player.current_projectile_name, player.projectile_path)
		else:
			print("⚠ Caminho de projétil vazio, ignorando.")

		if data.has("magic_path") and data["magic_path"] != "" and data["magic_path"] != "res://":
			player.magic_path = data["magic_path"]
			player.magic_scene = load(player.magic_path)
			if data.has("current_magic_name"):
				player.current_magic_name = data["current_magic_name"]
				player.set_magic(player.current_magic_name, player.magic_path)
		else:
			print("⚠ Caminho de magia vazio, ignorando.")

func set_player_reference(player_ref: Node) -> void:
	player = player_ref
	print("🎮 Player referenciado no SaveManager:", player_ref.name)
