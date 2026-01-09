class_name Hand
extends HBoxContainer
# Docstring

# Signals

# Enums

# Constants

# Export Variables

# Public Variables

# Private Variables
var _cards: Array[Card] = []
var _selected_card: Card = null

# OnReady Variables

func _ready() -> void:
	Global.board_click.connect(_on_board_click)
	for child in get_children():
		if child is Card:
			_cards.append(child)
			child.selected.connect(_on_card_selected)

func _process(_delta: float) -> void:
	pass

# Public Methods
func play_card() -> void:
	if _selected_card:
		_selected_card.play()
		remove_card(_selected_card)
		_selected_card = null

func add_card(card: Card) -> void:
	_cards.append(card)
	card.selected.connect(_on_card_selected)

func remove_card(card: Card) -> void:
	_cards.erase(card)
	card.selected.disconnect(_on_card_selected)
	card.queue_free()

# Private Methods
func _on_card_selected(card: Card) -> void:
	if _selected_card == card:
		card.deselect()
		_selected_card = null
		return

	if _selected_card:
		_selected_card.deselect()

	_selected_card = card
	_selected_card.select()

func _on_board_click(_pos: Vector2i, suit: Global.SUIT) -> void:
	if _selected_card == null or _selected_card.suit != suit:
		return
	play_card()
	
# Sub-classes
