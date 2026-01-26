class_name GunAction
extends Action

# Constants
const GUN_TEXTURE: Texture = preload(Global.TEXTURE_UUIDS.ACTION_GUN)

# Undo data
var _killed_unit: UnitState
var _killed_group_id: int
var _removed_hazard: Vector2i = Vector2i(-1, -1)

func can_execute(state: GameState) -> bool:
	var shooter: UnitState = state.get_unit_by_id(unit_id)
	if shooter == null:
		return false

	if shooter.cell_pos.x != target_pos.x and shooter.cell_pos.y != target_pos.y:
		return false

	var target: UnitState = state.get_unit_at(target_pos)
	if not state.has_hazard(target_pos) and not target:
		return false

	if target != null and (target.group_id == shooter.group_id or target.shielded):
		return false
	
	var line: Array[Vector2i] = state.get_line_tiles(shooter.cell_pos, target_pos - shooter.cell_pos)
	for cell in line:
		if cell == target_pos:
			break
		if state.get_unit_at(cell) != null or state.has_hazard(cell):
			return false

	if source_card != null:
		var suit: Global.Suit = source_card.suit
		if suit != Global.Suit.GREEN and suit != state.get_tile_suit(target_pos):
			return false

	return true

func execute(state: GameState) -> void:
	var target: UnitState = state.get_unit_at(target_pos)
	if target != null:
		_killed_unit = target
		_killed_group_id = target.group_id
		state.get_group_by_id(target.group_id).get_units().erase(target)
	elif state.has_hazard(target_pos):
		var hazard: HazardState = state.get_hazard_at(target_pos)
		state.hazards.erase(hazard.id)

	if source_card != null:
		state.hand.erase(source_card)

func undo(state: GameState) -> void:
	if _killed_unit != null:
		state.get_group_by_id(_killed_group_id).add_unit(_killed_unit)

	if _removed_hazard != Vector2i(-1, -1):
		var next_id: int = state.get_next_hazard_id()
		state.hazards[next_id] = HazardState.new(next_id, _removed_hazard)

	if source_card != null:
		state.restore_card(source_card)

func get_target_positions(state: GameState) -> Array[Vector2i]:
	var shooter: UnitState = state.get_unit_by_id(unit_id)
	if shooter == null:
		return []

	var result: Array[Vector2i] = []

	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		for cell in state.get_line_tiles(shooter.cell_pos, dir):
			result.append(cell)

	return result

func get_display_name() -> String:
	return "Gun"

func get_icon_texture() -> Texture:
	return GUN_TEXTURE
