class_name Unit
extends Node2D

# Signals
signal animation_started()
signal animation_finished()

# Onready Variables
@onready var piece_sprite: Sprite2D = %Sprite2D

# Public variables
var board: Board

# Private Variables
var _id: int
var _is_animating: bool = false

func sync_with_state(unit_state: UnitState) -> void:
	_id = unit_state.id
	name = unit_state.name
	piece_sprite.texture = unit_state.piece_texture

	var target_world_pos := board.cell_to_world(unit_state.cell_pos)

	if position == Vector2.ZERO:
		position = target_world_pos
		return

	# If position changed → animate
	if position != target_world_pos:
		_animate_move_to(target_world_pos)

func _animate_move_to(target_pos: Vector2) -> void:
	if _is_animating:
		return

	_is_animating = true
	animation_started.emit()

	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, 0.25) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		_is_animating = false
		animation_finished.emit()
	)


func get_id() -> int:
	return _id
