extends Control

@onready var how_to_play_menu: Control = %HowToPlayMenu
@onready var options_menu: Control = %OptionsMenu
@onready var character_selector: Control = %CharacterSelector


func _on_start_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	character_selector.show()
	

func _on_options_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	options_menu.show()

func _on_how_to_play_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	how_to_play_menu.show()

func _on_quit_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	get_tree().quit()
