class_name Unit
extends Node2D

# Onready Variables
@onready var piece_sprite: Sprite2D = %Sprite2D

# Public variables
var board: Board

# Private Variables
var _id: int

func sync_with_state(unit_state: UnitState) -> void:
	# TODO: Make if so it dont alwyas override
	var world_pos: Vector2 = board.cell_to_world(unit_state.cell_pos)
	_id = unit_state.id
	name = unit_state.name
	position = world_pos
	piece_sprite.texture = unit_state.piece_texture

func get_id() -> int:
	return _id
