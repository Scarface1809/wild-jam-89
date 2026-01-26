class_name SystemController
extends Controller

func begin_turn(state: GameState) -> void:
	var unit: UnitState = state.get_active_unit()
	assert(unit != null, "No active unit for AI turn")
	var group: GroupState = state.get_group_by_id(unit.group_id)
	assert(group != null, "No group for active unit")

	# Auto Draw
	if group.type == Global.GroupType.PLAYER:
		if state.get_hand_size() == 0:
			var draw_action: DrawAction = DrawAction.new()
			draw_action.unit_id = -1
			draw_action.num_cards = 4
			action_chosen.emit(draw_action)
	
	# Deshield 
	if unit.shielded:
		var shield_action: ShieldAction = ShieldAction.new()
		shield_action.unit_id = -1
		shield_action.target_pos = unit.cell_pos
		action_chosen.emit(shield_action)

func end_turn(state: GameState) -> void:
	# Hazards
	for hazard: HazardState in state.get_hazards():
		if state.get_unit_at(hazard.cell_pos):
			var trap_action: TrapAction = TrapAction.new()
			trap_action.unit_id = -1
			trap_action.target_pos = hazard.cell_pos
			action_chosen.emit(trap_action)
