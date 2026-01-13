class_name AIController
extends Node
## Reacts to turns and AI to choose actions

signal action_chosen(action: Action)

func begin_turn(state: GameState) -> void:
	var _group: GroupState = state.get_active_group()
	var unit: UnitState = state.get_active_unit()

	var action: Action = Action.new()
	action.type = Global.ACTION_TYPE.MOVE
	action.unit_id = unit.id
	action.target_pos = state.get_free_adjacent_tiles(unit.cell_pos).pick_random()

	action_chosen.emit(action)
