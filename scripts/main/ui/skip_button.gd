class_name SkipButton
extends Button

func set_enabled(enabled: bool) -> void:
	disabled = not enabled

func _ready() -> void:
	pressed.connect(_on_pressed)
	Global.player_turn_started.connect(_on_player_turn_started)
	Global.player_turn_ended.connect(_on_player_turn_ended)

func _on_pressed() -> void:
	Global.skip_turn.emit()

func _on_player_turn_started() -> void:
	set_enabled(true)

func _on_player_turn_ended() -> void:
	set_enabled(false)
