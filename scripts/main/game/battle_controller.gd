class_name BattleController
extends Node
## Owns game logic, rules, and state of selection. Also controls turn order.

# Export Variables
@export var rule_system: RuleSystem
@export var player_controller: PlayerController
@export var ai_controller: AIController

# Public Variables
var game_state: GameState

func _ready():
	assert(rule_system != null, "Rule system reference is required")
	assert(player_controller != null, "Player controller reference is required")
	assert(ai_controller != null, "AI controller reference is required")
	# Connect signals
	player_controller.action_chosen.connect(_on_action_chosen)
	ai_controller.action_chosen.connect(_on_action_chosen)

func start_battle():
	game_state.reset_turn()
	_next_turn()

func _next_turn():
	var active_group: GroupState = game_state.get_active_group()
	var active_unit: UnitState = game_state.get_active_unit()
	assert(active_group != null, "No active group")
	assert(active_unit != null, "No active unit")

	# Player Group
	if active_group.type == Global.GROUP_TYPE.PLAYER:
		_start_player_turn()
	else:
		_start_ai_turn()

# Every Action ends the turn. If different behaviour change here 
func _on_action_chosen(action: Action):
	if not rule_system.can_apply(game_state, action):
		print("Action rejected by RuleSystem")
		return

	rule_system.apply(game_state, action)

	_debug_print_action(action)

	Global.game_state_changed.emit(game_state)
	_end_turn()

func _end_turn():
	var group: GroupState = game_state.get_active_group()
	var unit: UnitState = game_state.get_active_unit()
	assert(group != null, "No active group")
	assert(unit != null, "No active unit")

	print("◀ TURN END | Group ", group.id, " | Unit ", unit.id)

	if group.type == Global.GROUP_TYPE.PLAYER:
		Global.player_turn_ended.emit()

	if game_state.has_next_unit():
		game_state.next_unit()
	else:
		game_state.next_group()
	_next_turn()

func _start_player_turn() -> void:
	# Turn-based state mutation belongs here
	if game_state.hand.is_empty():
		print("Drawing cards...")
		game_state.draw_cards(4)
		Global.game_state_changed.emit(game_state)

	# Announce turn start (UI reacts)
	Global.player_turn_started.emit()

	print("▶ Player TURN | Group ", game_state.get_active_group().id, " | Unit ", game_state.get_active_unit().id)

	# Activate controller
	player_controller.begin_turn(game_state)

func _start_ai_turn() -> void:
	print("▶ AI TURN | Group ", game_state.get_active_group().id, " | Unit ", game_state.get_active_unit().id)
	ai_controller.begin_turn(game_state)

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
