class_name Card
extends Button
# Docstring

# Signals
signal selected(card: Card)

# Enums
@export var suit: Global.SUIT = Global.SUIT.BLUE

# Constants
const OUTLINE_MATERIAL: ShaderMaterial = preload(Global.MATERIAL_UIDS.OUTLINE)
const PERSPECTIVE_MATERIAL: ShaderMaterial = preload(Global.MATERIAL_UIDS.PERSPECTIVE)

# Export Variables
@export_range(0.0, 30.0) var angle_x_max: float = 15.0
@export_range(0.0, 30.0) var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0

# Private Variables
var _tween_rot: Tween
var _tween_hover: Tween
var _tween_selected: Tween

# OnReady Variables
@onready var card_texture: TextureRect = %CardTexture
@onready var shadow_texture: TextureRect = %ShadowTexture

# Public Methods
func select() -> void:
	if _tween_selected and _tween_selected.is_running():
		_tween_selected.kill()

	card_texture.material = OUTLINE_MATERIAL.duplicate(true)

	_tween_selected = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_selected.tween_property(self, "position:y", -30.0, 0.55)

func deselect() -> void:
	if _tween_selected and _tween_selected.is_running():
		_tween_selected.kill()

	card_texture.material = PERSPECTIVE_MATERIAL.duplicate(true)

	_tween_selected = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_selected.tween_property(self, "position:y", 0.0, 0.55)

func play() -> void:
	print("Card played")

# Private Methods
func _ready() -> void:
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)

func _on_gui_input(event: InputEvent) -> void:
	# Tilt Effect
	if button_pressed: return
	if not event is InputEventMouseMotion: return
	
	var mouse_pos: Vector2 = get_local_mouse_position()
	# var diff: Vector2 = (position + size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	# print("Lerp val x: ", lerp_val_x)
	# print("lerp val y: ", lerp_val_y)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	# print("Rot x: ", rot_x)
	# print("Rot y: ", rot_y)

	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)

func _on_mouse_entered() -> void:
	if _tween_hover and _tween_hover.is_running():
		_tween_hover.kill()
	_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_hover.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)

func _on_mouse_exited() -> void:
	# Reset rotation
	if !button_pressed:
		if _tween_rot and _tween_rot.is_running():
			_tween_rot.kill()
		_tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
		_tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
		_tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	# Reset scale
	if _tween_hover and _tween_hover.is_running():
		_tween_hover.kill()
	_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)

func _on_pressed() -> void:
	selected.emit(self)
