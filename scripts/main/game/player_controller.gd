class_name PlayerController
extends Node
## Reacts to turns and player input to choose actions

signal action_chosen(action: Action)

var _state: GameState
var _selected_card_index: int = -1
var _enabled := false

func _ready() -> void:
	Global.tile_clicked.connect(_on_tile_clicked)
	Global.card_clicked.connect(_on_card_clicked)
	Global.shuffle_request.connect(_on_shuffle_request)

func set_enabled(enabled: bool) -> void:
	_enabled = enabled

func begin_turn(state: GameState):
	_state = state
	_selected_card_index = -1

# Signal Handlers
func _on_tile_clicked(cell_pos: Vector2i):
	var unit_state: UnitState = _state.get_active_unit()
	var card: CardData = _state.hand[_selected_card_index]

	if not _enabled:
		push_warning("Player controller not enabled")
		return

	if unit_state == null:
		push_warning("No unit found")
		return

	if _selected_card_index < 0:
		push_warning("No card selected")
		return

	var action: Action = Action.new()
	action.type = card.action_type
	action.unit_id = unit_state.id
	action.target_pos = cell_pos
	action.source_card = card

	action_chosen.emit(action)

func _on_shuffle_request() -> void:
	if not _enabled:
		push_warning("Player controller not enabled")
		return

	var action: Action = Action.new()
	action.type = Global.ACTION_TYPE.RESHUFFLE
	action.num_cards = 4

	action_chosen.emit(action)

func _on_card_clicked(index: int) -> void:
	if not _enabled:
		push_warning("Player controller not enabled")
		return

	if index < 0 or index >= _state.hand.size():
		_selected_card_index = -1
		return

	_selected_card_index = index

	# Debug
	var card: CardData = _state.hand[index]

	print("[PlayerController] Card clicked:")
	print("  Index:", index)
	print("  Action:", card.action_type)
	print("  Suit:", card.suit)
