class_name GameState
extends Resource
## Game State

# Board
var board_size: Vector2i
var tiles: Dictionary[Vector2i, Global.SUIT] = {}
# group_id -> Array[UnitState]
var groups: Array[GroupState] = []
# Turn State
var active_group_index: int
var active_unit_index: int
# Cards
var deck: Array[CardData] = []
var hand: Array[CardData] = []

# GameState Queries

# Turn
func get_active_group() -> GroupState:
	return groups[active_group_index]

func get_active_unit() -> UnitState:
	return get_active_group().units[active_unit_index]

func has_next_unit() -> bool:
	return active_unit_index + 1 < get_active_group().get_unit_count()

func next_unit() -> void:
	active_unit_index += 1

# TODO: Skip Empty groups which isnt happening yet
func next_group() -> void:
	active_group_index += 1
	if active_group_index >= groups.size():
		active_group_index = 0
	active_unit_index = 0

func reset_group() -> void:
	active_group_index = 0

func reset_unit() -> void:
	active_unit_index = 0

func reset_turn() -> void:
	reset_group()
	reset_unit()

# Board
func get_random_free_tile() -> Vector2i:
	var all_cells: Array[Vector2i] = []

	for x in range(board_size.x):
		for y in range(board_size.y):
			all_cells.append(Vector2i(x, y))

	var free_cells = get_free_tiles(all_cells)

	# TODO: Error prone pick random gives error in case of empty array try catch block? and simply return null?

	return free_cells.pick_random()

func get_adjacent_tiles(cell: Vector2i) -> Array[Vector2i]:
	var adj: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(0, -1), # up
		Vector2i(0, 1), # down
		Vector2i(-1, 0), # left
		Vector2i(1, 0) # right
	]

	for dir in directions:
		var neighbor = cell + dir
		# Check bounds
		if neighbor.x >= 0 and neighbor.x < board_size.x and neighbor.y >= 0 and neighbor.y < board_size.y:
			adj.append(neighbor)

	return adj

func get_free_adjacent_tiles(cell: Vector2i) -> Array[Vector2i]:
	var adj = get_adjacent_tiles(cell)
	return get_free_tiles(adj)

func get_free_tiles(cells: Array[Vector2i]) -> Array[Vector2i]:
	return cells.filter(func(cell: Vector2i) -> bool:
		return not is_tile_occupied(cell)
	)

func is_tile_occupied(cell: Vector2i) -> bool:
	for group: GroupState in groups:
		for unit: UnitState in group.units:
			if unit.cell_pos == cell:
				return true
	return false

# Groups
func get_groups() -> Array[GroupState]:
	return groups

func get_group(group_id: int) -> GroupState:
	for group: GroupState in groups:
		if group.id == group_id:
			return group
	return null

func get_group_count() -> int:
	return groups.size()

func has_group(group_id: int) -> bool:
	for group: GroupState in groups:
		if group.id == group_id:
			return true
	return false

# Units
func get_unit_by_id(unit_id: int) -> UnitState:
	for group: GroupState in groups:
		if group.has_unit(unit_id):
			return group.get_unit_by_id(unit_id)
	return null

# Cards
func draw_cards(count: int) -> void:
	for _i: int in range(count):
		if deck.is_empty():
			break
		var card = deck.pop_front()
		hand.append(card)

func remove_card(card: CardData) -> void:
	hand.erase(card)
