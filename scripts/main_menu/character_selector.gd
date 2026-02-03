extends Control
class_name CharacterSelector

signal character_selected(unit: UnitData)

const CHARACTER_BUTTON_SCENE = preload(Global.SCENE_UIDS.CHARACTER_BUTTON)
const WIN_BUTTON_STYLE = preload(Global.THEME_UIDS.WIN_BUTTON)
const WIN_HOVER_STYLE = preload(Global.THEME_UIDS.WIN_HOVER)
const THROW_DISTANCE: float = 700.0
const THROW_ROTATION: float = 320.0

@export var units: Array[UnitData] = []

@onready var card_player: AudioStreamPlayer = %card_player
@onready var front_card: TextureRect = %FrontCard
@onready var back_card: TextureRect = %BackCard
@onready var _characters_container: HBoxContainer = %CharactersContainer
@onready var wins_1: Label = %Wins1
@onready var wins_2: Label = %Wins2

var is_animating: bool = false
var current_tween: Tween
var current_unit: UnitData
var selection_locked: bool = false

func _ready() -> void:
	front_card.pivot_offset = front_card.size * 0.5
	back_card.pivot_offset = back_card.size * 0.5
	back_card.visible = false
	for unit: UnitData in units:
		# More customization make it a scene
		var button: Button = CHARACTER_BUTTON_SCENE.instantiate()
		button.icon = unit.piece_texture
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button, unit))
		button.pressed.connect(_on_button_pressed.bind(button, unit))
		if SaveSystem.character_wins.has(unit.name):
			button.add_theme_stylebox_override("normal", WIN_BUTTON_STYLE)
			button.add_theme_stylebox_override("hover", WIN_HOVER_STYLE)
			if unit.name == "Rat":
				wins_2.text = "wins: " + str(SaveSystem.character_wins[unit.name])
		_characters_container.add_child(button)

func _on_button_pressed(_button: Button, unit: UnitData) -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	if selection_locked:
		return
	selection_locked = true
	for child: Button in _characters_container.get_children():
		child.disabled = true
	character_selected.emit(unit)

func _on_back_button_pressed() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	hide()

func _on_button_mouse_entered(_button: Button, unit: UnitData) -> void:
	_show_unit(unit)

func _show_unit(unit: UnitData) -> void:
	if selection_locked:
		return

	# Ignore same unit spam
	if current_unit == unit:
		return
	current_unit = unit
	
	card_player.play()

	# If an animation is running, resolve it instantly
	if current_tween and current_tween.is_running():
		current_tween.kill()

		# Snap front card to whatever was "incoming"
		if back_card.visible:
			front_card.texture = back_card.texture
			front_card.position = back_card.position
			front_card.scale = back_card.scale
			back_card.visible = false

	# Prepare back card (new incoming card)
	back_card.texture = unit.portrait_texture
	var wins := 0
	if SaveSystem.character_wins.has(unit.name):
		wins = SaveSystem.character_wins[unit.name]

	wins_1.text = "wins: " + str(wins)
	back_card.position = front_card.position
	back_card.scale = Vector2(0.92, 0.92)

	# Random initial tilt so it doesn't look cloned
	back_card.rotation_degrees = randf_range(-12, 12)
	back_card.visible = true

	# Random throw direction (biased upward)
	var dir := Vector2(randf_range(-0.6, 0.6), randf_range(-1.2, -0.8)).normalized()

	var throw_pos := front_card.position + dir * THROW_DISTANCE
	var throw_rot := front_card.rotation + randf_range(-deg_to_rad(THROW_ROTATION), deg_to_rad(THROW_ROTATION))


	current_tween = create_tween().set_parallel()

	# Throw outgoing card
	current_tween.tween_property(front_card, "position", throw_pos, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	current_tween.tween_property(front_card, "rotation", throw_rot, 0.28)

	current_tween.tween_property(front_card, "scale", Vector2(0.85, 0.85), 0.28)

	# Bring new card forward
	current_tween.tween_property(back_card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.08)

	await current_tween.finished

	# Finalize swap
	front_card.texture = back_card.texture
	wins_2.text = "wins: " + str(wins)
	front_card.position = back_card.position
	front_card.scale = Vector2.ONE
	front_card.rotation = back_card.rotation


	back_card.visible = false
	current_tween = null
