class_name BattleController
extends Node
## Owns game logic, rules, and state of selection. Also controls turn order.
## This also reads the game state and writes but for the turn order.
## Additonally connects emits signals for when the game state changes.

# Signals
signal battle_won()
signal battle_lost()
signal turn_started(group: GroupState, unit: UnitState)
signal turn_ended(group: GroupState, unit: UnitState)

# Export Variables
@export var rule_system: RuleSystem
@export var units_container: UnitsContainer
@export var player_controller: PlayerController
@export var ai_controller: AIController

# Public Variables
var game_state: GameState

func _ready():
	assert(rule_system != null, "Rule system reference is required")
	assert(player_controller != null, "Player controller reference is required")
	assert(ai_controller != null, "AI controller reference is required")
	assert(units_container != null, "Units container reference is required")
	# Connect signals
	player_controller.action_chosen.connect(_on_action_chosen)
	ai_controller.action_chosen.connect(_on_action_chosen)
	turn_started.connect(func(group: GroupState, _unit: UnitState):
		if group.type == Global.GROUP_TYPE.PLAYER:
			Global.player_turn_started.emit())
	turn_ended.connect(func(group: GroupState, _unit: UnitState):
		if group.type == Global.GROUP_TYPE.PLAYER:
			Global.player_turn_ended.emit())

func start_battle():
	game_state.reset_turn()
	_next_turn()

func _next_turn():
	# Check if there are any units left
	if !(game_state.get_group_count() > 0 and game_state.get_active_group().get_unit_count() > 0):
		return

	var active_group: GroupState = game_state.get_active_group()
	var active_unit: UnitState = game_state.get_active_unit()

	turn_started.emit(active_group, active_unit)

	# Player Group
	if active_group.type == Global.GROUP_TYPE.PLAYER:
		_process_player_turn(active_group, active_unit)
	else:
		_process_ai_turn(active_group, active_unit)

# Every Action ends the turn. If different behaviour change here 
func _on_action_chosen(action: Action):
	if not rule_system.can_apply(game_state, action):
		push_error("Action rejected by RuleSystem: " + str(action.type))
		return

	rule_system.apply(game_state, action)
	_debug_print_action(action)
	Global.game_state_changed.emit(game_state)

	await units_container.animations_finished

	_end_turn()

func _end_turn():
	var group: GroupState = game_state.get_active_group()
	var unit: UnitState = game_state.get_active_unit()
	assert(group != null, "No active group")
	assert(unit != null, "No active unit")

	print("◀ TURN END | Group ", group.id, " | Unit ", unit.id)
	turn_ended.emit(group, unit)

	if _check_victory_conditions():
		return

	if game_state.has_next_unit():
		game_state.next_unit()
	else:
		game_state.next_group()
	_next_turn()

func _process_player_turn(group: GroupState, unit: UnitState) -> void:
	# Auto-draw rule
	_handle_auto_draw()

	print("▶ Player TURN | Group ", group.id, " | Unit ", unit.id)
	player_controller.begin_turn(game_state)

func _handle_auto_draw():
	if game_state.hand.is_empty():
		var draw_action = Action.new()
		draw_action.type = Global.ACTION_TYPE.DRAW
		draw_action.num_cards = 4 # Draw 4 cards
		draw_action.forced = true

		if rule_system.can_apply(game_state, draw_action):
			rule_system.apply(game_state, draw_action)
			Global.game_state_changed.emit(game_state)
		else:
			# No cards left = loss
			battle_lost.emit()
			return

func _process_ai_turn(group: GroupState, unit: UnitState) -> void:
	print("▶ AI TURN | Group ", group.id, " | Unit ", unit.id)
	ai_controller.begin_turn(game_state)

func _check_victory_conditions() -> bool:
	var player_alive := game_state.has_units(Global.GROUP_TYPE.PLAYER)
	var enemy_alive := game_state.has_units(Global.GROUP_TYPE.ENEMY)

	if not player_alive:
		print("❌ Player defeated")
		battle_lost.emit()
		return true

	if not enemy_alive:
		print("🏆 Player victorious")
		battle_won.emit()
		return true

	return false

# Utils
func _debug_print_action(action: Action) -> void:
	var group := game_state.get_active_group()
	var unit := game_state.get_unit_by_id(action.unit_id)

	print("──────── ACTION ────────")
	print("Group ID: ", group.id)
	print("Unit ID: ", str(unit.id) if unit != null else "NULL")
	print("Action Type: ", action.type)
	print("Target Pos: ", action.target_pos)

	if action.source_card != null:
		print("Source Card Type: ", action.source_card.action_type, " | Suit: ", action.source_card.suit)
	else:
		print("Source Card: NONE")

	print("Hand size now: ", game_state.hand.size())
	print("────────────────────────")
