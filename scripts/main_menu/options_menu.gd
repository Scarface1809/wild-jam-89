extends Control

@onready var back_button: Button = %BackButton
@onready var music_volume_bar: ProgressBar = %MusicVolumeBar
@onready var sound_volume_bar: ProgressBar = %SoundVolumeBar

var volume_steps: Array[int] = [-100, -40, -30, -20, -15, -10, -7, -4, -2, 0]

func _ready() -> void:
	_apply_music_volume()
	_apply_sound_volume()

# Private functions

func _apply_music_volume() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_steps[Global.music_step])
	music_volume_bar.value = float(Global.music_step) / float(volume_steps.size() - 1)

func _apply_sound_volume() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_steps[Global.sound_step])
	sound_volume_bar.value = float(Global.sound_step) / float(volume_steps.size() - 1)

# Signal callbacks

func _on_back_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	hide()

func _on_full_screen_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	var mode := DisplayServer.window_get_mode()
	
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_minus_music_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	Global.music_step = max(0, Global.music_step - 1)
	_apply_music_volume()

func _on_plus_music_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	Global.music_step = min(volume_steps.size() - 1, Global.music_step + 1)
	_apply_music_volume()

func _on_minus_sound_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	Global.sound_step = max(0, Global.sound_step - 1)
	_apply_sound_volume()

func _on_plus_sound_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	Global.sound_step = min(volume_steps.size() - 1, Global.sound_step + 1)
	_apply_sound_volume()
