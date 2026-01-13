extends Node

# Constants
# Scenes
const SCENE_UIDS = {
	"GAME_CONTROLLER": "uid://cyangrc80ocx0",
	"MAIN_GAME": "uid://c3flgpg55d6cv",
	"MAIN_UI": "uid://c76kj4of14ajq",
	"UNIT": "uid://bl3bkx617qrac",
	"CARD": "uid://c83iru1766q8g"
}

# Materials
const MATERIAL_UIDS = {
	"OUTLINE": "uid://bj6x4cma75nay",
	"PERSPECTIVE": "uid://cotdq4cdmntw8",
	"FLASH": "uid://c4id7ag22mv0v",
}

const TEXTURE_UUIDS = {
	"SUIT_BLUE": "uid://co2yelsyd2oej",
	"SUIT_YELLOW": "uid://cuj47no0incps",
	"SUIT_RED": "uid://c7q452thkmxmd",
	"SUIT_GREEN": "uid://dd2chgu8lyw3h",
	"ACTION_MOVE": "uid://s4qd1e4ir060",
	"ACTION_ATTACK": "uid://bn4kfjc01k5vy"
}

# Game Enums
enum SUIT {
	BLUE,
	YELLOW,
	RED,
	GREEN
}

enum GROUP_TYPE {
	PLAYER,
	ENEMY
}

enum ACTION_TYPE {
	MOVE,
	ATTACK
}

# Game Signals
@warning_ignore("unused_signal")
signal tile_clicked(cell_pos: Vector2, suit: SUIT)
@warning_ignore("unused_signal")
signal card_clicked(card_index: int)
@warning_ignore("unused_signal")
signal player_turn_started()
@warning_ignore("unused_signal")
signal player_turn_ended()
@warning_ignore("unused_signal")
signal game_state_changed(game_state: GameState)

# Game Controller
var game_controller: GameController

# Settings
var music_step: int = 9
var sound_step: int = 9
