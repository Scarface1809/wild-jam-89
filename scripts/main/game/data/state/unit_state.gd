@icon("uid://mjcjlr2vgpl0")
extends Resource
class_name UnitState
## Represents the state of a unit in the game (Mutable)

var id: int = -1
var group_id: int = -1
var cell_pos: Vector2i = Vector2i(-1, -1)
var shielded: bool = false

# TODO: just have unitdata here since its immutable data
var name: String = "Unit"
var piece_texture: Texture2D = null
var portrait_texture: Texture2D = null
var human_texture: Texture2D = null
var actions: Array[Action] = []

func _init(_id: int, _group_id: int, _cell_pos: Vector2i, data: UnitData = null) -> void:
	self.id = _id
	self.group_id = _group_id
	self.cell_pos = _cell_pos

	if data:
		self.name = data.name
		self.piece_texture = data.piece_texture
		self.portrait_texture = data.portrait_texture
		self.human_texture = data.human_texture
		self.actions = data.actions

func to_dict() -> Dictionary:
	return {
		"id": id,
		"group_id": group_id,
		"cell_pos": {"x": cell_pos.x, "y": cell_pos.y},
		"name": name,
		"piece_texture": piece_texture.resource_path,
		"portrait_texture": portrait_texture.resource_path,
		"human_texture": human_texture.resource_path,
		"actions": actions.map(func(a: Action) -> String: return a.resource_path)
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", id)
	group_id = data.get("group_id", group_id)
	var pos = data.get("cell_pos", {"x": - 1, "y": - 1})
	cell_pos = Vector2i(pos.get("x", -1), pos.get("y", -1))
	shielded = data.get("shielded", shielded)
	name = data.get("name", name)
	piece_texture = load(data.get("piece_texture"))
	portrait_texture = load(data.get("portrait_texture"))
	human_texture = load(data.get("human_texture"))
	
	var _actions: Array[Action] = []
	for path in data.get("actions", []):
		var res = load(path)
		if res is Action:
			_actions.append(res)
	actions = _actions
