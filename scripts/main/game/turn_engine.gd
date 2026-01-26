class_name TurnEngine
extends Node

# Signals
signal turn_started(group: GroupState, unit: UnitState)
signal turn_ended(group: GroupState, unit: UnitState)
signal battle_won()
signal battle_lost()

@export var visuals: Visuals

# Onready Variables
@onready var player_controller: PlayerController = %PlayerController
@onready var ai_controller: AIController = %AIController
@onready var system_controller: SystemController = %SystemController

# Public Variables
var game_state: GameState

func _ready():
	assert(visuals != null, "Visuals reference is required")
	assert(player_controller != null, "Player controller reference is required")
	assert(ai_controller != null, "AI controller reference is required")
	# Connect signals
	player_controller.action_chosen.connect(_on_action_chosen)
	ai_controller.action_chosen.connect(_on_action_chosen)
	system_controller.action_chosen.connect(_on_action_chosen)
	turn_started.connect(func(group: GroupState, _unit: UnitState):
		Global.turn_started.emit(group, _unit))
	turn_ended.connect(func(group: GroupState, _unit: UnitState):
		Global.turn_ended.emit(group, _unit))

func start_battle(state: GameState) -> void:
	assert(state != null, "GameState cannot be null")
	game_state = state
	game_state.active_group_index = 0
	game_state.active_unit_index = 0
	player_controller.set_enabled(false)
	ai_controller.set_enabled(false)
	_next_turn()

func _next_turn() -> void:
	if _check_victory():
		return

	var unit: UnitState = game_state.get_active_unit()
	assert(unit != null, "Active unit cannot be null")
	var group: GroupState = game_state.get_active_group()
	assert(group != null, "Active group cannot be null")

	# Apply automatic start-of-turn actions (like draw / deshield)
	system_controller.begin_turn(game_state)

	# Wait for animations to finish ?????????
	# await visuals.animations_finished
	
	turn_started.emit(group, unit)

	# Delegate to controller
	match group.type:
		Global.GroupType.PLAYER:
			_process_player_turn()
		Global.GroupType.ENEMY:
			_process_ai_turn()
		_:
			push_error("Unknown group type: " + str(group.type))

func _process_player_turn() -> void:
	player_controller.set_enabled(true)
	player_controller.begin_turn(game_state)
	ai_controller.set_enabled(false)

func _process_ai_turn() -> void:
	ai_controller.set_enabled(true)
	ai_controller.begin_turn(game_state)
	player_controller.set_enabled(false)

func _end_unit_turn() -> void:
	var group: GroupState = game_state.get_active_group()
	assert(group != null, "Active group cannot be null")
	var unit: UnitState = game_state.get_active_unit()

	if unit:
		turn_ended.emit(group, unit)

	if _check_victory():
		return

	if unit == null:
		# Clamp index in case it now points past the end
		if game_state.active_unit_index >= group.units.size():
			game_state.active_unit_index = 0
			game_state.active_group_index += 1
	else:
		# Normal case: advance to next unit
		game_state.active_unit_index += 1

	# Finished all units in this group
	if game_state.active_unit_index >= group.units.size():
		game_state.active_unit_index = 0
		game_state.active_group_index += 1

	# Loop groups
	if game_state.active_group_index >= game_state.groups.size():
		game_state.active_group_index = 0

	call_deferred("_next_turn")

func _on_action_chosen(action: Action) -> void:
	# Block controllers
	ai_controller.set_enabled(false)
	player_controller.set_enabled(false)

	if action == null:
		return
	
	if not action.can_execute(game_state):
		return

	action.execute(game_state)
	print(game_state)
	print(action)
	Global.game_state_changed.emit(game_state, action)
	await visuals.animations_finished

	# Apply automatic end-of-turn actions (like traps) here is the right place?
	system_controller.end_turn(game_state)

	# If action is not system action, end turn
	if action.unit_id != -1:
		_end_unit_turn()

func _check_victory() -> bool:
	assert(game_state != null, "GameState not initialized")
	var player_alive: bool = game_state.get_units_by_group_type(Global.GroupType.PLAYER).size() > 0
	var enemy_alive: bool = game_state.get_units_by_group_type(Global.GroupType.ENEMY).size() > 0

	if not player_alive:
		battle_lost.emit()
		return true
	elif not enemy_alive:
		battle_won.emit()
		return true

	return false
