@icon("uid://mjcjlr2vgpl0")
extends Resource
class_name UnitState
## Represents the state of a unit in the game (Mutable)

var id: int = -1
var group_id: int = -1
var cell_pos: Vector2i = Vector2i(-1, -1)
var shielded: bool = false

var name: String = "Unit"
var piece_texture: Texture2D = null
var human_texture: Texture2D = null
var actions: Array[Action] = []

func _init(_id: int, _group_id: int, _cell_pos: Vector2i, data: UnitData) -> void:
	self.id = _id
	self.group_id = _group_id
	self.cell_pos = _cell_pos

	self.name = data.name
	self.piece_texture = data.piece_texture
	self.human_texture = data.human_texture
	self.actions = data.actions
