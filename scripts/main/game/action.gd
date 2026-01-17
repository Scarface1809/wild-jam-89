class_name Action
extends Resource

var type: Global.ACTION_TYPE
var unit_id: int
var target_pos: Vector2i # cell coordinates
var source_card: CardData
var num_cards: int
var forced: bool = false # Forced action by the rules of the game

func _init() -> void:
	type = Global.ACTION_TYPE.MOVE
	unit_id = -1
	target_pos = Vector2i(-1, -1)
	source_card = null

func _to_string() -> String:
	var action_name := _action_type_to_string(type)
	var s := "──────── ACTION ────────\n"
	s += "Unit ID: " + str(unit_id) + "\n"
	s += "Action Type: " + action_name + "\n"
	s += "Target Pos: " + str(target_pos) + "\n"
	
	if source_card != null:
		s += "Source Card Type: " + _action_type_to_string(source_card.action_type)
		s += " | Suit: " + str(source_card.suit) + "\n"
	else:
		s += "Source Card: NONE\n"
	
	s += "Num Cards: " + str(num_cards) + "\n"
	s += "Forced: " + str(forced) + "\n"
	s += "────────────────────────"
	return s

# Helper: convert enum to string
func _action_type_to_string(t: int) -> String:
	match t:
		Global.ACTION_TYPE.MOVE: return "MOVE"
		Global.ACTION_TYPE.GUN: return "GUN"
		Global.ACTION_TYPE.KNIFE: return "KNIFE"
		Global.ACTION_TYPE.TELEPORT: return "TELEPORT"
		Global.ACTION_TYPE.PUSH: return "PUSH"
		Global.ACTION_TYPE.TRAP: return "TRAP"
		Global.ACTION_TYPE.SHIELD: return "SHIELD"
		Global.ACTION_TYPE.SEVEN: return "SEVEN"
		Global.ACTION_TYPE.DRAW: return "DRAW"
		Global.ACTION_TYPE.RESHUFFLE: return "RESHUFFLE"
		_: return "UNKNOWN"
