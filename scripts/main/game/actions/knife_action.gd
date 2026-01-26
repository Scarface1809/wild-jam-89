class_name KnifeAction
extends Action

# Constants
const KNIFE_TEXTURE: Texture = preload(Global.TEXTURE_UUIDS.ACTION_KNIFE)

# UNdo data
var _prev_pos: Vector2i
var _killed_unit: UnitState = null
var _removed_hazard: bool = false

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
	_prev_pos = unit.cell_pos

	var target_unit: UnitState = state.get_unit_at(target_pos)
	if target_unit != null:
		if target_unit.shielded:
			target_unit.shielded = false
		else:
			_killed_unit = target_unit
			state.get_group_by_id(target_unit.group_id).get_units().erase(target_unit)
			unit.cell_pos = target_pos
	else:
		_removed_hazard = true
		var hazard: HazardState = state.get_hazard_at(target_pos)
		state.hazards.erase(hazard.id)
		unit.cell_pos = target_pos

	if source_card:
		state.hand.erase(source_card)

func undo(state: GameState) -> void:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	unit.cell_pos = _prev_pos

	if _killed_unit:
		state.get_group_by_id(_killed_unit.group_id).add_unit(_killed_unit)

	if _removed_hazard:
		var next_id: int = state.get_next_hazard_id()
		state.hazards[next_id] = HazardState.new(next_id, target_pos)

	if source_card:
		state.restore_card(source_card)

func get_target_positions(state: GameState) -> Array[Vector2i]:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return []
	return state.get_adjacent_tiles(unit.cell_pos)

func get_display_name() -> String:
	return "Knife"

func get_icon_texture() -> Texture:
	return KNIFE_TEXTURE
