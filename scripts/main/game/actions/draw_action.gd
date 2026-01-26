class_name DrawAction
extends Action

var num_cards: int = 4

func can_execute(state: GameState) -> bool:
	return not state.is_deck_empty()

func execute(state: GameState) -> void:
	for i: int in range(num_cards):
		var card: CardData = state.deck.pop_back()
		if card:
			state.hand.append(card)

func undo(state: GameState) -> void:
	for i: int in range(num_cards):
		var card: CardData = state.hand.pop_back()
		if card:
			state.deck.append(card)

func get_target_positions(_state: GameState) -> Array[Vector2i]:
	return []

func get_display_name() -> String:
	return "Draw"

func get_icon_texture() -> Texture:
	return null
