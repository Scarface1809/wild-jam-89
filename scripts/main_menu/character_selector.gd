extends Control

@onready var portrait_texture: TextureRect = %PortraitTexture
@onready var characters_container: HBoxContainer = %CharactersContainer

var character_buttons: Array = []

func _ready() -> void:
	for child in characters_container.get_children():
		child.connect("mouse_entered", _on_mouse_entered.bind(child.name))
		child.connect("pressed", _on_button_pressed)

func _on_mouse_entered(animal: String) -> void:
	var image_path: String = "res://assets/characters/portraits/" + animal + ".png" 
	portrait_texture.texture = load(image_path)
	
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(portrait_texture, "scale", Vector2(0.95,0.95), 0.1)
	tween.tween_property(portrait_texture, "scale", Vector2(1,1), 0.1)

func _on_button_pressed():
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	await Global.game_controller.change_scene(Global.SCENE_UIDS.MAIN_UI, Global.SCENE_UIDS.MAIN_GAME, TransitionSettings.TRANSITION_TYPE.FADE_TO_FADE)


func _on_back_button_pressed() -> void:
	hide()
