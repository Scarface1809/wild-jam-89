extends Node

# Constants
const SAVE_LOCATION: String = "user://save_game.json"
const ENCRYPTION_PASSWORD: String = "WildJam89"

# Persistent Data
var music_step: int = 9
var sound_step: int = 9
var character_wins: Dictionary[String, int] = {} # The number of wins for each character

func _ready() -> void:
	load_global_data()

func save_global_data() -> void:
	var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.WRITE, ENCRYPTION_PASSWORD)
	if file:
		var save_data = {
			"settings": {
				"music_step": music_step,
				"sound_step": sound_step
			},
			"character_wins": character_wins
		}
		file.store_var(save_data)
		file.close()

func load_global_data() -> void:
	if FileAccess.file_exists(SAVE_LOCATION):
		var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.READ, ENCRYPTION_PASSWORD)
		if file:
			var data = file.get_var()
			file.close()
			if typeof(data) == TYPE_DICTIONARY:
				print(JSON.stringify(data, "  "))
				music_step = data.get("settings", {}).get("music_step", music_step)
				sound_step = data.get("settings", {}).get("sound_step", sound_step)
				character_wins = data.get("character_wins", character_wins)

func save_game_state(game_state: GameState) -> void:
	var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.WRITE, ENCRYPTION_PASSWORD)
	if file:
		# Load current global data first
		var save_data = {
			"settings": {
				"music_step": music_step,
				"sound_step": sound_step
			},
			"character_wins": character_wins,
			"game_state": game_state.to_dict()
		}
		file.store_var(save_data)
		file.close()

func load_game_state() -> GameState:
	if FileAccess.file_exists(SAVE_LOCATION):
		var file = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.READ, ENCRYPTION_PASSWORD)
		if file:
			var data = file.get_var()
			file.close()
			var gs_data = data.get("game_state", {})
			if gs_data:
				var gs = GameState.new()
				gs.from_dict(gs_data)
				return gs
	return null

func has_saved_game() -> bool:
	if not FileAccess.file_exists(SAVE_LOCATION):
		return false

	var file = FileAccess.open_encrypted_with_pass(
		SAVE_LOCATION,
		FileAccess.READ,
		ENCRYPTION_PASSWORD
	)
	if not file:
		return false

	var data = file.get_var()
	file.close()

	return typeof(data) == TYPE_DICTIONARY and data.has("game_state")
