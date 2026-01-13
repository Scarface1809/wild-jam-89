extends Resource
class_name GroupState
## Represents the state of a group in the game (Mutable)

var id: int
var type: Global.GROUP_TYPE
var units: Array[UnitState]

func _init(_id: int, _type: Global.GROUP_TYPE, _units: Array[UnitState]) -> void:
	self.id = _id
	self.type = _type
	self.units = _units

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
