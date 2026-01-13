class_name Seats
extends Node2D

@onready var _left_seats: Array[Marker2D] = [%LeftSeat1, %LeftSeat2, %LeftSeat3]
@onready var _right_seats: Array[Marker2D] = [%RightSeat1, %RightSeat2, %RightSeat3]
@onready var _player_seat: Marker2D = %PlayerSeat

func initialize_from_state(state: GameState) -> void:
	# Clear all seats
	for seat in _left_seats + _right_seats + [_player_seat]:
		_clear_seat(seat)

	for group: GroupState in state.groups:
		if group.type == Global.GROUP_TYPE.PLAYER:
			_place_player(group)
		else:
			_place_enemies(group)

func _place_player(group: GroupState) -> void:
	assert(group.units.size() == 1)

	var sprite := Sprite2D.new()
	sprite.texture = group.units[0].human_texture
	sprite.position = Vector2.ZERO
	_player_seat.add_child(sprite)

func _place_enemies(group: GroupState) -> void:
	var seats: Array[Marker2D] = []
	seats.append_array(_left_seats)
	seats.append_array(_right_seats)

	for unit in group.units:
		var seat: Marker2D = _get_first_free_seat(seats)
		if seat == null:
			push_warning("No free seat for unit %s" % unit.name)
			return

		var sprite := Sprite2D.new()
		sprite.texture = unit.human_texture
		sprite.flip_h = !_left_seats.has(seat)
		sprite.position = Vector2.ZERO
		seat.add_child(sprite)

func _get_first_free_seat(seats: Array[Marker2D]) -> Marker2D:
	for seat in seats:
		if _is_seat_free(seat):
			return seat
	return null

func _is_seat_free(seat: Marker2D) -> bool:
	return seat.get_child_count() == 0

func _clear_seat(seat: Marker2D) -> void:
	for child in seat.get_children():
		child.queue_free()
