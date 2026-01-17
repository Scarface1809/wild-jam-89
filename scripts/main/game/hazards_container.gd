class_name HazardsContainer
extends Node2D
## Owns all Hazard visuals in the game (VIEW ONLY)

# Constants
const HAZARD_SCENE: PackedScene = preload(Global.SCENE_UIDS.HAZARD)

# Export
@export var board: Board

# Private
var _hazards: Dictionary[Vector2i, Hazard] = {}

func _ready() -> void:
	assert(board != null, "Board reference is required")
	Global.game_state_changed.connect(sync_with_state)

## Sync hazard visuals with GameState
func sync_with_state(state: GameState, _action: Action) -> void:
	# 1. Remove visuals that no longer exist in GameState
	for cell_pos in _hazards.keys():
		if not state.is_tile_hazard(cell_pos):
			var hazard: Hazard = _hazards[cell_pos]
			_hazards.erase(cell_pos)
			hazard.queue_free()

	# 2. Create visuals missing from GameState
	for hazard_state: HazardState in state.get_hazards():
		if not _hazards.has(hazard_state.cell_pos):
			_create_hazard(hazard_state)

func _create_hazard(hazard_state: HazardState) -> void:
	var hazard: Hazard = HAZARD_SCENE.instantiate()
	hazard.board = board
	hazard.sync_with_state(hazard_state)
	add_child(hazard)

	_hazards[hazard_state.cell_pos] = hazard
