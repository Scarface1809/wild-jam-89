class_name TeleportAction
extends Action

# Constants
const TELEPORT_TEXTURE: Texture = preload(Global.TEXTURE_UUIDS.ACTION_TELEPORT)

# Undo data
var _prev_pos: Vector2i
var _swapped_unit: UnitState = null
var _swapped_hazard: bool = false

func can_execute(state: GameState) -> bool:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return false

	var target: UnitState = state.get_unit_at(target_pos)
	if not state.has_hazard(target_pos) and not target:
		return false
	
	if source_card != null:
		var suit: Global.Suit = source_card.suit
		if suit != Global.Suit.GREEN and suit != state.get_tile_suit(target_pos):
			return false

	return true

func execute(state: GameState) -> void:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	_prev_pos = unit.cell_pos

	var other: UnitState = state.get_unit_at(target_pos)
	if other != null:
		_swapped_unit = other
		other.cell_pos = _prev_pos
		unit.cell_pos = target_pos
	else:
		_swapped_hazard = true
		unit.cell_pos = target_pos
		state.get_hazard_at(target_pos).cell_pos = _prev_pos

	if source_card:
		state.hand.erase(source_card)

func undo(state: GameState) -> void:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	unit.cell_pos = _prev_pos

	if _swapped_unit:
		_swapped_unit.cell_pos = target_pos

	if _swapped_hazard:
		state.get_hazard_at(_prev_pos).cell_pos = target_pos

	if source_card:
		state.restore_card(source_card)

func get_target_positions(state: GameState) -> Array[Vector2i]:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return []

	var result: Array[Vector2i] = []

	for x in range(state.board_size.x):
		for y in range(state.board_size.y):
			var cell = Vector2i(x, y)

			if cell == unit.cell_pos:
				continue

			if state.get_unit_at(cell) or state.has_hazard(cell):
				result.append(cell)

	return result

func get_display_name() -> String:
	return "Teleport"

func get_icon_texture() -> Texture:
	return TELEPORT_TEXTURE
