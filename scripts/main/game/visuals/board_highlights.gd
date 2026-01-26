class_name BoardHighlights
extends TileMapLayer
## This class is responsible for rendering the board highlights.

const ALTERNATIVE_TILE_ID = {
	"HIT": 0,
	"TARGETABLE": 1
}

var _state: GameState

func _ready() -> void:
	Global.card_selected.connect(_on_card_selected)

func sync_with_state(state: GameState, _action: Action) -> void:
	_state = state
	clear()

func _on_card_selected(index: int) -> void:
	clear()
	if _state == null:
		return
	
	if index < 0 or index >= _state.hand.size():
		return
	
	var card: CardData = _state.hand[index]
	if card.action == null:
		return
	
	var action: Action = card.action.duplicate()

	var active_unit: UnitState = _state.get_active_unit()
	if active_unit == null:
		return
	action.unit_id = active_unit.id
	action.source_card = card
	
	var target_positions: Array[Vector2i] = action.get_target_positions(_state)
	for pos: Vector2i in target_positions:
		var alternative_tile_id = ALTERNATIVE_TILE_ID.TARGETABLE
		action.target_pos = pos
		if action.can_execute(_state):
			alternative_tile_id = ALTERNATIVE_TILE_ID.HIT
		set_cell(pos, 0, Vector2i.ZERO, alternative_tile_id)