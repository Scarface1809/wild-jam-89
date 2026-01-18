class_name RoundDisplay
extends Label

func _ready():
	Global.round_changed.connect(_on_round_changed)

func _on_round_changed(_round: int):
	text = "round " + str(_round + 1) + "/5"
