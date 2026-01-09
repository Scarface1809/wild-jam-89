class_name UnitsContainer
extends Node2D
# Docstring

# Signals
signal battle_over(winning_group: UnitGroup)

# Enums

# Constants

# Export Variables

# Public Variables

# Private Variables
var _all_groups: Array[UnitGroup]
var _current_group_index: int = 0

# OnReady Variables

func _ready() -> void:
	for child in get_children():
		if child is UnitGroup:
			_all_groups.append(child)
			child.turn_complete.connect(_on_turn_complete)

# Public Methods
func start_battle() -> void:
	if _all_groups.size() == 0:
		push_error("No groups found!")
		return
	_current_group_index = 0
	_all_groups[_current_group_index].take_turn()

func get_all_unit_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for group in _all_groups:
		for unit in group.get_children():
			if unit is Unit:
				positions.append(Vector2i(unit.position))
	return positions

# Private Methods
func _on_turn_complete(unit_group: UnitGroup) -> void:
	print("Turn has been completed for %s", unit_group.name)

	var active_groups = _all_groups.filter(
		func(group):
			return group.get_active_units().size() > 0
	)

	if active_groups.size() > 1:
		_step_turn()
	else:
		assert(active_groups.size() == 1)
		print("Battle over, %s wins", active_groups[0].name)
		battle_over.emit(active_groups[0])

func _step_turn() -> void:
	_current_group_index = wrapi(_current_group_index + 1, 0, _all_groups.size())
	var current_group: UnitGroup = _all_groups[_current_group_index]
	assert(current_group.get_active_units().size() > 0)
	current_group.take_turn()
