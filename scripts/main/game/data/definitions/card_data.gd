@icon("uid://csbdw36qg7vta")
class_name CardData
extends Resource

@export var suit: Global.Suit = Global.Suit.BLUE
@export var action: Action

func get_suit_texture() -> Texture:
	match suit:
		Global.Suit.BLUE:
			return preload(Global.TEXTURE_UUIDS.SUIT_BLUE)
		Global.Suit.RED:
			return preload(Global.TEXTURE_UUIDS.SUIT_RED)
		Global.Suit.GREEN:
			return preload(Global.TEXTURE_UUIDS.SUIT_GREEN)
		Global.Suit.YELLOW:
			return preload(Global.TEXTURE_UUIDS.SUIT_YELLOW)
		_:
			return null