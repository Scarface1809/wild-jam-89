extends Resource
class_name GroupData

enum Type {
	PLAYER,
	ENEMY
}

@export var name: String
@export var type: Type = Type.ENEMY
@export var units: Array[UnitData]