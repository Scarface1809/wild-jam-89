class_name MoveAction
extends Action

# Constants
const MOVE_TEXTURE: Texture = preload(Global.TEXTURE_UUIDS.ACTION_MOVE)

# Undo data
var _prev_pos: Vector2i

func can_execute(state: GameState) -> bool:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return false

	if not state.get_adjacent_tiles(unit.cell_pos).has(target_pos):
		return false

	if state.get_unit_at(target_pos):
		return false

	if source_card != null:
		var suit: Global.Suit = source_card.suit
		if suit != Global.Suit.GREEN and suit != state.get_tile_suit(target_pos):
			return false

	return true

func execute(state: GameState) -> void:
	var unit: UnitState = state.get_unit_by_id(unit_id)

	_prev_pos = unit.cell_pos
	unit.cell_pos = target_pos

	if source_card != null:
		state.hand.erase(source_card)

func undo(state: GameState) -> void:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	unit.cell_pos = _prev_pos

	if source_card != null:
		state.restore_card(source_card)

func get_target_positions(state: GameState) -> Array[Vector2i]:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return []
	return state.get_adjacent_tiles(unit.cell_pos)

func get_display_name() -> String:
	return "Move"

func get_icon_texture() -> Texture:
	return MOVE_TEXTURE
