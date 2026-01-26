@abstract class_name Action
extends Resource

# -1 means system/global action
var unit_id: int = -1
var target_pos: Vector2i = Vector2i(-1, -1)
var source_card: CardData = null

@abstract func can_execute(state: GameState) -> bool

@abstract func execute(state: GameState) -> void

@abstract func undo(state: GameState) -> void

@abstract func get_target_positions(state: GameState) -> Array[Vector2i]

@abstract func get_display_name() -> String

@abstract func get_icon_texture() -> Texture

func _to_string() -> String:
	var s := "──────── ACTION ────────\n"
	s += "Unit ID: " + str(unit_id) + "\n"
	s += "Target Pos: " + str(target_pos) + "\n"
	s += "Name: " + get_display_name() + "\n"
	s += "────────────────────────"
	return s
