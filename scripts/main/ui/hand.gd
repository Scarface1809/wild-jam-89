class_name Hand
extends Control
## This class is responsible for managing the player's hand of cards.

# Constants
const CARD_SCENE: PackedScene = preload(Global.SCENE_UIDS.CARD)

@export var height_curve: Curve
@export var rotation_curve: Curve
@export var max_rotation_degrees: float = 20.0
@export var card_spacing: float = 90.0
@export var y_offset: float = -40.0

# Private Variables
var _cards: Array[Card] = []
var _highlighted_index: int = -1
var _enabled: bool = false
var _last_hand_data: Array[CardData] = []

# Public Methods
func sync_with_state(game_state: GameState, _action: Action) -> void:
	var hand_data: Array[CardData] = game_state.hand

	if hand_data == _last_hand_data:
		return

	_last_hand_data = hand_data.duplicate(true)

	var hand_size := hand_data.size()
	var current_size := _cards.size()

	for i: int in range(current_size, hand_size):
		var card: Card = CARD_SCENE.instantiate()
		card.disabled = not _enabled

		var idx: int = i
		card.selected.connect(func(): _on_card_selected(idx))

		add_child(card)
		_cards.append(card)

	for i: int in range(hand_size, current_size):
		var removed_card: Card = _cards.pop_back()
		removed_card.queue_free()
		if _highlighted_index >= _cards.size():
			_highlighted_index = -1

	# Update all cards with latest data
	for i: int in range(hand_size):
		_cards[i].set_card_data(hand_data[i])
		_cards[i].disabled = not _enabled

	# Re-layout fan and clear highlight
	_update_fan()
	_clear_highlight()

func set_enabled(enabled: bool) -> void:
	if _enabled == enabled:
		return
	_enabled = enabled

	for card in _cards:
		card.disabled = not enabled

	if not enabled:
		_clear_highlight()

# Private methods
func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)
	Global.turn_started.connect(
		func(group: GroupState, _unit: UnitState):
			if group.type == Global.GroupType.PLAYER:
				_on_player_turn_started()
	)
	Global.turn_ended.connect(
		func(group: GroupState, _unit: UnitState):
			if group.type == Global.GroupType.PLAYER:
				_on_player_turn_ended()
	)

func _on_player_turn_started() -> void:
	set_enabled(true)

func _on_player_turn_ended() -> void:
	set_enabled(false)

func _on_card_selected(index: int) -> void:
	if _highlighted_index == index:
		_clear_highlight()
		Global.card_selected.emit(-1)
		return

	_clear_highlight()
	_highlighted_index = index
	_cards[index].select()

	Global.card_selected.emit(index)

func _clear_highlight() -> void:
	if _highlighted_index != -1:
		_cards[_highlighted_index].deselect()
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