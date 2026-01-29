class_name HazardState
extends Node

var id: int = -1
var cell_pos: Vector2i = Vector2i(-1, -1)

func _init(_id: int, _cell_pos: Vector2i) -> void:
	id = _id
	cell_pos = _cell_pos

func to_dict() -> Dictionary:
	return {
		"id": id,
		"cell_pos": {
			"x": cell_pos.x,
			"y": cell_pos.y
		}
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", id)
	var pos = data.get("cell_pos", {"x": - 1, "y": - 1})
	cell_pos = Vector2i(pos.get("x", -1), pos.get("y", -1))
