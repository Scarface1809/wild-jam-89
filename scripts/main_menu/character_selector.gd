extends Control

const THEME: Theme = preload(Global.THEME_UIDS.MAIN)

@export var units: Array[UnitData] = []

@onready var _portrait_texture: TextureRect = %PortraitTexture
@onready var _characters_container: HBoxContainer = %CharactersContainer

func _ready() -> void:
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
	_portrait_texture.texture = unit.portrait_texture
	
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(_portrait_texture, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(_portrait_texture, "scale", Vector2(1, 1), 0.1)

func _on_button_pressed(_button: Button, unit: UnitData) -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	Global.selected_unit = unit
	await Global.game_controller.change_scene(Global.SCENE_UIDS.MAIN_UI, Global.SCENE_UIDS.MAIN_GAME, TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)

func _on_back_button_pressed() -> void:
	hide()
