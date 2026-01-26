@abstract class_name Controller
extends Node

@warning_ignore("unused_signal")
signal action_chosen(action: Action)

var _enabled: bool = false

@abstract func begin_turn(state: GameState) -> void

func set_enabled(enabled: bool) -> void:
	_enabled = enabled