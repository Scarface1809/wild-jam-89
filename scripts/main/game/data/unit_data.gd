@icon("uid://di0gf686v4bf2")
extends Resource
class_name UnitData
## Represents the data of a unit in the game (Immutable)

@export var name: String
@export var piece_texture: Texture2D
@export var portrait_texture: Texture2D
@export var human_texture: Texture2D
@export var actions: Array[Global.ACTION_TYPE]