class_name Hazard
extends Node2D

var board: Board
var cell_pos: Vector2i

func sync_with_state(hazard_state: HazardState) -> void:
	cell_pos = hazard_state.cell_pos
	var tween = create_tween()
	tween.tween_property(self, "position", board.cell_to_world(cell_pos), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
