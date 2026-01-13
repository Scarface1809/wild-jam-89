class_name Board
extends TileMapLayer
## This class is responsible for managing the game board.

# Constants
const BOARD_SIZE: int = 5

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var world_pos = event.position # mouse position in world coordinates
		var cell: Vector2i = world_to_cell(world_pos)
		if _is_inside_board(cell):
			Global.tile_clicked.emit(cell) # emit the cell (map coordinates)

# Public Methods
## Renders the board based on the game state
# TODO: MAKE SYNC INSTEAD
func initialize_from_state(state: GameState) -> void:
	clear()
	for tile: Vector2i in state.tiles:
		set_cell(tile, state.tiles.get(tile) + 1, Vector2i.ZERO)

func cell_to_world(cell_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(cell_pos))

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))

# Private Methods
func _is_inside_board(cell: Vector2i) -> bool:
	return (
		cell.x >= 0 and cell.x < BOARD_SIZE and
		cell.y >= 0 and cell.y < BOARD_SIZE
	)
