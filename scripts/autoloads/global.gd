extends Node

# Constants
# Scenes
const SCENE_UIDS = {
	"GAME_CONTROLLER": "uid://cyangrc80ocx0",
	"MAIN_GAME": "uid://c3flgpg55d6cv",
	"MAIN_UI": "uid://c76kj4of14ajq",
	"UNIT": "uid://bl3bkx617qrac",
}

# Materials
const MATERIAL_UIDS = {
	"OUTLINE": "uid://bj6x4cma75nay",
	"PERSPECTIVE": "uid://cotdq4cdmntw8",
	"FLASH": "uid://c4id7ag22mv0v",
}

# Game Related
enum SUIT {
	BLUE,
	YELLOW,
	ORANGE,
	GREEN
}

# Game Signals
signal board_click(pos: Vector2i, suit: SUIT)

# Game Controller
var game_controller: GameController

# Settings
var music_step: int = 9
var sound_step: int = 9
