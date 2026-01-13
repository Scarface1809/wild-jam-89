class_name UnitGroup
extends Node2D

# Constants
const UNIT_SCENE: PackedScene = preload(Global.SCENE_UIDS.UNIT)

# Public
var board: Board

# Private
var _id: int
var _units: Array[Unit] = []

# --- Setup ---
func _init(id: int) -> void:
	_id = id

func sync_with_state(group_state: GroupState) -> void:
	var units: Array[UnitState] = group_state.units

	# Remove or sync existing units
	for unit in _units.duplicate(): # duplicate to safely remove
		var found: bool = false
		for unit_state in units:
			if unit_state.id == unit.get_id():
				unit.sync_with_state(unit_state)
				found = true
				break
		if not found:
			_remove_unit(unit)

	# Create missing units
	for unit_state in units:
		if _get_unit_by_id(unit_state.id) == null:
			_create_unit(unit_state)

func get_id() -> int:
	return _id

func _create_unit(unit_state: UnitState) -> void:
	var unit: Unit = UNIT_SCENE.instantiate()
	unit.board = board
	add_child(unit)
	unit.sync_with_state(unit_state)
	_units.append(unit)

func _remove_unit(unit: Unit) -> void:
	unit.queue_free()
	_units.remove_at(_units.find(unit))

func _get_unit_by_id(id: int) -> Unit:
	for unit: Unit in _units:
		if unit.get_id() == id:
			return unit
	return null

func _clear() -> void:
	for unit: Unit in _units:
		unit.queue_free()
	_units.clear()
