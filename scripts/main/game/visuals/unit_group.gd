class_name UnitGroup
extends Node2D

# Constants
const UNIT_SCENE: PackedScene = preload(Global.SCENE_UIDS.UNIT)

# Private
var _id: int
var _units: Array[Unit] = []
var _board: Board

# --- Setup ---
func _init(id: int, board: Board) -> void:
	_id = id
	_board = board

func get_id() -> int:
	return _id

func sync_with_state(group_state: GroupState, action: Action) -> Array[Signal]:
	self.name = group_state.name
	
	var animation_signals: Array[Signal] = []
	
	# Remove units that no longer exist
	for unit: Unit in _units.duplicate():
		if not group_state.has_unit(unit.get_id()):
			_remove_unit(unit)

	# Update existing units and add new units
	for unit_state: UnitState in group_state.units:
		var unit: Unit = _get_unit_by_id(unit_state.id)
		if unit:
			if unit.sync_with_state(unit_state, action):
				animation_signals.append(unit.animation_finished)
		else:
			_create_unit(unit_state, action)
	
	return animation_signals

func _create_unit(unit_state: UnitState, action: Action) -> void:
	var unit: Unit = UNIT_SCENE.instantiate()
	unit._board = _board
	add_child(unit)
	unit.sync_with_state(unit_state, action)
	_units.append(unit)

func _remove_unit(unit: Unit) -> void:
	unit.queue_free()
	_units.erase(unit)

func _get_unit_by_id(unit_id: int) -> Unit:
	for u: Unit in _units:
		if u.get_id() == unit_id:
			return u
	return null

# Active unit handling
func set_active_unit(unit_id: int) -> void:
	for unit: Unit in _units:
		unit.set_active(unit.get_id() == unit_id)

func clear_active_unit() -> void:
	for unit: Unit in _units:
		unit.set_active(false)
