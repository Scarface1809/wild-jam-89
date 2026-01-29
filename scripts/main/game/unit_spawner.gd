class_name UnitSpawner
extends RefCounted
## Responsible for creating UnitState and GroupState objects

# Specific to my game...
func spawn_player_group(state: GameState, group_data: GroupData) -> GroupState:
	var group: GroupState = GroupState.new(state.get_next_group_id(), group_data)
	state.groups.append(group)

	for unit_data: UnitData in group_data.units:
		var position: Vector2i = _get_board_center(state)
		_spawn_unit(state, group, unit_data, position)
	return group

# Generic except location...
func spawn_enemy_group(state: GameState, group_data: GroupData) -> GroupState:
	var group: GroupState = GroupState.new(state.get_next_group_id(), group_data)
	state.groups.append(group)

	var spawn_tiles: Array[Vector2i] = _get_border_tiles(state)

	for unit_data: UnitData in group_data.units:
		var pos: Vector2i = spawn_tiles.pick_random()
		spawn_tiles.erase(pos)
		_spawn_unit(state, group, unit_data, pos)

	return group

func _spawn_unit(state: GameState, group: GroupState, unit_data: UnitData, cell: Vector2i) -> void:
	var unit: UnitState = UnitState.new(
		state.get_next_unit_id(),
		group.id,
		cell,
		unit_data
	)
	group.units.append(unit)

# Helper functions
func _get_board_center(state: GameState) -> Vector2i:
	return Vector2i(
		state.board_size.x >> 1,
		state.board_size.y >> 1
	)

func _get_border_tiles(state: GameState) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var max_x := state.board_size.x - 1
	var max_y := state.board_size.y - 1

	for cell in state.tiles.keys():
		if (
			cell.x == 0 or cell.x == max_x
			or cell.y == 0 or cell.y == max_y
		) and state.get_unit_at(cell) == null:
			tiles.append(cell)

	return tiles
