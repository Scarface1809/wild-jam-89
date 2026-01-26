class_name Unit
extends Node2D

signal animation_finished

#Constants
const OUTLINE_MATERIAL: ShaderMaterial = preload(Global.MATERIAL_UIDS.OUTLINE)

# Onready Variables
@onready var piece_sprite: Sprite2D = %Sprite2D

# Private Variables
var _id: int = -1
var _cell_pos: Vector2i = Vector2i(-1, -1)
var _active: bool = false
var _board: Board

func get_id() -> int:
	return _id

func get_cell_pos() -> Vector2i:
	return _cell_pos

func set_active(active: bool) -> void:
	if _active == active:
		return
	_active = active
	piece_sprite.material = OUTLINE_MATERIAL if _active else null

func sync_with_state(unit_state: UnitState, action: Action) -> bool:
	# First time setup - no animation
	if _id == -1:
		_id = unit_state.id
		name = unit_state.name
		_cell_pos = unit_state.cell_pos
		position = _board.cell_to_world(_cell_pos)
		if piece_sprite.texture != unit_state.piece_texture:
			piece_sprite.texture = unit_state.piece_texture
		return false

	if action is GunAction and action.unit_id == _id:
		play_gun_animation()
		return true

	if action is PushAction and action.unit_id == _id:
		play_push_animation()
		return true

	# TODO: MOVE TO THE HAZARD ITSELF
	if action is TrapAction and action.unit_id == _id:
		play_trap_animation()
		return true

	if action is TeleportAction and action.unit_id == _id:
		play_teleport_animation(action.target_pos)
		return true

	if action is ShieldAction and action.unit_id == _id:
		play_shield_animation()
		return true

	# Set persistent piece texture
	if piece_sprite.texture != unit_state.piece_texture:
		piece_sprite.texture = unit_state.piece_texture

	# Set persistent shield color
	piece_sprite.modulate = Color(0.4, 0.7, 1.0) if unit_state.shielded else Color.WHITE

	# Set persistent cell position
	if _cell_pos != unit_state.cell_pos:
		_cell_pos = unit_state.cell_pos
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

func play_gun_animation() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.GUN)

	# Quick scale
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)
	tween.finished.connect(func():
		animation_finished.emit()
	, CONNECT_ONE_SHOT)

func play_push_animation() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PUSH)

	# Slight forward + squash
	tween.tween_property(self, "scale", Vector2(1.2, 0.9), 0.07)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)

	tween.finished.connect(func():
		animation_finished.emit()
	, CONNECT_ONE_SHOT)

# TODO: MOVE TO THE HAZARD ITSELF
func play_trap_animation() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Quick shake
	tween.tween_property(self, "position", position + Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", position - Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", position, 0.05)

	tween.finished.connect(func():
		animation_finished.emit()
	, CONNECT_ONE_SHOT)

func play_teleport_animation(target_cell: Vector2i) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TELEPORT)

	tween.tween_property(self, "position", _board.cell_to_world(target_cell), 0.3)
	tween.finished.connect(func():
		animation_finished.emit()
	, CONNECT_ONE_SHOT)

func play_shield_animation() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.SHIELD)

	# Flash + pulse
	piece_sprite.modulate = Color(0.4, 0.7, 1.0)

	tween.tween_property(piece_sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(piece_sprite, "scale", Vector2.ONE, 0.15)

	tween.finished.connect(func():
		animation_finished.emit()
	, CONNECT_ONE_SHOT)
