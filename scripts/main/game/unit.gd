class_name Unit
extends Node2D

# Signals
signal animation_started()
signal animation_finished()

# Onready Variables
@onready var piece_sprite: Sprite2D = %Sprite2D

# Public variables
var board: Board

# Private Variables
var _id: int
var _is_animating: bool = false

func sync_with_state(unit_state: UnitState, action: Action) -> void:
	_id = unit_state.id
	name = unit_state.name
	piece_sprite.texture = unit_state.piece_texture

	var target_pos: Vector2 = board.cell_to_world(unit_state.cell_pos)

	# Always sync shield visual from state
	# Kind of sketchy?
	animate_shield(unit_state)

	if action == null:
		position = target_pos
		return

	match action.type:
		Global.ACTION_TYPE.MOVE:
			if action.unit_id == _id:
				animate_move(target_pos)

		Global.ACTION_TYPE.KNIFE:
			if action.unit_id == _id:
				animate_knife(target_pos)

		Global.ACTION_TYPE.GUN:
			if action.unit_id == _id:
				animate_gun()

		Global.ACTION_TYPE.TELEPORT:
			animate_teleport_swap(target_pos)

		Global.ACTION_TYPE.PUSH:
			animate_push(target_pos)

		Global.ACTION_TYPE.SEVEN:
			animate_special_seven()

func animate_move(target_pos: Vector2) -> void:
	if not _start_animation():
		return

	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_end_animation)

func animate_knife(target_pos: Vector2) -> void:
	if not _start_animation():
		return

	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_end_animation)

func animate_gun() -> void:
	if not _start_animation():
		return

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.1, 0.05)
	tween.tween_property(self, "scale", Vector2.ONE, 0.05)
	tween.finished.connect(_end_animation)

func animate_death() -> void:
	if not _start_animation():
		return
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)

	tween.finished.connect(func():
		_end_animation()
		if is_inside_tree():
			queue_free() # Unit removes itself safely
	)

func animate_push(target_pos: Vector2) -> void:
	if not _start_animation():
		return

	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_end_animation)

func animate_teleport_swap(target_pos: Vector2) -> void:
	if not _start_animation():
		return

	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_end_animation)

func animate_shield(unit_state: UnitState) -> void:
	#if not _start_animation():
	#	return
	if unit_state.shielded:
		piece_sprite.modulate = Color(0.4, 0.6, 1.0, 1.0)
	else:
		piece_sprite.modulate = Color(1, 1, 1, 1)

	#_end_animation()

func animate_special_seven() -> void:
	if not _start_animation():
		return
	_end_animation()

# Utils
func _start_animation() -> bool:
	if _is_animating:
		return false
	_is_animating = true
	animation_started.emit()
	return true

func _end_animation() -> void:
	_is_animating = false
	animation_finished.emit()

func get_id() -> int:
	return _id
