class_name SignalGroup
extends RefCounted

signal _all_completed

var _counter: int = 0

func all(signals: Array) -> void:
    _counter = signals.size()

    if _counter == 0:
        call_deferred("_emit_completed")
    else:
        for sig in signals:
            sig.connect(_on_signal_completed, CONNECT_ONE_SHOT)
    
    await _all_completed

func _on_signal_completed() -> void:
    _counter -= 1
    if _counter == 0:
        _all_completed.emit()

func _emit_completed() -> void:
    _all_completed.emit()
