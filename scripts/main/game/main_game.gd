class_name MainGame
extends Node2D
## Main game controller

# Export Variables
@export var levels_data: Array[LevelData]
@export var deck: Array[CardData]

# Public Variables

# Private Variables
var _current_level: int = 0

# OnReady Variables
@onready var _board: Board = %Board
@onready var _seats: Seats = %Seats
@onready var _units_container: UnitsContainer = %UnitsContainer
@onready var _battle_controller: BattleController = %BattleController

func _ready() -> void:
	# Setup
	assert(levels_data.size() > 0, "At least one level is required")

	# Randomize
	randomize()

	var state: GameState = _initialize_game_state(levels_data[_current_level])

	# Setup Visual Layers
	# TODO: change to emit state changed
	_seats.initialize_from_state(state)
	_board.initialize_from_state(state)
	_units_container.sync_with_state(state, null)
	
	# Generate level
	_start_game(state)

# Private Methods
func _start_game(state: GameState) -> void:
	# Pass game state to components. TODO: AI controller & RuleSystem/ActionController
	_battle_controller.game_state = state
	# Start Game
	_battle_controller.start_battle()

func _initialize_game_state(level: LevelData) -> GameState:
	var state: GameState = GameState.new()
	state.board_size = Vector2i(_board.BOARD_SIZE, _board.BOARD_SIZE)
	state.groups = []
	state.tiles = {}
	
	# Generate Board (balanced suits)
	var allowed_suits: Array[Global.SUIT] = [
		Global.SUIT.RED,
		Global.SUIT.BLUE,
		Global.SUIT.YELLOW
	]
	var total_tiles := state.board_size.x * state.board_size.y
	var suit_bag: Array[Global.SUIT] = []
	var base := floori(total_tiles / float(allowed_suits.size()))
	var remainder := total_tiles % allowed_suits.size()
	for suit in allowed_suits:
		for i in range(base):
			suit_bag.append(suit)
	allowed_suits.shuffle()
	for i in range(remainder):
		suit_bag.append(allowed_suits[i])
	suit_bag.shuffle()
	var index := 0
	for x in range(state.board_size.x):
		for y in range(state.board_size.y):
			state.tiles[Vector2i(x, y)] = suit_bag[index]
			index += 1

	# Create GroupStates
	for group_data in level.groups:
		var group_state = GroupState.new(state, group_data)
		state.groups.append(group_state)

	state.active_group_index = 0
	state.active_unit_index = 0

	# Setup Deck
	state.deck = deck.duplicate()
	state.deck.shuffle()

	state.hand = []

	_validate_state(state)

	return state

func _validate_state(state: GameState) -> void:
	assert(state.get_num_groups(Global.GROUP_TYPE.PLAYER) == 1, "Only one player group is allowed")
	var player_group = state.get_groups().filter(func(g): return g.type == Global.GROUP_TYPE.PLAYER)[0]
	assert(player_group.get_unit_count() == 1, "Player group must have exactly one unit")
	assert(state.get_num_units(Global.GROUP_TYPE.ENEMY) <= 7, "Only 7 enemy units are allowed")
