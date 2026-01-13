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
		Global.ACTION_TYPE.KNIFE:
			_apply_knife(game_state, action)
		_:
			push_error("Unknown action type: " + str(action.type))

func can_apply(game_state: GameState, action: Action) -> bool:
	match action.type:
		Global.ACTION_TYPE.MOVE:
			return _can_apply_move(game_state, action)
		Global.ACTION_TYPE.KNIFE:
			return _can_apply_knife(game_state, action)
		_:
			return false

# Private Methods
# Applies
func _apply_move(game_state: GameState, action: Action) -> void:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")
	# Move
	unit.cell_pos = action.target_pos
	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_knife(game_state: GameState, action: Action) -> void:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")
	# Attack
	var target_unit: UnitState = game_state.get_unit_by_position(action.target_pos)
	assert(target_unit != null, "Target unit not found")
	
	var target_group: GroupState = game_state.get_group(target_unit.group_id)
	assert(target_group != null, "Unit's target group not found")
	
	# Remove target unit from group
	target_group.remove_unit(target_unit)
	
	# Move unit
	unit.cell_pos = action.target_pos
	
	# Remove card
	if action.source_card != null:
		game_state.remove_card(action.source_card)

# Validation
func _can_apply_move(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")

	if not game_state.get_adjacent_tiles(unit.cell_pos).has(action.target_pos):
		push_warning("Target tile is not adjacent")
		return false

	if game_state.is_tile_occupied(action.target_pos):
		push_warning("Target tile is occupied")
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

	if action.source_card != null:
		var card_suit: Global.SUIT = action.source_card.suit
		if card_suit != Global.SUIT.GREEN and card_suit != game_state.get_suit_at(action.target_pos):
			push_warning("Card suit does not match unit suit")
			return false

	return true

func _can_apply_card(state: GameState, card: CardData, target: Vector2i) -> bool:
	if card == null:
		push_warning("No card provided to check if can apply on tile")
		return false

	var hand = state.hand
	if not hand.has(card):
		push_warning("Card not in hand")
		return false

	var tile_suit: Global.SUIT = state.tiles.get(target)
	if tile_suit == null:
		push_warning("No valid tile found at cell " + str(target))
		return false
	
	return card.suit == tile_suit
