@icon("uid://mjcjlr2vgpl0")
extends Resource
class_name GroupState
## Represents the state of a group in the game (Mutable)

var id: int = -1
var name: String = "GroupState"
var type: Global.GroupType = Global.GroupType.ENEMY
var units: Array[UnitState] = []

func _init(_id: int = -1, _data: GroupData = null) -> void:
	self.id = _id
	if _data:
		self.name = _data.name
		self.type = _data.type

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

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"type": type,
		"units": units.map(func(u: UnitState) -> Dictionary: return u.to_dict())
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", id)
	name = data.get("name", name)
	type = data.get("type", type)
	
	var new_units: Array[UnitState] = []
	for d in data.get("units", []):
		if d is Dictionary:
			var unit = UnitState.new(0, 0, Vector2i(-1, -1), null)
			unit.from_dict(d)
			new_units.append(unit)
	units = new_units
