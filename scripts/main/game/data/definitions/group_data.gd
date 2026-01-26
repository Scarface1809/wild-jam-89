@icon("uid://duyjj5ukigpie")
extends Resource
class_name GroupData
## Represents the data of a group in the game (Immutable)

@export var name: String
@export var type: Global.GroupType
@export var units: Array[UnitData] = []

func init(_name: String, _type: Global.GroupType, _units: Array[UnitData]) -> void:
	name = _name
	type = _type
	units = _units