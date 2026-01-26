extends Control
class_name MainMenu

@onready var start_menu: Control = %StartMenu
@onready var how_to_play_menu: Control = %HowToPlayMenu
@onready var options_menu: Control = %OptionsMenu
@onready var character_selector: Control = %CharacterSelector

func _ready() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MENU_MUSIC)

func _on_start_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	start_menu.hide()
	character_selector.show()

func _on_options_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	start_menu.hide()
	options_menu.show()

func _on_how_to_play_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	start_menu.hide()
	how_to_play_menu.show()

func _on_quit_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	get_tree().quit()

func _on_options_menu_hidden() -> void:
	start_menu.show()

func _on_how_to_play_menu_hidden() -> void:
	start_menu.show()

func _on_character_selector_hidden() -> void:
	start_menu.show()
