extends Resource
class_name UnitState
## Represents the state of a unit in the game (Mutable)

var id: int
var group_id: int
var cell_pos: Vector2i
var name: String

func _init(_id: int, _group_id: int, _cell_pos: Vector2i, data: UnitData) -> void:
    self.id = _id
    self.group_id = _group_id
    self.cell_pos = _cell_pos
    self.name = data.name