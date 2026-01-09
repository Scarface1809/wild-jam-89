class_name MainGame
extends Node2D
# Docstring

# Signals

# Enums

# Constants

# Export Variables
@export var level_data: Array[LevelData]

# Public Variables

# Private Variables
var _current_level: int = 0

# OnReady Variables
@onready var _board: Board = %Board
@onready var _units_container: UnitsContainer = %UnitsContainer

func _ready() -> void:
	# Randomize
	randomize()

	# Generate level
	_generate_level()

	# Connect signals
	_units_container.battle_over.connect(_on_battle_over)

	_units_container.start_battle()

# Public Methods

# Private Methods
func _generate_level() -> void:
	var level = level_data[_current_level]

	# Generate board
	_board.generate_board()
	
	# Setup Units
	for group_data in level.groups:
		var unit_group: UnitGroup = UnitGroup.new(group_data)
		unit_group.request_spawn_position.connect(_on_unit_spawn_request)
		_units_container.add_child(unit_group)

func _on_battle_over(winning_group: UnitGroup) -> void:
	print("Battle over! Winner:", winning_group.name)

func _on_unit_spawn_request(unit: Unit, callback: Callable) -> void:
	var pos: Vector2i = _board.get_random_position(_units_container.get_all_unit_positions())
	callback.call(unit, pos)

# Sub-classes
