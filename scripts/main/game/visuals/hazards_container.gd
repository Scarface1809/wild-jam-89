class_name HazardsContainer
extends Node2D
## Owns all Hazard visuals in the game

# Constants
const HAZARD_SCENE: PackedScene = preload(Global.SCENE_UIDS.HAZARD)

# Export
@export var board: Board

# Private
var _hazards: Dictionary[int, Hazard] = {}

func _ready() -> void:
	assert(board != null, "Board reference is required")

## Sync hazard visuals with GameState
func sync_with_state(state: GameState, action: Action) -> void:
	var signal_group = SignalGroup.new()
	var animation_signals: Array[Signal] = []

	var state_ids := []
	for hazard_state in state.get_hazards():
		state_ids.append(hazard_state.id)

	# Remove visuals for deleted hazards
	for id in _hazards.keys():
		if not state_ids.has(id):
			_hazards[id].queue_free()
			_hazards.erase(id)

	# Create missing hazards
	for hazard_state in state.get_hazards():
		if not _hazards.has(hazard_state.id):
			_create_hazard(hazard_state)

	# Sync existing hazards (this is where tweening works!)
	for hazard_state in state.get_hazards():
		var hazard := _hazards[hazard_state.id]
		if hazard.sync_with_state(hazard_state, action):
			animation_signals.append(hazard.animation_finished)

	await signal_group.all(animation_signals)

func _create_hazard(hazard_state: HazardState) -> void:
	var hazard: Hazard = HAZARD_SCENE.instantiate()
	hazard._board = board
	add_child(hazard)
	hazard.sync_with_state(hazard_state, null)
	_hazards[hazard_state.id] = hazard
