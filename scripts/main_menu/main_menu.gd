extends Control
class_name MainMenu

@onready var start_menu: Control = %StartMenu
@onready var how_to_play_menu: Control = %HowToPlayMenu
@onready var options_menu: Control = %OptionsMenu
@onready var character_selector: CharacterSelector = %CharacterSelector

# Private Functions
func _ready() -> void:
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MENU_MUSIC)

#region Signal Handlers
# Start Menu
func _on_start_menu_start_game() -> void:
	if Global.game_state:
		character_selector.show()
	else:
		character_selector.show()

func _on_start_menu_open_options() -> void:
	options_menu.show()

func _on_start_menu_open_how_to_play() -> void:
	how_to_play_menu.show()

# Character Selector
func _on_character_selector_hidden() -> void:
	start_menu.show()

# Options Menu
func _on_options_menu_hidden() -> void:
	start_menu.show()

# How To Play Menu
func _on_how_to_play_menu_hidden() -> void:
	start_menu.show()
#endregion