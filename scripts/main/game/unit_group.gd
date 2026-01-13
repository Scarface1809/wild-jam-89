class_name UnitGroup
extends Node2D

# Constants
const UNIT_SCENE: PackedScene = preload(Global.SCENE_UIDS.UNIT)

# Public
var board: Board

# Private
var _id: int
var _units: Dictionary[int, Unit] = {}

# --- Setup ---
func _init(id: int) -> void:
	_id = id

func initialize_from_state(units: Array[UnitState]) -> void:
	# Parent already clears so this is pointless but safety
	_clear()
	for unit_state: UnitState in units:
		_create_unit(unit_state)

func sync_with_state(units: Array[UnitState]) -> void:
	for unit_state: UnitState in units:
		if not _units.has(unit_state.id):
			_create_unit(unit_state)
		else:
			# TODO: Dont like this fecthing board position here
			var world_pos: Vector2 = board.cell_to_world(unit_state.cell_pos)
			_units[unit_state.id].sync_with_state(unit_state, world_pos)

func _create_unit(unit_state: UnitState) -> void:
	var unit: Unit = UNIT_SCENE.instantiate()
	add_child(unit)
	# TODO: Dont like this fecthing board position here
	var world_pos: Vector2 = board.cell_to_world(unit_state.cell_pos)
	unit.initialize_from_state(unit_state, world_pos)
	_units[unit_state.id] = unit

func _clear() -> void:
	for unit: Unit in _units.values():
		unit.queue_free()
	_units.clear()
