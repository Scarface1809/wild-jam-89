class_name UnitGroup
extends Node2D

# Signals
signal unit_animation_started
signal unit_animation_finished

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

func sync_with_state(group_state: GroupState, action: Action) -> void:
	# Remove or sync existing units
	for unit: Unit in _units.duplicate(): # duplicate to safely remove
		var found: bool = false
		for unit_state: UnitState in group_state.units:
			if unit_state.id == unit.get_id():
				unit.sync_with_state(unit_state, action)
				found = true
				break
		if not found:
			unit.animate_death()
			_units.erase(unit)

	# Create missing units
	for unit_state in group_state.units:
		if _get_unit_by_id(unit_state.id) == null:
			_create_unit(unit_state, action)

func get_id() -> int:
	return _id

func _create_unit(unit_state: UnitState, action: Action) -> void:
	var unit: Unit = UNIT_SCENE.instantiate()
	unit.board = board
	add_child(unit)
	unit.animation_started.connect(func():
		unit_animation_started.emit()
	)
	unit.animation_finished.connect(func():
		unit_animation_finished.emit()
	)
	unit.sync_with_state(unit_state, action)
	_units.append(unit)

func _get_unit_by_id(id: int) -> Unit:
	for unit: Unit in _units:
		if unit.get_id() == id:
			return unit
	return null

func _clear() -> void:
	for unit: Unit in _units:
		unit.queue_free()
	_units.clear()
