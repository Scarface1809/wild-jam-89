class_name Hazard
extends Node2D

var board: Board
var cell_pos: Vector2i

func sync_with_state(hazard_state: HazardState) -> void:
	cell_pos = hazard_state.cell_pos
	position = board.cell_to_world(cell_pos)
