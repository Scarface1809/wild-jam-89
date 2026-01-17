class_name Radio
extends Button

@export var musics: Array[SoundEffectSettings.SOUND_EFFECT_TYPE] = []

@onready var switch_player: AudioStreamPlayer = $switch_player

var _last_music = null

var _switching: bool = false

func _ready() -> void:
	if musics.is_empty():
		return

	var first_song := _pick_new_music()
	_last_music = first_song
	AudioManager.create_audio(first_song)

func _pressed() -> void:
	if musics.is_empty() or _switching:
		return
	
	_switching = true
	
	# Stop currently playing musics
	for music_type in musics:
		AudioManager.fade_out_audio(music_type, 0.3)

	# Pick next music
	var next_music := _pick_new_music()
	_last_music = next_music

	var start_time = randf_range(1,38)
	switch_player.play(start_time)

	var tween := create_tween()
	tween.tween_interval(0.6)
	
	await tween.finished
	
	switch_player.stop() 
	AudioManager.create_audio(next_music, randf_range(0, 10))
	_switching = false

func _pick_new_music() -> SoundEffectSettings.SOUND_EFFECT_TYPE:

	if _last_music == null:
		_last_music = musics[0]
		return _last_music

	var index := musics.find(_last_music)
	index = (index + 1) % musics.size()
	_last_music = musics[index]
	return _last_music
