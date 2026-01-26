class_name ShieldAction
extends Action

# Constants
const SHIELD_TEXTURE: Texture = preload(Global.TEXTURE_UUIDS.ACTION_SHIELD)

# Undo data
var _prev_state: bool = false

func can_execute(state: GameState) -> bool:
	if unit_id != -1:
		var unit: UnitState = state.get_unit_by_id(unit_id)
		if unit == null:
			return false

		var target: UnitState = state.get_unit_at(target_pos)
		if target == null:
			return false
		
		if target.shielded:
			return false

		if source_card != null:
			var suit: Global.Suit = source_card.suit
			if suit != Global.Suit.GREEN and suit != state.get_tile_suit(target_pos):
				return false

		return true
	else:
		var target: UnitState = state.get_unit_at(target_pos)
		if target == null:
			return false
		
		if !target.shielded:
			return false
		
		return true

func execute(state: GameState) -> void:
	if unit_id != -1:
		var target: UnitState = state.get_unit_at(target_pos)
		_prev_state = target.shielded
		target.shielded = true

		if source_card:
			state.hand.erase(source_card)
	else:
		var target: UnitState = state.get_unit_at(target_pos)
		_prev_state = target.shielded
		target.shielded = false

func undo(state: GameState) -> void:
	var target: UnitState = state.get_unit_at(target_pos)
	target.shielded = _prev_state

	if source_card:
		state.restore_card(source_card)

func get_target_positions(state: GameState) -> Array[Vector2i]:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return []
	
	var group: GroupState = state.get_group_by_id(unit.group_id)

	var result: Array[Vector2i] = []
	for u: UnitState in group.get_units():
		result.append(u.cell_pos)
	return result

func get_display_name() -> String:
	return "Shield"

func get_icon_texture() -> Texture:
	return SHIELD_TEXTURE
