@icon("uid://duyjj5ukigpie")
extends Resource
class_name GroupData
## Represents the data of a group in the game (Immutable)

@export var name: String
@export var type: Global.GROUP_TYPE
@export var units: Array[UnitData] = []