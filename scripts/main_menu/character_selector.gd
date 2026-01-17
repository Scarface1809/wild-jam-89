extends Control

const THEME: Theme = preload(Global.THEME_UIDS.MAIN)
const throw_distance: float = 700.0
const throw_rotation: float = 320.0

@export var units: Array[UnitData] = []

@onready var front_card: TextureRect = %FrontCard
@onready var back_card: TextureRect = %BackCard
@onready var _characters_container: HBoxContainer = %CharactersContainer

var is_animating: bool = false
var current_tween: Tween
var current_unit: UnitData

func _ready() -> void:
	front_card.pivot_offset = front_card.size * 0.5
	back_card.pivot_offset = back_card.size * 0.5
	back_card.visible = false
	for unit: UnitData in units:
		# More customization make it a scene
		var button: Button = Button.new()
		button.icon = unit.piece_texture
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.theme = THEME
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button, unit))
		button.pressed.connect(_on_button_pressed.bind(button, unit))
		_characters_container.add_child(button)

func _on_button_mouse_entered(_button: Button, unit: UnitData) -> void:
	show_unit(unit)

func _on_button_pressed(_button: Button, unit: UnitData) -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	Global.selected_unit = unit
	AudioManager.fade_out_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MENU_MUSIC, 0.8)
	await Global.game_controller.change_scene(Global.SCENE_UIDS.MAIN_UI, Global.SCENE_UIDS.MAIN_GAME, TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)

func _on_back_button_pressed() -> void:
	hide()
	

func show_unit(unit: UnitData) -> void:
	# Ignore same unit spam
	if current_unit == unit:
		return
	current_unit = unit

	# If an animation is running, resolve it instantly
	if current_tween and current_tween.is_running():
		current_tween.kill()

		# Snap front card to whatever was "incoming"
		if back_card.visible:
			front_card.texture = back_card.texture
			front_card.position = back_card.position
			front_card.scale = back_card.scale
			back_card.visible = false

	# Prepare back card (new incoming card)
	back_card.texture = unit.portrait_texture
	back_card.position = front_card.position
	back_card.scale = Vector2(0.92, 0.92)

	# Random initial tilt so it doesn't look cloned
	back_card.rotation_degrees = randf_range(-12, 12)
	back_card.visible = true

	# Random throw direction (biased upward)
	var dir := Vector2(randf_range(-0.6, 0.6),randf_range(-1.2, -0.8)).normalized()

	var throw_pos := front_card.position + dir * throw_distance
	var throw_rot := front_card.rotation + randf_range(-deg_to_rad(throw_rotation),deg_to_rad(throw_rotation))


	current_tween = create_tween().set_parallel()

	# Throw outgoing card
	current_tween.tween_property(front_card,"position",throw_pos,0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	current_tween.tween_property(front_card,"rotation",throw_rot,0.28)

	current_tween.tween_property(front_card,"scale",Vector2(0.85, 0.85),0.28)

	# Bring new card forward
	current_tween.tween_property(back_card,"scale",Vector2.ONE,0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.08)

	await current_tween.finished

	# Finalize swap
	front_card.texture = back_card.texture
	front_card.position = back_card.position
	front_card.scale = Vector2.ONE
	front_card.rotation = back_card.rotation


	back_card.visible = false
	current_tween = null
