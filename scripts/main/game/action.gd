class_name Action
extends Resource

var type: Global.ACTION_TYPE
var unit_id: int
var target_pos: Vector2i # cell coordinates
var source_card: CardData

func _init() -> void:
    type = Global.ACTION_TYPE.MOVE
    unit_id = -1
    target_pos = Vector2i(-1, -1)
    source_card = null
