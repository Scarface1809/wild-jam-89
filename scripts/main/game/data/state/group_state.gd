@icon("uid://mjcjlr2vgpl0")
extends Resource
class_name GroupState
## Represents the state of a group in the game (Mutable)

var id: int = -1
var name: String = "GroupState"
var type: Global.GroupType = Global.GroupType.ENEMY
var units: Array[UnitState] = []

func _init(state: GameState, data: GroupData) -> void:
	id = state.get_next_group_id()
	name = data.name
	type = data.type

func get_units() -> Array[UnitState]:
	return units

func get_unit_count() -> int:
	return units.size()

func get_unit_by_id(unit_id: int) -> UnitState:
	for unit: UnitState in units:
		if unit.id == unit_id:
			return unit
	return null

func has_unit(unit_id: int) -> bool:
	return get_unit_by_id(unit_id) != null
