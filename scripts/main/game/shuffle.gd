class_name Shuffle
extends TextureButton

@onready var label: Label = %Label

func set_enabled(enabled: bool) -> void:
	disabled = not enabled

func _ready() -> void:
	Global.game_state_changed.connect(sync_with_state)
	Global.player_turn_started.connect(_on_player_turn_started)
	Global.player_turn_ended.connect(_on_player_turn_ended)

func sync_with_state(state: GameState, _action: Action) -> void:
	label.text = str(state.deck.size())

func _on_pressed() -> void:
	Global.shuffle_request.emit()

func _on_player_turn_started() -> void:
	set_enabled(true)

func _on_player_turn_ended() -> void:
	set_enabled(false)
