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
			
			#TODO: Fix can_apply debugger spam calls

			# Check if the action can be applied
			if rule_system.can_apply(_state, action):
				#var suit = _state.get_suit_at(cell)
				set_cell(cell, 0, Vector2.ZERO, 1) # default
				
				#This is not looking to good, i think it´s better to leave it white for now 
				
				#if _state.get_unit_by_position(cell):
					#match suit:
						#Global.SUIT.BLUE:
							#get_cell_tile_data(cell).modulate = Color(57.0 / 255.0, 115.0 / 255.0, 115.0 / 255.0, 1.0)
						#Global.SUIT.YELLOW:
							#get_cell_tile_data(cell).modulate = Color(255.0 / 255.0, 218.0 / 255.0, 108.0 / 255.0, 1.0)
						#Global.SUIT.RED:
							#get_cell_tile_data(cell).modulate = Color(182.0 / 255.0, 88.0 / 255.0, 76.0 / 255.0, 1.0)
						#_:
							#get_cell_tile_data(cell).modulate = Color(1.0, 1.0, 1.0, 1.0)
				#else:
					#get_cell_tile_data(cell).modulate = Color(1.0, 1.0, 1.0, 1.0)
