class_name Card
extends Button

# Signals
signal selected

# Constants
const OUTLINE_MATERIAL: ShaderMaterial = preload(Global.MATERIAL_UIDS.OUTLINE)
const PERSPECTIVE_MATERIAL: ShaderMaterial = preload(Global.MATERIAL_UIDS.PERSPECTIVE)

# Export Variables
@export_range(0.0, 30.0) var angle_x_max: float = 15.0
@export_range(0.0, 30.0) var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0

# Private Variables
var _card_data: CardData
var _tween_rot: Tween
var _tween_hover: Tween
var _tween_selected: Tween

# OnReady Variables
@onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer
@onready var shadow_texture: TextureRect = %ShadowTexture
@onready var suit_texture: TextureRect = %SuitTexture
@onready var type_texture: TextureRect = %TypeTexture
@onready var type_name: Label = %TypeName

# Public Methods
func set_card_data(data: CardData) -> void:
	_card_data = data
	suit_texture.texture = data.get_suit_texture()
	type_texture.texture = data.action.get_icon_texture()
	type_name.text = data.action.get_display_name()

func get_card_data() -> CardData:
	return _card_data

func select() -> void:
	_kill_tween(_tween_selected)

	sub_viewport_container.material = OUTLINE_MATERIAL.duplicate(true)
	_tween_selected = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_selected.tween_property(sub_viewport_container, "position:y", -30.0, 0.55)

func deselect() -> void:
	_kill_tween(_tween_selected)

	sub_viewport_container.material = PERSPECTIVE_MATERIAL.duplicate(true)
	_tween_selected = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_selected.tween_property(sub_viewport_container, "position:y", 0.0, 0.55)

# Private Methods
func _ready() -> void:
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)

func _on_pressed() -> void:
	selected.emit()

func _on_gui_input(event: InputEvent) -> void:
	if button_pressed or not event is InputEventMouseMotion:
		return

	var mouse_pos := get_local_mouse_position()
	var lerp_x := remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_y := remap(mouse_pos.y, 0.0, size.y, 0, 1)

	var rot_x := rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_x))
	var rot_y := rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_y))

	sub_viewport_container.material.set_shader_parameter("x_rot", rot_y)
	sub_viewport_container.material.set_shader_parameter("y_rot", rot_x)

func _on_mouse_entered() -> void:
	z_index = 1
	shadow_texture.visible = true
	_kill_tween(_tween_hover)
	_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_hover.tween_property(sub_viewport_container, "scale", Vector2(1.1, 1.1), 0.5)

func _on_mouse_exited() -> void:
	z_index = 0
	shadow_texture.visible = false
	_reset_rotation()
	_kill_tween(_tween_hover)
	_tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_hover.tween_property(sub_viewport_container, "scale", Vector2.ONE, 0.55)

func _reset_rotation() -> void:
	_kill_tween(_tween_rot)
	_tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	_tween_rot.tween_property(sub_viewport_container.material, "shader_parameter/x_rot", 0.0, 0.5)
	_tween_rot.tween_property(sub_viewport_container.material, "shader_parameter/y_rot", 0.0, 0.5)

func _kill_tween(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()
