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
		Global.ACTION_TYPE.ATTACK:
			_apply_attack(game_state, action)
		_:
			push_error("Unknown action type: " + str(action.type))

func can_apply(game_state: GameState, action: Action) -> bool:
	match action.type:
		Global.ACTION_TYPE.MOVE:
			return _can_apply_move(game_state, action)
		Global.ACTION_TYPE.ATTACK:
			return _can_apply_attack(game_state, action)
		#Global.ACTION_TYPE.CARD:
		#	return _can_apply_card(game_state, action)
		_:
			return false

# Private Methods
# Applies
func _apply_move(game_state: GameState, action: Action) -> void:
	var unit := game_state.get_unit_by_id(action.unit_id)
	unit.cell_pos = action.target_pos
	if action.source_card != null:
		game_state.remove_card(action.source_card)

func _apply_attack(game_state: GameState, action: Action) -> void:
	# TODO: resolve damage, remove units, etc.
	pass

func _apply_card(game_state: GameState, action: Action) -> void:
	# TODO: apply card effects
	pass

# Validation
func _can_apply_move(game_state: GameState, action: Action) -> bool:
	var unit: UnitState = game_state.get_unit_by_id(action.unit_id)
	assert(unit != null, "Unit not found")
	# TODO: Implement move validation logic
	return true
	
func _can_apply_attack(game_state: GameState, action: Action) -> bool:
	# TODO: Implement attack validation logic
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
