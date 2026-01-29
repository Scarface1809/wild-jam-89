class_name MainGame
extends Node2D
## Main game controller

const BOARD_SIZE = 5

# Export Variables
@export var levels_data: Array[LevelData]
@export var deck: Array[CardData]

# Private Variables
var _current_level: int = 0

# OnReady Variables
@onready var _turn_engine: TurnEngine = %TurnEngine

func _ready() -> void:
	# Setup
	assert(Global.selected_unit != null, "A character unit must be selected")
	assert(levels_data.size() > 0, "At least one level is required")

	# Signals
	_turn_engine.battle_won.connect(_on_battle_won)
	_turn_engine.battle_lost.connect(_on_battle_lost)

	# Randomize
	randomize()

	_load_current_level()

# Private Methods
func _load_current_level() -> void:
	Global.round_changed.emit(_current_level)

	Global.game_state = _initialize_game_state(levels_data[_current_level])
	Global.game_state_changed.emit(Global.game_state, null)

	# Generate level
	_start_game(Global.game_state)

func _start_game(state: GameState) -> void:
	_turn_engine.start_battle(state)

func _initialize_game_state(level: LevelData) -> GameState:
	var state: GameState = GameState.new()
	state.board_size = Vector2i(BOARD_SIZE, BOARD_SIZE)
	state.groups = []
	state.tiles = {}

	_generate_board(state)

	_setup_units(state, level)

	_setup_deck(state)

	_validate_state(state)

	return state

func _generate_board(state: GameState) -> void:
	# Generate Board (balanced suits)
	var allowed_suits: Array[Global.Suit] = [
		Global.Suit.RED,
		Global.Suit.BLUE,
		Global.Suit.YELLOW
	]
	var total_tiles: int = state.board_size.x * state.board_size.y
	var suit_bag: Array[Global.Suit] = []
	var base: int = floori(total_tiles / float(allowed_suits.size()))
	var remainder: int = total_tiles % allowed_suits.size()
	for suit: Global.Suit in allowed_suits:
		for i: int in range(base):
			suit_bag.append(suit)
	allowed_suits.shuffle()
	for i: int in range(remainder):
		suit_bag.append(allowed_suits[i])
	suit_bag.shuffle()
	var index: int = 0
	for x: int in range(state.board_size.x):
		for y: int in range(state.board_size.y):
			state.tiles[Vector2i(x, y)] = suit_bag[index]
			index += 1

func _setup_units(state: GameState, level: LevelData) -> void:
	var spawner: UnitSpawner = UnitSpawner.new()
	
	var selected_character: UnitData = Global.selected_unit
	var player_group: GroupData = GroupData.new()
	player_group.init("Player", Global.GroupType.PLAYER, [selected_character])

	spawner.spawn_player_group(state, player_group)

	for group_data: GroupData in level.groups:
		spawner.spawn_enemy_group(state, group_data)
	
	state.active_group_index = 0
	state.active_unit_index = 0

func _setup_deck(state: GameState) -> void:
	var actions: Array[Action] = []
	for a: Action in Global.selected_unit.actions:
		if not a is MoveAction:
			actions.append(a)
	var current_deck: Array[CardData] = deck.duplicate()
	for action: Action in actions:
		for i: int in range(4):
			var card_data: CardData = CardData.new()
			card_data.action = action
			card_data.suit = Global.Suit.GREEN
			current_deck.append(card_data)
	state.deck = current_deck
	state.deck.shuffle()

	state.hand = []

func _validate_state(state: GameState) -> void:
	# Current game state musts for our game.
	assert(state.get_groups_by_type(Global.GroupType.PLAYER).size() == 1, "Only one player group is allowed")
	var player_group = state.get_groups_by_type(Global.GroupType.PLAYER)[0]
	assert(player_group.get_unit_count() == 1, "Player group must have exactly one unit")

#region Signal Handlers
func _on_battle_won() -> void:
	print("Level ", _current_level + 1, " won!")
	_current_level += 1

	if _current_level >= levels_data.size():
		print("🎉 All levels completed! You win the game!")
		var _name := Global.selected_unit.name
		if not Global.character_wins.has(_name):
			Global.character_wins[_name] = 0
		Global.character_wins[_name] += 1
		Global.save_game()
		await Global.game_controller.change_scene(Global.SCENE_UIDS.WIN_SCREEN, "", TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)
	else:
		print("➡ Loading next level...")
		_load_current_level()

func _on_battle_lost() -> void:
	print("❌ Player defeated. Returning to main menu.")
	await Global.game_controller.change_scene(Global.SCENE_UIDS.LOSE_SCREEN, "", TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)
#endregion

#region Debug
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
#endregion
