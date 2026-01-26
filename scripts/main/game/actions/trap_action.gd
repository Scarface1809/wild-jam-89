class_name TrapAction
extends Action

# Constants
const TRAP_TEXTURE: Texture = preload(Global.TEXTURE_UUIDS.ACTION_TRAP)

# Undo data
var _killed_unit: UnitState
var _killed_group: int

func can_execute(state: GameState) -> bool:
	if unit_id == -1:
		# Trap resolving
		var u: UnitState = state.get_unit_at(target_pos)
		if u == null:
			return false
		if not state.has_hazard(target_pos):
			return false
		return true
	else:
		# Trap placing logic
		var unit: UnitState = state.get_unit_by_id(unit_id)
		if unit == null:
			return false
		
		if state.has_hazard(target_pos) or state.get_unit_at(target_pos):
			return false
		
		if source_card != null:
			var suit: Global.Suit = source_card.suit
			if suit != Global.Suit.GREEN and suit != state.get_tile_suit(target_pos):
				return false
		
		return true

func execute(state: GameState) -> void:
	if unit_id == -1:
		var u: UnitState = state.get_unit_at(target_pos)
		var hazard: HazardState = state.get_hazard_at(target_pos)
		_killed_unit = u
		_killed_group = u.group_id
		state.get_group_by_id(u.group_id).get_units().erase(u)
		state.hazards.erase(hazard.id)
	else:
		var next_id: int = state.get_next_hazard_id()
		state.hazards[next_id] = HazardState.new(next_id, target_pos)
		state.hand.erase(source_card)

func undo(state: GameState) -> void:
	if unit_id == -1:
		state.get_group_by_id(_killed_group).add_unit(_killed_unit)
		var next_id: int = state.get_next_hazard_id()
		state.hazards[next_id] = HazardState.new(next_id, target_pos)
	else:
		var hazard: HazardState = state.get_hazard_at(target_pos)
		state.hazards.erase(hazard.id)
		state.hand.append(source_card)

func get_target_positions(state: GameState) -> Array[Vector2i]:
	var unit: UnitState = state.get_unit_by_id(unit_id)
	if unit == null:
		return []
	return state.get_adjacent_tiles(unit.cell_pos)

func get_display_name() -> String:
	return "Trap"

func get_icon_texture() -> Texture:
	return TRAP_TEXTURE
