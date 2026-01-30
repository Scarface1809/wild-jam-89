@icon("uid://mjcjlr2vgpl0")
class_name GameState
extends Resource
## Immutable snapshot of the entire game state.

# Round
var current_round: int = 0
# Board
var board_size: Vector2i
var tiles: Dictionary[Vector2i, Global.Suit] = {}
var hazards: Dictionary[int, HazardState] = {}
# Unit groups
var groups: Array[GroupState] = [] # TODO: Pass to Dictionary
# Turn State
var active_group_index: int = -1
var active_unit_index: int = -1
# Cards
var deck: Array[CardData] = []
var hand: Array[CardData] = []
# Spawn ID's
var next_unit_id: int = 0
var next_group_id: int = 0
var next_hazard_id: int = 0

# Queries

#region round
func get_current_round() -> int:
	return current_round
#endregion

#region Board
# Board
func get_board_size() -> Vector2i:
	return board_size

func get_tile_suit(cell: Vector2i) -> Global.Suit:
	return tiles.get(cell)

func has_tile(cell: Vector2i) -> bool:
	return tiles.has(cell)

func get_adjacent_tiles(cell: Vector2i) -> Array[Vector2i]:
	var adjacent_tiles: Array[Vector2i] = []
	for offset in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var neighbor = cell + offset
		if has_tile(neighbor):
			adjacent_tiles.append(neighbor)
	return adjacent_tiles

func get_cross_tiles(start: Vector2i, max_distance: int = -1) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var directions: Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]

	for dir in directions:
		result += get_line_tiles(start, dir, max_distance)

	return result

func get_line_tiles(start: Vector2i, direction: Vector2i, max_distance: int = -1) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var limit := max_distance
	if limit < 0:
		limit = max(board_size.x, board_size.y)

	var current := start
	for _i in range(limit):
		current += direction
		if not has_tile(current):
			break
		result.append(current)

	return result

# Hazards
func has_hazard(cell: Vector2i) -> bool:
	for hazard in hazards.values():
		if hazard.cell_pos == cell:
			return true
	return false

func get_hazard_at(cell: Vector2i) -> HazardState:
	for hazard in hazards.values():
		if hazard.cell_pos == cell:
			return hazard
	return null

func get_hazards() -> Array[HazardState]:
	return hazards.values()
#endregion

#region Groups
func get_groups() -> Array[GroupState]:
	return groups.duplicate(true)

func get_groups_by_type(type: Global.GroupType) -> Array[GroupState]:
	var result: Array[GroupState] = []
	for group: GroupState in groups:
		if group.type == type:
			result.append(group)
	return result

func get_group_by_id(group_id: int) -> GroupState:
	for group: GroupState in groups:
		if group.id == group_id:
			return group
	return null

func has_group(group_id: int) -> bool:
	for group: GroupState in groups:
		if group.id == group_id:
			return true
	return false

func get_group_count() -> int:
	return groups.size()

func get_unit_by_id(unit_id: int) -> UnitState:
	for group: GroupState in groups:
		if group.has_unit(unit_id):
			return group.get_unit_by_id(unit_id)
	return null

func get_unit_at(cell: Vector2i) -> UnitState:
	for group: GroupState in groups:
		for unit: UnitState in group.units:
			if unit.cell_pos == cell:
				return unit
	return null

func get_all_units() -> Array[UnitState]:
	var units: Array[UnitState] = []
	for group: GroupState in groups:
		units += group.units
	return units

func get_units_in_group(group_id: int) -> Array[UnitState]:
	for group: GroupState in groups:
		if group.id == group_id:
			return group.units.duplicate(true)
	return []

func get_units_by_group_type(type: Global.GroupType) -> Array[UnitState]:
	var units: Array[UnitState] = []
	for group in groups:
		if group.type == type:
			units += group.units
	return units

#endregion

#region Turn
func get_active_group_index() -> int:
	return active_group_index

func get_active_unit_index() -> int:
	return active_unit_index

func get_active_group() -> GroupState:
	return groups[active_group_index]

func get_active_unit() -> UnitState:
	if active_unit_index < get_active_group().get_unit_count():
		return get_active_group().get_units()[active_unit_index]
	return null

#endregion

#region Cards
func get_deck_size() -> int:
	return deck.size()

func get_hand_size() -> int:
	return hand.size()

func get_hand() -> Array[CardData]:
	return hand.duplicate(true)

func is_deck_empty() -> bool:
	return deck.is_empty()

#endregion

#region Spawn
func get_next_unit_id() -> int:
	var id = next_unit_id
	next_unit_id += 1
	return id

func get_next_group_id() -> int:
	var id = next_group_id
	next_group_id += 1
	return id

func get_next_hazard_id() -> int:
	var id = next_hazard_id
	next_hazard_id += 1
	return id
#endregion

#region Serialization
func to_dict() -> Dictionary:
	return {
		"current_round": current_round,
		"board_size": board_size,
		"tiles": tiles,
		"hazards": hazards.values().map(func(h: HazardState) -> Dictionary: return h.to_dict()),
		"groups": groups.map(func(g: GroupState) -> Dictionary: return g.to_dict()),
		"active_group_index": active_group_index,
		"active_unit_index": active_unit_index,
		"deck": deck.filter(func(c: CardData) -> bool: return c != null).map(func(c: CardData) -> String: return c.resource_path),
		"hand": hand.filter(func(c: CardData) -> bool: return c != null).map(func(c: CardData) -> String: return c.resource_path),
		"next_unit_id": next_unit_id,
		"next_group_id": next_group_id,
		"next_hazard_id": next_hazard_id
	}

func from_dict(data: Dictionary) -> void:
	current_round = data.get("current_round", current_round)
	board_size = data.get("board_size", board_size)
	tiles = data.get("tiles", tiles)

	hazards.clear()
	for h_data in data.get("hazards", []):
		var hazard: HazardState = HazardState.new(-1, Vector2i(-1, -1))
		hazard.from_dict(h_data)
		hazards[hazard.id] = hazard
	
	groups.clear()
	for g_data in data.get("groups", []):
		var group: GroupState = GroupState.new(-1, null)
		group.from_dict(g_data)
		groups.append(group)
	
	active_group_index = data.get("active_group_index", active_group_index)
	active_unit_index = data.get("active_unit_index", active_unit_index)

	deck.clear()
	for path in data.get("deck", []):
		if path == "" or path == null:
			continue
		var card = load(path)
		if card != null:
			deck.append(card)

	hand.clear()
	for path in data.get("hand", []):
		if path == "" or path == null:
			continue
		var card = load(path)
		if card != null:
			hand.append(card)

	next_unit_id = data.get("next_unit_id", next_unit_id)
	next_group_id = data.get("next_group_id", next_group_id)
	next_hazard_id = data.get("next_hazard_id", next_hazard_id)
#endregion

# String representation for debugging
func _to_string() -> String:
	var s = "[GameState] Board size: %s\n" % [str(board_size)]
	s += "Round: %d\n" % [current_round]
	s += "Tiles: %d, Hazards: %d\n" % [tiles.size(), hazards.size()]
	s += "Groups: %d, Active Group: %d, Active Unit: %d\n" % [groups.size(), active_group_index, active_unit_index]
	s += "Deck: %d, Hand: %d\n" % [deck.size(), hand.size()]
	for group in groups:
		s += "  Group %d (%s): %d units\n" % [group.id, str(group.type), group.units.size()]
		for unit in group.units:
			s += "    Unit %d (%s) at %s\n" % [unit.id, unit.name, unit.cell_pos]
	return s
