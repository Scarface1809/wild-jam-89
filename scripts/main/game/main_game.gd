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
@onready var _units_container: UnitsContainer = %UnitsContainer
@onready var _battle_controller: BattleController = %BattleController

func _ready() -> void:
	# Setup
	assert(levels_data.size() > 0, "At least one level is required")

	# Randomize
	randomize()

	# Generate level
	_start_level(levels_data[_current_level])

# Private Methods
func _start_level(level: LevelData) -> void:
	var state: GameState = _initialize_game_state(level)

	# Setup Visual Layers
	_board.initialize_from_state(state)
	_units_container.initialize_from_state(state)

	# Pass game state to components. TODO: AI controller & RuleSystem/ActionController
	_battle_controller.game_state = state

	# Start Game
	_battle_controller.start_battle()

func _initialize_game_state(level: LevelData) -> GameState:
	var state: GameState = GameState.new()
	state.board_size = Vector2i(_board.BOARD_SIZE, _board.BOARD_SIZE)
	state.groups = []
	state.tiles = {}
	
	# Generate Board
	for x in range(state.board_size.x):
		for y in range(state.board_size.y):
			var suit := randi_range(0, 2)
			state.tiles[Vector2i(x, y)] = suit as Global.SUIT

	# Create GroupStates
	var next_unit_id = 0
	for group_index: int in range(level.groups.size()):
		var group_data: GroupData = level.groups[group_index]
		var units: Array[UnitState] = []
		for unit_data: UnitData in group_data.units:
			var unit_state = UnitState.new(next_unit_id, group_index, state.get_random_free_tile(), unit_data)
			next_unit_id += 1
			units.append(unit_state)

		var group_state = GroupState.new(group_index, group_data.type, units)
		state.groups.append(group_state)

	state.active_group_index = 0
	state.active_unit_index = 0

	# Setup Deck
	state.deck = deck.duplicate()
	state.deck.shuffle()

	# TODO: Setup Hand
	state.hand = []

	return state
