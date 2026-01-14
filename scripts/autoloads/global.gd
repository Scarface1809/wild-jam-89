extends Node

# Constants
# Scenes
const SCENE_UIDS = {
	"GAME_CONTROLLER": "uid://cyangrc80ocx0",
	"MAIN_GAME": "uid://c3flgpg55d6cv",
	"MAIN_UI": "uid://c76kj4of14ajq",
	"UNIT": "uid://bl3bkx617qrac",
	"CARD": "uid://c83iru1766q8g",
	"HAZARD": "uid://bjgtss2iyo7hj"
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
	"ACTION_KNIFE": "uid://bn4kfjc01k5vy",
	"ACTION_GUN": "uid://da526bg7o763y",
	"ACTION_TELEPORT": "uid://cmicwqsjksohk",
	"ACTION_PUSH": "uid://dtma80hhc1ix4",
	"ACTION_TRAP": "uid://dm0fgdvp3c5g6",
	"ACTION_SHIELD": "uid://csy5kh80csek0",
	"ACTION_SEVEN": "uid://d2g4qwmi1tn6w",
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
	GUN,
	KNIFE,
	TELEPORT,
	PUSH,
	TRAP,
	SHIELD,
	SEVEN,
	DRAW,
	RESHUFFLE
}

# Game Signals
@warning_ignore("unused_signal")
signal tile_clicked(cell_pos: Vector2, suit: SUIT)
@warning_ignore("unused_signal")
signal card_clicked(card_index: int)
@warning_ignore("unused_signal")
signal shuffle_request()
@warning_ignore("unused_signal")
signal player_turn_started()
@warning_ignore("unused_signal")
signal player_turn_ended()
@warning_ignore("unused_signal")
signal game_state_changed(game_state: GameState, action: Action)


# Game Controller
var game_controller: GameController

# Settings
var music_step: int = 9
var sound_step: int = 9
