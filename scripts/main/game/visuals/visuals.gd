class_name Visuals
extends Node2D

signal animations_finished

@onready var _board: Board = %Board
@onready var _board_highlights: BoardHighlights = %BoardHighlights
@onready var _units_container: UnitsContainer = %UnitsContainer
@onready var _hazards_container: HazardsContainer = %HazardsContainer
@onready var _seats: Seats = %Seats

var _is_animating: bool = false

func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)

func sync_with_state(state: GameState, action: Action) -> void:
	_is_animating = true

	_board.sync_with_state(state, action)
	_board_highlights.sync_with_state(state, action)
	await _hazards_container.sync_with_state(state, action)
	await _units_container.sync_with_state(state, action)
	_seats.sync_with_state(state, action) # TODO

	_is_animating = false
	animations_finished.emit()
