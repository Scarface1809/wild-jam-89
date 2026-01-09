class_name Unit
extends Node2D
# Docstring

# Signals
signal defeated

# Private Variables
var _unit_data: UnitData

func init(unit_data: UnitData) -> void:
	_unit_data = unit_data
	name = unit_data.name
	print("Unit ", name, " has been created")
