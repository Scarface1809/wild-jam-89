class_name Seats
extends Node2D

@onready var _left_seats: Array[Marker2D] = [%LeftSeat1, %LeftSeat2, %LeftSeat3]
@onready var _right_seats: Array[Marker2D] = [%RightSeat1, %RightSeat2, %RightSeat3]
@onready var _player_seat: Marker2D = %PlayerSeat

var _unit_to_seat: Dictionary = {} # unit_id -> Marker2D
var _unit_to_sprite: Dictionary = {} # unit_id -> Sprite2D

func sync_with_state(state: GameState, _action: Action) -> void:
	if state == null:
		return

	var current_unit_ids: Array[int] = []

	for group: GroupState in state.groups:
		for unit: UnitState in group.units:
			current_unit_ids.append(unit.id)

	# 1. Remove dead units
	for unit_id in _unit_to_sprite.keys():
		if not current_unit_ids.has(unit_id):
			_fade_out_and_remove(unit_id)

	# 2. Add new units
	for group: GroupState in state.groups:
		for unit: UnitState in group.units:
			if not _unit_to_sprite.has(unit.id):
				_assign_seat_and_add(unit, group.type)

func _assign_seat_and_add(unit: UnitState, group_type: Global.GroupType) -> void:
	if _unit_to_seat.has(unit.id):
		return

	if group_type == Global.GroupType.PLAYER:
		_unit_to_seat[unit.id] = _player_seat
		_add_unit(unit)
		return

	var free_seats := _get_free_enemy_seats()
	if free_seats.is_empty():
		push_warning("No free seat for %s" % unit.name)
		return

	free_seats.shuffle()
	_unit_to_seat[unit.id] = free_seats.pop_front()
	_add_unit(unit)

func _get_free_enemy_seats() -> Array[Marker2D]:
	var all_seats: Array[Marker2D] = []
	all_seats.append_array(_left_seats)
	all_seats.append_array(_right_seats)

	var occupied := _unit_to_seat.values()
	var free: Array[Marker2D] = []

	for seat in all_seats:
		if not occupied.has(seat):
			free.append(seat)

	return free

func _add_unit(unit: UnitState) -> void:
	if _unit_to_sprite.has(unit.id):
		return

	var seat: Marker2D = _unit_to_seat.get(unit.id)
	if seat == null:
		return

	var sprite := Sprite2D.new()
	sprite.texture = unit.human_texture
	sprite.position = Vector2.ZERO
	sprite.modulate.a = 0.0

	if _right_seats.has(seat):
		sprite.flip_h = true

	seat.add_child(sprite)
	_unit_to_sprite[unit.id] = sprite

	_fade(sprite, 0.0, 1.0)

func _fade_out_and_remove(unit_id: int) -> void:
	var sprite: Sprite2D = _unit_to_sprite.get(unit_id)
	if sprite == null:
		return

	_unit_to_sprite.erase(unit_id)
	_unit_to_seat.erase(unit_id)

	var tween: Tween = _fade(sprite, sprite.modulate.a, 0.0)
	tween.finished.connect(sprite.queue_free)

func _fade(sprite: Sprite2D, from: float, to: float, time := 0.25) -> Tween:
	sprite.modulate.a = from
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", to, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween
