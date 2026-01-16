class_name RuleSystem
extends Node
## Rule system for the game. It is essentially an actioncontroller. Validates actions and applies them to the game state.
## Only reads and writes to game state

# Public Methods
func apply(game_state: GameState, action: Action) -> void:
	assert(can_apply(game_state, action), "Applying invalid action")
	match action.type:
		Global.ACTION_TYPE.MOVE:
			_apply_move(game_state, action)
		Global.ACTION_TYPE.GUN:
			_apply_gun(game_state, action)
		Global.ACTION_TYPE.KNIFE:
			_apply_knife(game_state, action)
		Global.ACTION_TYPE.TELEPORT:
			_apply_teleport(game_state, action)
		Global.ACTION_TYPE.PUSH:
			_apply_push(game_state, action)
		Global.ACTION_TYPE.TRAP:
			_apply_trap(game_state, action)
		Global.ACTION_TYPE.SHIELD:
			_apply_shield(game_state, action)
		Global.ACTION_TYPE.SEVEN:
			_apply_seven(game_state, action)
		Global.ACTION_TYPE.DRAW:
			_apply_draw(game_state, action)
		Global.ACTION_TYPE.RESHUFFLE:
			_apply_reshuffle(game_state, action)
		_:
			push_error("Unknown action type: " + str(action.type))

func can_apply(game_state: GameState, action: Action) -> bool:
	match action.type:
		Global.ACTION_TYPE.MOVE:
			return _can_apply_move(game_state, action)
		Global.ACTION_TYPE.GUN:
			return _can_apply_gun(game_state, action)
		Global.ACTION_TYPE.KNIFE:
			return _can_apply_knife(game_state, action)
		Global.ACTION_TYPE.TELEPORT:
			return _can_apply_teleport(game_state, action)
		Global.ACTION_TYPE.PUSH:
			return _can_apply_push(game_state, action)
		Global.ACTION_TYPE.TRAP:
			return _can_apply_trap(game_state, action)
		Global.ACTION_TYPE.SHIELD:
			return _can_apply_shield(game_state, action)
		Global.ACTION_TYPE.SEVEN:
			return _can_apply_seven(game_state, action)
		Global.ACTION_TYPE.DRAW:
			return _can_apply_draw(game_state, action)
		Global.ACTION_TYPE.RESHUFFLE:
			return _can_apply_reshuffle(game_state, action)
		_:
			return false

# Private Methods
#region Applies
func _apply_move(game_state: GameState, action: Action) -> void:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	var target_pos = action.target_pos

	# Check if moving onto a trap
	if game_state.is_tile_hazard(target_pos):
		# Remove trap
		game_state.remove_hazard(target_pos)
		# Remove unit from its group (unit “dies”)
		var group: GroupState = game_state.get_group(unit.group_id)
		if group != null:
			group.remove_unit(unit)
	else:
		# Normal move
		unit.cell_pos = target_pos

	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_gun(game_state: GameState, action: Action) -> void:
	var target_pos = action.target_pos
	var target_unit: UnitState = game_state.get_unit_by_position(target_pos)

	if target_unit == null:
		if game_state.is_tile_hazard(target_pos):
			# Gun can destroy trap
			game_state.remove_hazard(target_pos)
		else:
			push_error("Gun target is neither a unit nor a trap")
		# Remove card
		if action.source_card != null:
			game_state.remove_card(action.source_card)
		return

	var target_group: GroupState = game_state.get_group(target_unit.group_id)
	assert(target_group != null, "Target unit's group not found")

	if target_unit.shielded:
		target_unit.shielded = false
	else:
		target_group.remove_unit(target_unit)

	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_knife(game_state: GameState, action: Action) -> void:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	var target_pos = action.target_pos
	var target_unit: UnitState = game_state.get_unit_by_position(target_pos)
	var is_trap := false
	if target_unit == null:
		if game_state.is_tile_hazard(target_pos):
			is_trap = true
		else:
			push_error("Knife target is neither a unit nor a trap")
			return

	# Apply knife effect
	if target_unit != null:
		if target_unit.shielded:
			target_unit.shielded = false
			return
		var target_group: GroupState = game_state.get_group(target_unit.group_id)
		assert(target_group != null, "Target unit's group not found")
		target_group.remove_unit(target_unit)
	elif is_trap:
		game_state.remove_hazard(target_pos)

	# Move unit if hitting a unit
	if target_unit != null:
		unit.cell_pos = target_pos

	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_teleport(game_state: GameState, action: Action) -> void:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	var target_pos = action.target_pos
	var target_unit: UnitState = game_state.get_unit_by_position(target_pos)

	if target_unit != null:
		# Swap positions with another unit
		var temp := unit.cell_pos
		unit.cell_pos = target_unit.cell_pos
		target_unit.cell_pos = temp
	elif game_state.is_tile_hazard(target_pos):
		# Teleport onto trap → trap removed, unit dies
		game_state.remove_hazard(target_pos)
		var group: GroupState = game_state.get_group(unit.group_id)
		if group != null:
			group.remove_unit(unit)
	else:
		push_error("Teleport target is neither a unit nor a trap")
		return

	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_push(game_state: GameState, action: Action) -> void:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	var from := unit.cell_pos
	var to := action.target_pos
	var final_pos := to

	# Determine if there is a unit at the target
	var target_unit: UnitState = game_state.get_unit_by_position(to)
	var is_trap := false
	if target_unit == null:
		if game_state.is_tile_hazard(to):
			is_trap = true
		else:
			push_error("Push target is neither a unit nor a trap")
			return

	# Horizontal push
	if from.y == to.y:
		if to.x > from.x:
			final_pos.x = game_state.board_size.x - 1
		else:
			final_pos.x = 0
	# Vertical push
	elif from.x == to.x:
		if to.y > from.y:
			final_pos.y = game_state.board_size.y - 1
		else:
			final_pos.y = 0
	else:
		push_error("Push requires alignment")
		return

	# Apply push
	if target_unit != null:
		target_unit.cell_pos = final_pos
	elif is_trap:
		game_state.remove_hazard(to)
		game_state.set_hazard(final_pos)

	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_trap(game_state: GameState, action: Action) -> void:
	# place trap
	game_state.set_hazard(action.target_pos)

	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_shield(game_state: GameState, action: Action) -> void:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	if action.forced:
		# Forced = remove shield instead of adding
		unit.shielded = false
	else:
		unit.shielded = true

	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_seven(game_state: GameState, action: Action) -> void:
	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_draw(game_state: GameState, action: Action) -> void:
	game_state.draw_up_to(action.num_cards)

func _apply_reshuffle(game_state: GameState, action: Action) -> void:
	game_state.clear_hand()
	game_state.draw_up_to(action.num_cards)
#endregion

#region Validation
func _can_apply_move(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	if not game_state.get_adjacent_tiles(unit.cell_pos).has(action.target_pos):
		push_warning("Target tile is not adjacent")
		return false

	# Moving onto a trap is allowed
	var target_pos = action.target_pos
	if game_state.is_tile_occupied(target_pos):
		push_warning("Target tile is occupied")
		return false

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(target_pos):
			push_warning("Card suit does not match unit suit")
			return false

	return true
	
func _can_apply_gun(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	if unit.cell_pos.x != action.target_pos.x and unit.cell_pos.y != action.target_pos.y:
		push_warning("Unit is not aligned with target. Unit: " + str(unit.cell_pos) + " Target: " + str(action.target_pos))
		return false
	
	if not game_state.is_tile_occupied(action.target_pos):
		push_warning("Target tile is not occupied")
		return false

	var target_unit: UnitState = game_state.get_unit_by_position(action.target_pos)
	if target_unit != null and target_unit.group_id == unit.group_id:
		push_warning("Cannot shoot own unit")
		return false

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(action.target_pos):
			push_warning("Card suit does not match unit suit")
			return false

	return true

func _can_apply_knife(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	if not game_state.get_adjacent_tiles(unit.cell_pos).has(action.target_pos):
		push_warning("Target tile is not adjacent")
		return false
	
	if not game_state.is_tile_occupied(action.target_pos):
		push_warning("Target tile is not occupied")
		return false
	
	var target_unit: UnitState = game_state.get_unit_by_position(action.target_pos)
	if target_unit != null and target_unit.group_id == unit.group_id:
		push_warning("Cannot stab own unit")
		return false

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(action.target_pos):
			push_warning("Card suit does not match unit suit")
			return false

	return true

func _can_apply_teleport(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")
	
	var target_pos = action.target_pos
	var target_unit: UnitState = game_state.get_unit_by_position(target_pos)

	# Teleport allowed if target is a unit or a trap
	if target_unit != null and target_unit.group_id == unit.group_id:
		push_warning("Cannot teleport to own unit")
		return false
	
	if target_unit == null and not game_state.is_tile_hazard(target_pos):
		push_warning("Teleport target is neither a unit nor a trap")
		return false

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(target_pos):
			push_warning("Card suit does not match unit suit")
			return false

	return true

func _can_apply_push(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")
	
	if not game_state.is_tile_occupied(action.target_pos):
		push_warning("Target tile is not occupied")
		return false
	
	if not game_state.get_adjacent_tiles(unit.cell_pos).has(action.target_pos):
		push_warning("Target tile is not adjacent")
		return false
	
	var target_unit: UnitState = game_state.get_unit_by_position(action.target_pos)
	if target_unit != null and target_unit.group_id == unit.group_id:
		push_warning("Cannot push own unit")
		return false

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(action.target_pos):
			push_warning("Card suit does not match unit suit")
			return false

	return true

func _can_apply_trap(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")
	
	if not game_state.get_adjacent_tiles(unit.cell_pos).has(action.target_pos):
		push_warning("Target tile is not adjacent")
		return false
	
	var target_unit: UnitState = game_state.get_unit_by_position(action.target_pos)
	if target_unit != null and target_unit.group_id == unit.group_id:
		push_warning("Cannot place trap on own unit")
		return false

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(action.target_pos):
			push_warning("Card suit does not match unit suit")
			return false

	return true

func _can_apply_shield(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	if action.forced:
		return true
	
	if action.target_pos != unit.cell_pos:
		push_warning("Cannot shield other unit")
		return false

	# Normal shield logic
	if unit.shielded:
		# TODO: Allow or not allow to waste card to put another shield (useless)
		push_warning("Unit already shielded")
		return false

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(action.target_pos):
			push_warning("Card suit does not match unit suit")
			return false
	
	return true

func _can_apply_seven(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(action.target_pos):
			push_warning("Card suit does not match unit suit")
			return false
	
	return true

func _can_apply_draw(game_state: GameState, _action: Action) -> bool:
	return not game_state.is_deck_empty()

func _can_apply_reshuffle(game_state: GameState, _action: Action) -> bool:
	return not game_state.is_deck_empty()
#endregion

#TODO: REMOVE ENEMY IF MOVING TO TRAP AND THE TRAP IS REMOVED
#TODO: SHIELD
#TODO: SEVEN
