class_name Hand
extends Control
## This class is responsible for managing the player's hand of cards.

# Constants
const CARD_SCENE: PackedScene = preload(Global.SCENE_UIDS.CARD)

@export var height_curve: Curve
@export var rotation_curve: Curve
@export var max_rotation_degrees := 20.0
@export var card_spacing := 90.0
@export var y_offset := -40.0

# Private Variables
var _cards: Array[Card] = []
var _highlighted_index: int = -1
var _enabled := true

func set_hand(hand_data: Array[CardData]) -> void:
	_clear()

	for i in range(hand_data.size()):
		var card: Card = CARD_SCENE.instantiate()
		card.disabled = not _enabled
		card.clicked.connect(func():
			_on_card_clicked(i)
		)
		add_child(card)
		card.set_card_data(hand_data[i])
		_cards.append(card)
	
	_update_fan()

func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	print("Hand.set_enabled:", enabled)

	for card in _cards:
		card.disabled = not enabled

	if not enabled:
		_clear_highlight()

# Private methods
func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)
	Global.player_turn_started.connect(_on_player_turn_started)
	Global.player_turn_ended.connect(_on_player_turn_ended)

func sync_with_state(game_state: GameState, _action: Action) -> void:
	var hand: Array[CardData] = game_state.hand
	#TODO: DONT CALL SET HAND Expensive to destroy and create again without smart building...
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

func _update_fan() -> void:
	var count := _cards.size()
	if count == 0:
		return

	var width := (count - 1) * card_spacing
	var start_x := -width * 0.5

	for i in range(count):
		var card := _cards[i]

		var t := 0.5 if count == 1 else float(i) / float(count - 1)

		var y_mul := height_curve.sample(t) if height_curve else 0.0
		var rot_mul := rotation_curve.sample(t) if rotation_curve else 0.0

		var x := start_x + i * card_spacing
		var y := y_mul * y_offset
		var rot := deg_to_rad(rot_mul * max_rotation_degrees)

		card.position = Vector2(x, y)
		card.rotation = rot
		card.z_index = i
