extends TextureRect
class_name Deck

@onready var label: Label = %Label

var _last_deck_size: int = -1

func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)

func sync_with_state(state: GameState, _action: Action) -> void:
	var current_size = state.deck.size()
	if current_size != _last_deck_size:
		label.text = str(current_size) + "/56"
		_last_deck_size = current_size