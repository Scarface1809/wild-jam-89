class_name StartMenu
extends Control

signal new_game
signal continue_game
signal open_options
signal open_how_to_play

@onready var _continue_button: Button = %ContinueButton

func _ready() -> void:
	_continue_button.visible = SaveSystem.has_saved_game()

func _on_new_game_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	hide()
	new_game.emit()

func _on_continue_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	hide()
	continue_game.emit()

func _on_options_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	hide()
	open_options.emit()

func _on_how_to_play_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	hide()
	open_how_to_play.emit()

func _on_quit_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	get_tree().quit()
