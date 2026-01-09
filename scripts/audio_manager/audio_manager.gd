extends Node2D

# Public variables
@export var sound_effect_settings: Array[SoundEffectSettings]

# Private variables
var _sound_effect_dict: Dictionary = {}
var _active_sounds: Dictionary = {}

# Virtual functions
func _ready():
	for setting: SoundEffectSettings in sound_effect_settings:
		if setting.type in _sound_effect_dict:
			push_warning("Duplicate SoundEffectSettings type: %s" % [setting.type])
		else:
			_sound_effect_dict[setting.type] = setting

# Public functions
## Create a 2D audio source at a specific location with the given sound effect type.
func create_2d_audio_at_location(location: Vector2, type: SoundEffectSettings.SOUND_EFFECT_TYPE):
	if _sound_effect_dict.has(type):
		var sound_effect_setting: SoundEffectSettings = _sound_effect_dict[type]
		if sound_effect_setting.has_open_limit():
			sound_effect_setting.change_audio_count(1)
			var new_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			add_child(new_audio)
			new_audio.stream = sound_effect_setting.sound_effect
			new_audio.volume_db = sound_effect_setting.volume
			new_audio.pitch_scale = sound_effect_setting.pitch_scale
			new_audio.pitch_scale += randf_range(-sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)
			if (AudioServer.get_bus_index(sound_effect_setting.bus_name) == -1):
				push_warning("Audio Manager: Bus name '%s' not found. Defaulting to 'Master' bus." % sound_effect_setting.bus_name)
			new_audio.bus = sound_effect_setting.bus_name
			new_audio.position = location
			new_audio.finished.connect(func():
				sound_effect_setting.on_audio_finished()
				_remove_active_sound(type, new_audio)
				new_audio.queue_free()
			)
			new_audio.play()
			_add_active_sound(type, new_audio)
	else:
		push_error("Audio Manager failed to find setting for type ", type)

## Create a standard 2D audio source with the given sound effect type.
func create_audio(type: SoundEffectSettings.SOUND_EFFECT_TYPE):
	if _sound_effect_dict.has(type):
		var sound_effect_setting: SoundEffectSettings = _sound_effect_dict[type]
		if sound_effect_setting.has_open_limit():
			sound_effect_setting.change_audio_count(1)
			var new_audio = AudioStreamPlayer.new()
			add_child(new_audio)
			new_audio.stream = sound_effect_setting.sound_effect
			new_audio.volume_db = sound_effect_setting.volume
			new_audio.pitch_scale = sound_effect_setting.pitch_scale
			new_audio.pitch_scale += randf_range(-sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)
			if (AudioServer.get_bus_index(sound_effect_setting.bus_name) == -1):
				push_warning("Audio Manager: Bus name '%s' not found. Defaulting to 'Master' bus." % sound_effect_setting.bus_name)
			new_audio.bus = sound_effect_setting.bus_name
			new_audio.finished.connect(func():
				sound_effect_setting.on_audio_finished()
				_remove_active_sound(type, new_audio)
				new_audio.queue_free()
			)
			new_audio.play()
			_add_active_sound(type, new_audio)
	else:
		push_error("Audio Manager failed to find setting for type ", type)

## Fade out all active audio sources of a given type over a specified duration.
func fade_out_audio(type: SoundEffectSettings.SOUND_EFFECT_TYPE, duration: float = 1.0):
	if not _active_sounds.has(type):
		return

	for player in _active_sounds[type]:
		if not is_instance_valid(player):
			continue
		var tween: Tween = player.create_tween()
		tween.tween_property(player, "volume_db", -80, duration)
		tween.finished.connect(func():
			if is_instance_valid(player):
				player.stop()
				var sound_effect_setting: SoundEffectSettings = _sound_effect_dict[type]
				sound_effect_setting.on_audio_finished()
				_remove_active_sound(type, player)
				player.queue_free())

## Stop all active audio sources of a given type immediately.
func stop_audio(type: SoundEffectSettings.SOUND_EFFECT_TYPE):
	if not _active_sounds.has(type):
		return

	for player in _active_sounds[type]:
		if is_instance_valid(player):
			player.stop()
			var sound_effect_setting: SoundEffectSettings = _sound_effect_dict[type]
			sound_effect_setting.on_audio_finished()
			_remove_active_sound(type, player)
			player.queue_free()

## Get all active audio sources of a given type.
func get_active_audios(type: SoundEffectSettings.SOUND_EFFECT_TYPE) -> Array:
	if _active_sounds.has(type):
		return _active_sounds[type]
	return []

## Get the first active audio source of a given type.
func get_active_audio(type: SoundEffectSettings.SOUND_EFFECT_TYPE) -> AudioStreamPlayer:
	# Returns the first active sound of this type (or null)
	if _active_sounds.has(type) and not _active_sounds[type].is_empty():
		return _active_sounds[type][0]
	return null

# Private functions
func _add_active_sound(type, player):
	if not _active_sounds.has(type):
		_active_sounds[type] = []
	_active_sounds[type].append(player)

func _remove_active_sound(type, player):
	if _active_sounds.has(type):
		_active_sounds[type].erase(player)
		if _active_sounds[type].is_empty():
			_active_sounds.erase(type)
