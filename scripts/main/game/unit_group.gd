class_name UnitGroup
extends Node2D
# Docstring

# Signals
signal request_spawn_position(unit: Unit, callback: Callable)
signal turn_complete

# Constants
const UNIT_SCENE: PackedScene = preload(Global.SCENE_UIDS.UNIT)

# Private Variables
var _group_data: GroupData
var _current_unit_index: int = 0

# OnReady Variables

# Public Methods
func take_turn() -> void:
	for unit in _get_active_units():
		unit.take_turn()
	turn_complete.emit()

# Private Methods
func _init(group_data: GroupData) -> void:
	_group_data = group_data
	name = group_data.name

func _ready() -> void:
	_spawn_units()

func _spawn_units() -> void:
	for unit_data in _group_data.units:
		var unit: Unit = UNIT_SCENE.instantiate()
		unit.init(unit_data)
		unit.defeated.connect(_on_unit_defeated)
		add_child(unit)
		request_spawn_position.emit(unit, _spawn_unit)

func _spawn_unit(unit: Unit, pos: Vector2i) -> void:
	unit.position = pos

func _get_active_units() -> Array[Unit]:
	var units: Array[Unit] = []
	for child in get_children():
		if child is Unit:
			units.append(child)

	return units

func _is_player() -> bool:
	return _group_data.type == GroupData.Type.PLAYER

func _on_unit_defeated(unit: Unit) -> void:
	print("Unit ", unit.name, " has been defeated")
