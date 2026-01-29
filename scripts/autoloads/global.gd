extends Node

# Constants
# Scenes
const SCENE_UIDS = {
	"GAME_CONTROLLER": "uid://cyangrc80ocx0",
	"MAIN_MENU": "uid://dolritqgtceml",
	"CHARACTER_BUTTON": "uid://b1y8al5563q23",
	"MAIN_GAME": "uid://c3flgpg55d6cv",
	"MAIN_UI": "uid://c76kj4of14ajq",
	"UNIT": "uid://bl3bkx617qrac",
	"CARD": "uid://c83iru1766q8g",
	"HAZARD": "uid://bjgtss2iyo7hj",
	"WIN_SCREEN": "uid://cxex3ancqi3pm",
	"LOSE_SCREEN": "uid://c1rsrt4vnky1p",
}

# Materials
const MATERIAL_UIDS = {
	"OUTLINE": "uid://bj6x4cma75nay",
	"PERSPECTIVE": "uid://cotdq4cdmntw8",
	"FLASH": "uid://c4id7ag22mv0v",
}

# Textures
const TEXTURE_UUIDS = {
	"SUIT_BLUE": "uid://co2yelsyd2oej",
	"SUIT_YELLOW": "uid://cuj47no0incps",
	"SUIT_RED": "uid://c7q452thkmxmd",
	"SUIT_GREEN": "uid://dd2chgu8lyw3h",
	"ACTION_MOVE": "uid://s4qd1e4ir060",
	"ACTION_KNIFE": "uid://bn4kfjc01k5vy",
	"ACTION_GUN": "uid://da526bg7o763y",
	"ACTION_TELEPORT": "uid://cmicwqsjksohk",
	"ACTION_PUSH": "uid://dtma80hhc1ix4",
	"ACTION_TRAP": "uid://dm0fgdvp3c5g6",
	"ACTION_SHIELD": "uid://csy5kh80csek0",
	"ACTION_SEVEN": "uid://d2g4qwmi1tn6w",
}

# Theme
const THEME_UIDS = {
	"GENERAL": "uid://2ek7eagjo7f0",
	"WIN_BUTTON": "uid://cocl083sqn6ep",
	"WIN_HOVER": "uid://bk1tpqc5dew6o"
}

# Game Enums
enum Suit {
	BLUE,
	YELLOW,
	RED,
	GREEN
}

enum GroupType {
	PLAYER,
	ENEMY
}

# Save
const SAVE_LOCATION: String = "user://save_game.json"
const ENCRYPTION_PASSWORD: String = "WildJam89"

# Game Signals
@warning_ignore("unused_signal")
signal tile_selected(cell_pos: Vector2, suit: Suit)
@warning_ignore("unused_signal")
signal card_selected(card_index: int)
@warning_ignore("unused_signal")
signal shuffle_requested()
@warning_ignore("unused_signal")
signal skip_requested()
@warning_ignore("unused_signal")
signal game_state_changed(game_state: GameState, action: Action)
@warning_ignore("unused_signal")
signal turn_started(group: GroupState, unit: UnitState)
@warning_ignore("unused_signal")
signal turn_ended(group: GroupState, unit: UnitState)
@warning_ignore("unused_signal")
signal round_changed(round: int)

# Game Controller
var game_controller: GameController
var debug_panel: DebugPanel

# Game Settings
var music_step: int = 9
var sound_step: int = 9

# Game Variables
var selected_unit: UnitData # The unit selected by the player in the character selector
var game_state: GameState = GameState.new()
var character_wins: Dictionary[String, int] = {} # The number of wins for each character

# Load Game
func _ready() -> void:
	game_state_changed.connect(
		func(_g: GameState, _a: Action):
			save_game()
	)
	load_game()

# Input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var mode: int = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Save Game
func save_game() -> void:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.WRITE, ENCRYPTION_PASSWORD)
	if file:
		var save_data: Dictionary = {
			"settings": {
				"music_step": music_step,
				"sound_step": sound_step,
			},
			"character_wins": character_wins,
			"game_state": game_state.to_dict()
		}
		file.store_var(save_data)
		file.close()

# Load Game
func load_game() -> void:
	if FileAccess.file_exists(SAVE_LOCATION):
		var file: FileAccess = FileAccess.open_encrypted_with_pass(SAVE_LOCATION, FileAccess.READ, ENCRYPTION_PASSWORD)
		if file:
			var data = file.get_var()
			print(JSON.stringify(data, "  "))
			if typeof(data) == TYPE_DICTIONARY:
				music_step = data.get("music_step", music_step)
				sound_step = data.get("sound_step", sound_step)
				character_wins = data.get("character_wins", character_wins)
				game_state.from_dict(data.get("game_state", {}))
			file.close()
