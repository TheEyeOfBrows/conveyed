extends ColorRect

func _can_drop_data(at_position, data):
	if ((at_position-data.handle.size/2).x < 0
		or (at_position-data.handle.size/2).y < 0
		or (at_position+data.handle.size/2).x > size.x
		or (at_position+data.handle.size/2).y > size.y
	):
		data.draggable.modulate = Color(1,0,0,0.5)
		return false
	else:
		data.draggable.modulate = Color(1,1,1,0.5)
		return true

func _drop_data(at_position, data):
	data.handle.finish_drag(
		at_position - data.handle.size/2,
		null
	)
