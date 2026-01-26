class_name HazardState
extends Node

var id: int = -1
var cell_pos: Vector2i = Vector2i(-1, -1)

func _init(_id: int, _cell_pos: Vector2i) -> void:
	id = _id
	cell_pos = _cell_pos