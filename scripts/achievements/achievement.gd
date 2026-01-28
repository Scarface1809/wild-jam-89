@abstract class_name Achievement
extends Node

var unlocked: bool = false
var title: String
var description: String

func _init(_title: String, _description: String) -> void:
    title = _title
    description = _description

@abstract func register() -> void

@abstract func unregister() -> void

func unlock() -> void:
    if not unlocked:
        unlocked = true
        print("Achievement unlocked: %s" % title)
