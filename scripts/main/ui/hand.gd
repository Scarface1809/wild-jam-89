class_name Hand
extends HBoxContainer
## This class is responsible for managing the player's hand of cards.

# Constants
const CARD_SCENE: PackedScene = preload(Global.SCENE_UIDS.CARD)

# Private Variables
var _cards: Array[Card] = []
var _highlighted_index: int = -1

func set_hand(hand_data: Array[CardData]) -> void:
	_clear()

	for i in range(hand_data.size()):
		var card: Card = CARD_SCENE.instantiate()
		card.set_card_data(hand_data[i])
		card.clicked.connect(func():
			_on_card_clicked(i)
		)
		add_child(card)
		_cards.append(card)

func set_enabled(enabled: bool) -> void:
	for card in _cards:
		card.disabled = not enabled

	if not enabled:
		_clear_highlight()

# Private methods
func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)
	Global.player_turn_started.connect(_on_player_turn_started)
	Global.player_turn_ended.connect(_on_player_turn_ended)

func sync_with_state(game_state: GameState) -> void:
	var hand: Array[CardData] = game_state.hand
	set_hand(hand)

func _on_player_turn_started() -> void:
	set_enabled(true)

func _on_player_turn_ended() -> void:
	set_enabled(false)

func _on_card_clicked(index: int) -> void:
	if _highlighted_index == index:
		_clear_highlight()
		Global.card_clicked.emit(-1)
		return

	_clear_highlight()
	_highlighted_index = index
	_cards[index].select()

	Global.card_clicked.emit(index)

func _clear_highlight() -> void:
	if _highlighted_index != -1:
		_cards[_highlighted_index].deselect()
		_highlighted_index = -1

func _clear() -> void:
	for c in _cards:
		c.queue_free()
	_cards.clear()
	_highlighted_index = -1
