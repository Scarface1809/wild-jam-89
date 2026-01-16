class_name Radio
extends Area2D

@export var musics: Array[SoundEffectSettings.SOUND_EFFECT_TYPE] = []

var _last_music = null

func _ready() -> void:
	if musics.is_empty():
		return

	var first_song := _pick_new_music()
	_last_music = first_song
	AudioManager.create_audio(first_song)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		for music_type in musics:
			AudioManager.stop_audio(music_type)

		if musics.is_empty():
			return

		var next_music := _pick_new_music()
		_last_music = next_music
		AudioManager.create_audio(next_music)

func _pick_new_music() -> SoundEffectSettings.SOUND_EFFECT_TYPE:
	if musics.size() == 1:
		return musics[0]

	var choices := musics.duplicate()
	if _last_music != null:
		choices.erase(_last_music)
	return choices.pick_random()
