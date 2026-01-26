class_name Hazard
extends Node2D

signal animation_finished

var _board: Board
var _cell_pos: Vector2i = Vector2i(-1, -1)

@onready var sprite: Sprite2D = %Sprite2D

func sync_with_state(hazard_state: HazardState, _action: Action) -> bool:
	if _cell_pos == Vector2i(-1, -1):
		_cell_pos = hazard_state.cell_pos
		position = _board.cell_to_world(_cell_pos)
		AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TRAP)
		return false

	if _cell_pos != hazard_state.cell_pos:
		_cell_pos = hazard_state.cell_pos
		play_move_animation(_cell_pos)
		return true

	return false

func play_move_animation(target_cell: Vector2i) -> void:
	print("START ANIM", name)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

	tween.tween_property(self, "position", _board.cell_to_world(target_cell), 0.3)
	tween.finished.connect(func():
		print("END ANIM", name)
		animation_finished.emit()
	, CONNECT_ONE_SHOT)