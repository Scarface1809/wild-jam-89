class_name UnitsContainer
extends Node2D
## Owns all UnitGroups in the game

# Export variables
@export var board: Board

# Private
var _unit_groups: Dictionary[int, UnitGroup] = {}

func _ready() -> void:
	assert(board != null, "Board reference is required")
	Global.game_state_changed.connect(sync_with_state)

## Renders the units based on the game state
func initialize_from_state(state: GameState) -> void:
	_clear()
	for group_state: GroupState in state.groups:
		_create_group(group_state)

## Sync units with game state
func sync_with_state(state: GameState) -> void:
	for group_state: GroupState in state.groups:
		var group_id := group_state.id

		if not _unit_groups.has(group_id):
			_create_group(group_state)
		else:
			_unit_groups[group_id].sync_with_state(group_state.units)

func _create_group(group_state: GroupState) -> void:
	var unit_group := UnitGroup.new(group_state.id)
	unit_group.board = board
	add_child(unit_group)

	unit_group.initialize_from_state(group_state.units)
	_unit_groups[group_state.id] = unit_group

func _clear() -> void:
	for group: UnitGroup in _unit_groups.values():
		group.queue_free()
	_unit_groups.clear()
