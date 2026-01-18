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
@onready var _highlights: BoardHighlights = %Highlights
@onready var _seats: Seats = %Seats
@onready var _units_container: UnitsContainer = %UnitsContainer
@onready var _battle_controller: BattleController = %BattleController

func _ready() -> void:
	# Setup
	assert(Global.selected_unit != null, "A player unit must be selected")
	assert(levels_data.size() > 0, "At least one level is required")

	# Signals
	_battle_controller.battle_won.connect(_on_battle_won)
	_battle_controller.battle_lost.connect(_on_battle_lost)

	# Randomize
	randomize()

	_load_current_level()

# Private Methods
func _start_game(state: GameState) -> void:
	# Pass game state to components. TODO: AI controller & RuleSystem/ActionController
	_battle_controller.game_state = state
	# Start Game
	_battle_controller.start_battle()

func _load_current_level() -> void:
	Global.round_changed.emit(_current_level)
	var state: GameState = _initialize_game_state(levels_data[_current_level])

	# Setup Visual Layers
	# TODO: change to emit state changed
	_seats.initialize_from_state(state)
	_board.initialize_from_state(state)
	_highlights.sync_with_state(state, null)
	_units_container.sync_with_state(state, null)

	# Generate level
	_start_game(state)

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
	# First, add the **player group** using the selected unit
	var player_unit_data: UnitData = Global.selected_unit
	var player_group_data := GroupData.new()
	player_group_data.name = "Player"
	player_group_data.type = Global.GROUP_TYPE.PLAYER
	player_group_data.units = [player_unit_data]
	
	var board_center := Vector2i(floori(state.board_size.x / 2.0), floori(state.board_size.y / 2.0))

	var player_group_state = GroupState.new(state, player_group_data, [board_center])
	state.groups.append(player_group_state)

	# Then, add the **enemy groups** from level data
	for group_data in level.groups:
		var group_state = GroupState.new(state, group_data, [])
		state.groups.append(group_state)

	state.active_group_index = 0
	state.active_unit_index = 0

	# Setup Deck
	var action_types: Array[Global.ACTION_TYPE] = player_unit_data.actions.duplicate()
	var current_deck := deck.duplicate()
	action_types.erase(Global.ACTION_TYPE.MOVE)
	for action_type in action_types:
		for i in range(4):
			var card_data := CardData.new()
			card_data.action_type = action_type
			card_data.suit = Global.SUIT.GREEN
			current_deck.append(card_data)
	
	state.deck = current_deck
	state.deck.shuffle()

	state.hand = []

	_validate_state(state)

	return state

func _validate_state(state: GameState) -> void:
	assert(state.get_num_groups(Global.GROUP_TYPE.PLAYER) == 1, "Only one player group is allowed")
	var player_group = state.get_groups().filter(func(g): return g.type == Global.GROUP_TYPE.PLAYER)[0]
	assert(player_group.get_unit_count() == 1, "Player group must have exactly one unit")
	assert(state.get_num_units(Global.GROUP_TYPE.ENEMY) <= 7, "Only 7 enemy units are allowed")

func _on_battle_won() -> void:
	print("Level ", _current_level + 1, " won!")
	_current_level += 1

	if _current_level >= levels_data.size():
		print("🎉 All levels completed! You win the game!")
		Global.character_wins[Global.selected_unit.name] += 1
		Global.save_game()
		await Global.game_controller.change_scene(Global.SCENE_UIDS.WIN_SCREEN, "", TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)
	else:
		print("➡ Loading next level...")
		_load_current_level()

func _on_battle_lost() -> void:
	print("❌ Player defeated. Returning to main menu.")
	await Global.game_controller.change_scene(Global.SCENE_UIDS.LOSE_SCREEN, "", TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("level_1"):
		_current_level = 0
		_load_current_level()
	elif event.is_action_pressed("level_2"):
		_current_level = 1
		_load_current_level()
	elif event.is_action_pressed("level_3"):
		_current_level = 2
		_load_current_level()
	elif event.is_action_pressed("level_4"):
		_current_level = 3
		_load_current_level()
	elif event.is_action_pressed("level_5"):
		_current_level = 4
		_load_current_level()
