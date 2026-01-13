extends Resource
class_name GroupState
## Represents the state of a group in the game (Mutable)

var id: int
var name: String
var type: Global.GROUP_TYPE
var units: Array[UnitState]

func _init(state: GameState, data: GroupData) -> void:
	id = state.get_next_group_id()
	name = data.name
	type = data.type
	units = []
	for unit_data: UnitData in data.units:
		var unit_id: int = state.get_next_unit_id()
		var unit_state: UnitState = UnitState.new(unit_id, id, state.get_random_free_tile(), unit_data)
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
