class_name Unit
extends Node2D

# Private Variables
var _id: int

func initialize_from_state(unit_state: UnitState, world_pos: Vector2) -> void:
	_id = unit_state.id
	name = unit_state.name
	position = world_pos
	print("Unit ", name, " has been created with id ", _id)

func sync_with_state(unit_state: UnitState, world_pos: Vector2) -> void:
	position = world_pos
	pass
