extends Control
class_name PauseMenu

@onready var options_menu: Control = %OptionsMenu
@onready var how_to_play_menu: Control = %HowToPlayMenu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		open_close_pause()

# Public functions
func open_close_pause():
	visible = !visible
	if visible:
		get_tree().paused = true

	else:
		get_tree().paused = false
		options_menu.hide()
		how_to_play_menu.hide()

# Signal callbacks
func _on_resume_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	open_close_pause()

func _on_options_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	options_menu.show()
	
func _on_how_to_play_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	how_to_play_menu.show()

func _on_main_menu_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	get_tree().paused = false
	AudioManager.fade_out_audio_by_bus("Music", 0.8)
	await Global.game_controller.change_scene(Global.SCENE_UIDS.MAIN_MENU, "", TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)
