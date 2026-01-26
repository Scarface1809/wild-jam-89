class_name AIController
extends Controller
## AI controller for handling AI input and actions

@export var action_odds: float = 0.1

func begin_turn(state: GameState) -> void:
	assert(_enabled, "AI controller not enabled")
	var unit: UnitState = state.get_active_unit()
	assert(unit != null, "No active unit for AI turn")
	var group: GroupState = state.get_active_group()
	assert(group != null, "No active group for AI turn")
	assert(group.type == Global.GroupType.ENEMY, "AI controller can only handle enemy groups")

	var enemy_units: Array[UnitState] = state.get_units_by_group_type(Global.GroupType.PLAYER)
	var free_adjacent_tiles: Array[Vector2i] = state.get_adjacent_tiles(unit.cell_pos).filter(
		func(tile: Vector2i) -> bool:
			return state.get_unit_at(tile) == null
	)

	# --- Try to attack first ---
	for template_action: Action in unit.actions:
		# Assuming the unit has only one attack (Knife, Gun, etc)
		if template_action is KnifeAction or template_action is GunAction or template_action is PushAction:
			for enemy_unit: UnitState in enemy_units:
				var attack_action = template_action.duplicate()
				attack_action.unit_id = unit.id
				attack_action.target_pos = enemy_unit.cell_pos
				if attack_action.can_execute(state):
					action_chosen.emit(attack_action)
					return
		if template_action is TeleportAction or template_action is TrapAction:
			if randf() < action_odds:
				for enemy_unit: UnitState in enemy_units:
					var attack_action = template_action.duplicate()
					attack_action.unit_id = unit.id
					attack_action.target_pos = enemy_unit.cell_pos
					if attack_action.can_execute(state):
						action_chosen.emit(attack_action)
						return

	# --- Try to move if attack not possible ---
	if !free_adjacent_tiles.is_empty():
		for template_action in unit.actions:
			if template_action is MoveAction:
				var move_action = template_action.duplicate()
				move_action.unit_id = unit.id
				move_action.target_pos = free_adjacent_tiles.pick_random()
				if move_action.can_execute(state):
					action_chosen.emit(move_action)
					return

	# --- Fallback: skip ---
	var skip_action = SkipAction.new()
	skip_action.unit_id = unit.id
	action_chosen.emit(skip_action)
