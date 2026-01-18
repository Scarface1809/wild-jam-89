extends TextureRect


@onready var label: Label = %Label

func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)

func sync_with_state(state: GameState, _action: Action) -> void:
	label.text = str(state.deck.size()) + "/56"
