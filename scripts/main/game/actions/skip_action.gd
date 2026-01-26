class_name SkipAction
extends Action

func can_execute(_state: GameState) -> bool:
	return true

func execute(_state: GameState) -> void:
	pass

func undo(_state: GameState) -> void:
	pass

func get_target_positions(_state: GameState) -> Array[Vector2i]:
	return []

func get_display_name() -> String:
	return "Skip"

func get_icon_texture() -> Texture:
	return null
