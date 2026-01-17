class_name AIController
extends Node
## Reacts to turns and AI to choose actions

signal action_chosen(action: Action)

@export var action_odds: float = 0.1

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

	# Try to kill a player if possible
	for action_type in unit.actions:
		if action_type in [Global.ACTION_TYPE.KNIFE, Global.ACTION_TYPE.GUN, Global.ACTION_TYPE.PUSH]:
			for player_unit in state.get_units(Global.GROUP_TYPE.PLAYER):
				var test_action := Action.new()
				test_action.type = action_type
				test_action.unit_id = unit.id
				test_action.target_pos = player_unit.cell_pos
				if _can_hit_player(state, test_action):
					action_chosen.emit(test_action)
					return
		
		if action_type == Global.ACTION_TYPE.TELEPORT:
			for player_unit in state.get_units(Global.GROUP_TYPE.PLAYER):
				if randf() < action_odds:
					var test_action := Action.new()
					test_action.type = action_type
					test_action.unit_id = unit.id
					test_action.target_pos = player_unit.cell_pos
					action_chosen.emit(test_action)
					return
			continue
		
		if action_type == Global.ACTION_TYPE.SHIELD:
			if randf() < action_odds:
				var test_action := Action.new()
				test_action.type = action_type
				test_action.unit_id = unit.id
				test_action.target_pos = unit.cell_pos
				action_chosen.emit(test_action)
				return
		
		if action_type == Global.ACTION_TYPE.TRAP:
			var free_tiles = state.get_free_adjacent_tiles(unit.cell_pos)
			if not free_tiles.is_empty() and randf() < action_odds:
				var action := Action.new()
				action.type = action_type
				action.unit_id = unit.id
				action.target_pos = free_tiles.pick_random()
				action_chosen.emit(action)
				return
	
	# Try to move if possible
	if Global.ACTION_TYPE.MOVE in unit.actions:
		var adj_tiles = state.get_adjacent_tiles(unit.cell_pos)
		adj_tiles = adj_tiles.filter(func(tile: Vector2i) -> bool:
			return state.get_unit_by_position(tile) == null
		)
		if adj_tiles.size() > 0:
			var move_action := Action.new()
			move_action.type = Global.ACTION_TYPE.MOVE
			move_action.unit_id = unit.id
			move_action.target_pos = adj_tiles.pick_random()
			action_chosen.emit(move_action)
			return

	# Fallback: pass/draw
	var pass_action := Action.new()
	pass_action.type = Global.ACTION_TYPE.DRAW
	pass_action.unit_id = unit.id
	pass_action.num_cards = 0
	action_chosen.emit(pass_action)

# --- Helpers ---
# Returns true if this action would hit a player unit
func _can_hit_player(state: GameState, action: Action) -> bool:
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
		_:
			return false
