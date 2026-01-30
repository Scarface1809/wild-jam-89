class_name RoundDisplay
extends Label

func _ready():
	Global.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(_game_state: GameState, _action: Action):
	text = "round " + str(_game_state.get_current_round() + 1) + "/5"
