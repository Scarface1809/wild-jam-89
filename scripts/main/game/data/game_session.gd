extends RefCounted
class_name GameSession

enum Mode {NEW_GAME, CONTINUE}

var mode: Mode
var selected_unit: UnitData = null
var loaded_state: GameState = null
