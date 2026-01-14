class_name Hazard
extends Node2D

var cell_pos: Vector2i

func initialize(cell: Vector2i, world_pos: Vector2) -> void:
	cell_pos = cell
	position = world_pos
