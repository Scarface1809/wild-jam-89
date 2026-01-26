class_name UnitsContainer
extends Node2D
## Owns all UnitGroups in the game

@export var board: Board

# Private
var _unit_groups: Array[UnitGroup] = []

func _ready() -> void:
	assert(board != null, "Board reference is required")
	Global.turn_started.connect(_on_turn_started)
	Global.turn_ended.connect(_on_turn_ended)

## Sync units with game state
func sync_with_state(state: GameState, action: Action) -> void:
	var signal_group = SignalGroup.new()
	var animation_signals: Array[Signal] = []

	# Sync existing groups
	for unit_group: UnitGroup in _unit_groups.duplicate():
		var group_state: GroupState = state.get_group_by_id(unit_group.get_id())
		if group_state:
			animation_signals.append_array(unit_group.sync_with_state(group_state, action))
		else:
			_remove_group(unit_group)

	# Create new groups that don't exist yet
	for group_state: GroupState in state.groups:
		if not _get_group_by_id(group_state.id):
			_create_group(group_state, action)
	
	await signal_group.all(animation_signals)

# Helpers
func _create_group(group_state: GroupState, action: Action) -> void:
	var unit_group: UnitGroup = UnitGroup.new(group_state.id, board)
	unit_group.name = group_state.name
	add_child(unit_group)
	unit_group.sync_with_state(group_state, action)
	_unit_groups.append(unit_group)

func _remove_group(group: UnitGroup) -> void:
	group.queue_free()
	_unit_groups.erase(group)

func _get_group_by_id(group_id: int) -> UnitGroup:
	for group in _unit_groups:
		if group.get_id() == group_id:
			return group
	return null

func _get_unit_by_pos(cell_pos: Vector2i) -> Unit:
	for group: UnitGroup in _unit_groups:
		var unit: Unit = group._get_unit_by_pos(cell_pos)
		if unit:
			return unit
	return null

# Signal Handlers
func _on_turn_started(_group: GroupState, unit: UnitState) -> void:
	var unit_group: UnitGroup = _get_group_by_id(_group.id)
	if unit_group:
		unit_group.set_active_unit(unit.id)

func _on_turn_ended(_group: GroupState, _unit: UnitState) -> void:
	var unit_group: UnitGroup = _get_group_by_id(_group.id)
	if unit_group:
		unit_group.clear_active_unit()
