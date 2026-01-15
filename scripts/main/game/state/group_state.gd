@icon("uid://mjcjlr2vgpl0")
extends Resource
class_name GroupState
## Represents the state of a group in the game (Mutable)

var id: int
var name: String
var type: Global.GROUP_TYPE
var units: Array[UnitState]

func _init(state: GameState, data: GroupData, start_positions: Array[Vector2i]) -> void:
	id = state.get_next_group_id()
	name = data.name
	type = data.type
	units = []
	# Get all free tiles (avoid collisions with existing units or hazards)
	var free_tiles: Array[Vector2i] = state.get_free_tiles(state.tiles.keys())

	# Track tiles used for this group to avoid intra-group overlap
	var occupied_tiles: Array[Vector2i] = []

	for i in range(data.units.size()):
		var unit_data: UnitData = data.units[i]
		var pos: Vector2i
		
		if i < start_positions.size():
			pos = start_positions[i]
		else:
			# Filter out tiles already taken by this group's previous units
			var available_tiles = free_tiles.filter(func(cell: Vector2i) -> bool:
				return not occupied_tiles.has(cell)
			)
			if available_tiles.size() == 0:
				push_warning("No free tiles left to spawn unit in group '%s'. Using fallback (0,0)." % name)
				pos = Vector2i(0, 0)
			else:
				pos = available_tiles.pick_random()
			
		occupied_tiles.append(pos)
		var unit_id: int = state.get_next_unit_id()
		var unit_state: UnitState = UnitState.new(unit_id, id, pos, unit_data)
		units.append(unit_state)

func get_units() -> Array[UnitState]:
	return units

func get_unit_by_id(unit_id: int) -> UnitState:
	for unit: UnitState in units:
		if unit.id == unit_id:
			return unit
	return null

func get_unit_count() -> int:
	return units.size()

func remove_unit(unit: UnitState) -> void:
	units.erase(unit)

func has_unit(unit_id: int) -> bool:
	for unit: UnitState in units:
		if unit.id == unit_id:
			return true
	return false
