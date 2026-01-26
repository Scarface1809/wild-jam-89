class_name PlayerController
extends Controller
## Player controller for handling player input and actions

var _state: GameState
var _selected_card_index: int = -1

func _ready() -> void:
	Global.tile_selected.connect(_on_tile_selected)
	Global.card_selected.connect(_on_card_selected)
	Global.shuffle_requested.connect(_on_shuffle_requested)
	Global.skip_requested.connect(_on_skip_requested)

func begin_turn(state: GameState):
	assert(state != null, "GameState cannot be null")
	_state = state
	_selected_card_index = -1

# Signal Handlers
func _on_card_selected(index: int) -> void:
	if not _enabled:
		return

	if index < 0 or index >= _state.hand.size():
		_selected_card_index = -1
		return

	_selected_card_index = index

func _on_tile_selected(cell_pos: Vector2i):
	if not _enabled:
		return

	if _selected_card_index < 0:
		return

	var unit_state: UnitState = _state.get_active_unit()
	if unit_state == null:
		return
	
	if not _state.has_tile(cell_pos):
		return

	var card: CardData = _state.hand[_selected_card_index]

	var action: Action = card.action.duplicate()
	action.unit_id = unit_state.id
	action.target_pos = cell_pos
	action.source_card = card

	if action.can_execute(_state):
		action_chosen.emit(action)

func _on_skip_requested() -> void:
	if not _enabled:
		return

	var unit_state: UnitState = _state.get_active_unit()
	if unit_state == null:
		return

	var skip_action: SkipAction = SkipAction.new()
	skip_action.unit_id = unit_state.id

	if skip_action.can_execute(_state):
		action_chosen.emit(skip_action)

func _on_shuffle_requested() -> void:
	if not _enabled:
		return

	var unit_state: UnitState = _state.get_active_unit()
	if unit_state == null:
		return

	var shuffle_action: ShuffleAction = ShuffleAction.new()
	shuffle_action.unit_id = unit_state.id
	shuffle_action.num_cards = 4

	if shuffle_action.can_execute(_state):
		action_chosen.emit(shuffle_action)
