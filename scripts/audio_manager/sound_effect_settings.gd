@icon("uid://dbpk4dr1p4ci8")
class_name SoundEffectSettings
extends Resource

enum SOUND_EFFECT_TYPE {
	BUTTON_CLICK,
}

## Maximum amount of this sound that can play at the same time.
@export_range(0, 10) var limit: int = 5
## Type/category of the sound effect (used for grouping or filtering).
@warning_ignore("ENUM_VARIABLE_WITHOUT_DEFAULT")
@export var type: SOUND_EFFECT_TYPE
## The actual audio file (AudioStream) that will be played.
@export var sound_effect: AudioStream
## Volume offset applied when playing this sound (-40 to +20 dB).
@export_range(-40, 20) var volume = 0
## Pitch multiplier (1.0 is normal pitch).
@export_range(0.0, 4.0, .01) var pitch_scale = 1.0
## Random variation added to the pitch when playing (0 to 1).
@export_range(0.0, 1.0, .01) var pitch_randomness = 0.0
## Bus this sound should play on (e.g., "Master", "SFX", "Music")
@export var bus_name: StringName = "Master"

var _audio_count: int = 0

func change_audio_count(amount: int):
	_audio_count = max(0, _audio_count + amount)

func has_open_limit() -> bool:
	return _audio_count < limit

func on_audio_finished():
	change_audio_count(-1)
