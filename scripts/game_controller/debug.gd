class_name DebugPanel
extends Control
## Debug Panel

# How often to update the debug panel (in milliseconds)
const FPS_MS: float = 16

@onready var container: VBoxContainer = %VBoxContainer

var _properties: Array = []

func _ready() -> void:
	Global.debug_panel = self
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		visible = !visible
		get_viewport().set_input_as_handled()

func add_debug_property(id: StringName, value, time_in_frames) -> void:
	if _properties.has(id):
		if int(Time.get_ticks_msec() / FPS_MS) % time_in_frames == 0:
			var target = container.find_child(id, true, false) as Label
			target.text = id + ": " + str(value)
	else:
		var property = Label.new()
		container.add_child(property)
		property.name = id
		property.text = id + ": " + str(value)
		_properties.append(id)
