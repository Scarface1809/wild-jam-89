class_name BoardHighlights
extends TileMapLayer
## This class is responsible for rendering the board highlights.

@export var rule_system: RuleSystem
var _state: GameState

func _ready() -> void:
	assert(rule_system != null, "RuleSystem is required")
	Global.card_clicked.connect(_on_card_clicked)
	Global.game_state_changed.connect(sync_with_state)

func sync_with_state(state: GameState, action: Action) -> void:
	_state = state
	if action != null and action.source_card != null:
		clear() # clear highlights after using a card

func _on_card_clicked(index: int) -> void:
	if index >= 0 and index < _state.hand.size():
		var card: CardData = _state.hand[index]
		_update_highlights(card)
	else:
		clear()

func _update_highlights(card: CardData) -> void:
	clear() # Remove previous highlights

	var active_unit: UnitState = _state.get_active_unit()

	for x in range(_state.board_size.x):
		for y in range(_state.board_size.y):
			var cell = Vector2i(x, y)

			var action = Action.new()
			action.type = card.action_type
			action.unit_id = active_unit.id
			action.target_pos = cell
			action.source_card = card

			# Check if the action can be applied
			if rule_system.can_apply(_state, action):
				var suit = _state.get_suit_at(cell)
				set_cell(cell, suit + 1, Vector2i.ZERO)
