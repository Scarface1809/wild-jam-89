class_name PushAction
extends Action

# Constants
const PUSH_TEXTURE: Texture = preload(Global.TEXTURE_UUIDS.ACTION_PUSH)

# Undo data
var _prev_unit_pos: Vector2i
var _prev_target_pos: Vector2i
var _pushed_entity = null
var _edge_pos: Vector2i

func can_execute(state: GameState) -> bool:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return false

	if not state.get_adjacent_tiles(unit.cell_pos).has(target_pos):
		return false

	var target: UnitState = state.get_unit_at(target_pos)
	if not state.has_hazard(target_pos) and not target:
		return false

	if target != null and (target.group_id == unit.group_id or target.shielded):
		return false

	if source_card != null:
		var suit: Global.Suit = source_card.suit
		if suit != Global.Suit.GREEN and suit != state.get_tile_suit(target_pos):
			return false

	return true

func execute(state: GameState) -> void:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	var target_unit: UnitState = state.get_unit_at(target_pos)
	var hazard: HazardState = state.get_hazard_at(target_pos)

	_prev_unit_pos = unit.cell_pos
	_pushed_entity = null

	# Compute edge of board
	_edge_pos = target_pos
	if unit.cell_pos.y == target_pos.y:
		_edge_pos.x = state.board_size.x - 1 if target_pos.x > unit.cell_pos.x else 0
	else:
		_edge_pos.y = state.board_size.y - 1 if target_pos.y > unit.cell_pos.y else 0

	# Apply push
	if target_unit:
		_prev_target_pos = target_unit.cell_pos
		_pushed_entity = target_unit
		target_unit.cell_pos = _edge_pos
	elif hazard:
		_prev_target_pos = hazard.cell_pos
		_pushed_entity = hazard
		hazard.cell_pos = _edge_pos

	if source_card:
		state.hand.erase(source_card)

func undo(state: GameState) -> void:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if _pushed_entity:
		_pushed_entity.cell_pos = _prev_target_pos
	else:
		var hazard_id: int = state.get_hazard_id_at(_prev_target_pos)
		state.hazards[hazard_id] = HazardState.new(hazard_id, _prev_target_pos)

	if source_card:
		state.restore_card(source_card)

	unit.cell_pos = _prev_unit_pos

func get_target_positions(state: GameState) -> Array[Vector2i]:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return []
	return state.get_adjacent_tiles(unit.cell_pos)

func get_display_name() -> String:
	return "Push"

func get_icon_texture() -> Texture:
	return PUSH_TEXTURE
