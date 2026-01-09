class_name Board
extends TileMapLayer
# Docstring

# Signals

# Enums

# Constants
const BOARD_SIZE: int = 5

# Export Variables

# Public Variables

# Private Variables

# OnReady Variables

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var pos = local_to_map(event.position)
		if _is_inside_board(pos):
			var tile_suit = get_cell_tile_data(pos).get_custom_data("Suit")
			assert(tile_suit != null, "Tile doesn't have a suit!")
			Global.board_click.emit(pos, tile_suit)

# Public Methods
func generate_board() -> void:
	# Clean TileMapLayer
	clear()
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			set_cell(Vector2i(x, y), randi_range(1, 4), Vector2i.ZERO)

func get_random_position(exclude_cells: Array[Vector2i] = []) -> Vector2i:
	var candidates: Array[Vector2i] = []

	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var cell = Vector2i(x, y)
			if not exclude_cells.has(cell):
				candidates.append(cell)

	if candidates.size() == 0:
		push_error("No valid positions left!")
		return Vector2i.ZERO

	var cell_pos = candidates[randi() % candidates.size()]
	# Convert cell coordinates to world position
	return map_to_local(cell_pos)

# Private Methods
func _is_inside_board(cell: Vector2i) -> bool:
	return (
		cell.x >= 0 and cell.x < BOARD_SIZE and
		cell.y >= 0 and cell.y < BOARD_SIZE
	)

# Sub-classes
