class_name UnitsContainer
extends Node2D
## Owns all UnitGroups in the game

# Signals
signal animations_finished()

@export var board: Board

# Private
var _unit_groups: Array[UnitGroup] = []
var _pending_animations: int = 0

func _ready() -> void:
	assert(board != null, "Board reference is required")
	Global.game_state_changed.connect(sync_with_state)

## Sync units with game state
func sync_with_state(state: GameState) -> void:
	# Sync existing groups
	for unit_group in _unit_groups.duplicate():
		var group_state = state.get_group(unit_group.get_id())
		if group_state:
			unit_group.sync_with_state(group_state)
		else:
			_remove_group(unit_group)

	# Create new groups that don't exist yet
	for group_state in state.groups:
		if _get_group_by_id(group_state.id) == null:
			_create_group(group_state)

func _create_group(group_state: GroupState) -> void:
	var unit_group: UnitGroup = UnitGroup.new(group_state.id)
	unit_group.board = board
	add_child(unit_group)
	unit_group.unit_animation_started.connect(_on_unit_anim_started)
	unit_group.unit_animation_finished.connect(_on_unit_anim_finished)
	unit_group.sync_with_state(group_state)
	_unit_groups.append(unit_group)

func _remove_group(group: UnitGroup) -> void:
	group.queue_free()
	_unit_groups.remove_at(_unit_groups.find(group))

func _get_group_by_id(id: int) -> UnitGroup:
	for group: UnitGroup in _unit_groups:
		if group.get_id() == id:
			return group
	return null

func _clear() -> void:
	for group in _unit_groups:
		group.queue_free()
	_unit_groups.clear()


func _on_unit_anim_started():
	_pending_animations += 1

func _on_unit_anim_finished():
	_pending_animations -= 1
	if _pending_animations == 0:
		animations_finished.emit()