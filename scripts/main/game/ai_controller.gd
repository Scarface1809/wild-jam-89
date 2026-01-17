class_name AIController
extends Node
## Reacts to turns and AI to choose actions

signal action_chosen(action: Action)

var _enabled := false

func set_enabled(enabled: bool) -> void:
	_enabled = enabled

func begin_turn(state: GameState) -> void:
	var group: GroupState = state.get_active_group()
	var unit: UnitState = state.get_active_unit()

	assert(unit != null, "No active unit for AI turn")
	assert(group != null, "No active group for AI turn")

	if not _enabled:
		push_warning("AI controller not enabled")
		return

	# 1️⃣ Try to kill a player if possible
	for action_type in unit.actions:
		if action_type in [Global.ACTION_TYPE.KNIFE, Global.ACTION_TYPE.GUN, Global.ACTION_TYPE.TRAP]:
			for player_unit in state.get_units(Global.GROUP_TYPE.PLAYER):
				var test_action := Action.new()
				test_action.type = action_type
				test_action.unit_id = unit.id
				test_action.target_pos = player_unit.cell_pos
				if _can_kill_player(state, test_action):
					action_chosen.emit(test_action)
					return
	
	# 2️⃣ Try to move if possible
	if Global.ACTION_TYPE.MOVE in unit.actions:
		var free_tiles = state.get_free_adjacent_tiles(unit.cell_pos)
		if free_tiles.size() > 0:
			var move_action := Action.new()
			move_action.type = Global.ACTION_TYPE.MOVE
			move_action.unit_id = unit.id
			move_action.target_pos = free_tiles.pick_random()
			action_chosen.emit(move_action)
			return

	# 3️⃣ Fallback: pass/draw
	var pass_action := Action.new()
	pass_action.type = Global.ACTION_TYPE.DRAW
	pass_action.unit_id = unit.id
	pass_action.num_cards = 0
	action_chosen.emit(pass_action)

# --- Helpers ---
# Returns true if this action would remove a player unit
func _can_kill_player(state: GameState, action: Action) -> bool:
	var target_unit = state.get_unit_by_position(action.target_pos)
	if target_unit == null:
		return false

	# Only care about player units
	if target_unit.group_id != Global.GROUP_TYPE.PLAYER:
		return false

	# Determine if the AI unit can affect that player unit based on action type
	var unit = state.get_unit_by_id(action.unit_id)
	if unit == null:
		return false

	match action.type:
		Global.ACTION_TYPE.KNIFE, Global.ACTION_TYPE.PUSH:
			# Must be adjacent
			return state.get_adjacent_tiles(unit.cell_pos).has(target_unit.cell_pos)
		Global.ACTION_TYPE.GUN:
			# Must be aligned horizontally or vertically
			return unit.cell_pos.x == target_unit.cell_pos.x or unit.cell_pos.y == target_unit.cell_pos.y
		Global.ACTION_TYPE.TRAP:
			# Must be adjacent to place trap under player unit
			return state.get_adjacent_tiles(unit.cell_pos).has(target_unit.cell_pos)
		_:
			return false
