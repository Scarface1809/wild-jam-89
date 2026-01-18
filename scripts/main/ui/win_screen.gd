class_name WinScreen
extends Control

@onready var next_button: Button = %Next

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)

func _on_next_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	await Global.game_controller.change_scene(Global.SCENE_UIDS.MAIN_MENU, "", TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)
