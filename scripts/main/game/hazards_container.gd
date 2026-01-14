class_name HazardsContainer
extends Node2D
## Owns all Hazards in the game

# Constants
const HAZARD_SCENE: PackedScene = preload(Global.SCENE_UIDS.HAZARD)

# Export Variables
@export var board: Board

# Private
var _hazards: Array[Hazard] = []

func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)

## Sync hazards with game state
func sync_with_state(state: GameState) -> void:
	# 1. Remove hazards that no longer exist in state
	for hazard in _hazards.duplicate():
		if not state.is_tile_hazard(hazard.cell_pos):
			_hazards.erase(hazard)
			hazard.queue_free()

	# 2. Create hazards missing in visuals
	for cell: Vector2i in state.get_hazards():
		if not _has_hazard_at(cell):
			_create_hazard(cell)

func _create_hazard(cell: Vector2i) -> void:
	var hazard: Hazard = HAZARD_SCENE.instantiate()
	var world_pos: Vector2 = board.cell_to_world(cell)
	hazard.initialize(cell, world_pos)
	add_child(hazard)
	_hazards.append(hazard)


func _has_hazard_at(cell: Vector2i) -> bool:
	for hazard: Hazard in _hazards:
		if hazard.cell_pos == cell:
			return true
	return false
