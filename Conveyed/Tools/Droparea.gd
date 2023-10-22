extends Control

@onready var collision_map = $CollisionMap

@export var collision_map_visible = false

var bottom_right : Vector2i

signal item_added(item)
signal item_removed(item)

func _ready():
	if !collision_map_visible:
		collision_map.hide()
	bottom_right = collision_map.local_to_map(size)
	for child in get_children():
		if child is Control:
			child.mouse_filter = MOUSE_FILTER_IGNORE

func _can_drop_data(at_position, data):
	if data.handle.droparea != self:
		return false
	var final_pos = at_position - data.handle.size/2
	if is_colliding(data.collision_cells, collision_map.local_to_map(final_pos)):
		data.draggable.modulate = Color(1,0,0,0.5)
		return false
	else:
		data.draggable.modulate = Color(1,1,1,0.5)
		return true

func _drop_data(at_position, data):
	var final_pos = at_position - data.handle.size/2
	if is_colliding(data.collision_cells, collision_map.local_to_map(final_pos)):
		data.handle.return_to_drag_start()
	else:
		data.handle.finish_drag(
			snap_to_collision_grid(collision_map.to_global(at_position) - data.handle.size/2),
			collision_map.local_to_map(final_pos)
		)

func set_collision_cells(collision_cells, offset):
	for collision_cell in collision_cells:
		collision_map.set_cell(0,collision_cell+offset, 0, Vector2i(0,0))

func remove_collision_cells(collision_cells, offset):
	for collision_cell in collision_cells:
		collision_map.set_cell(0,collision_cell+offset)

func snap_to_collision_grid(pos):
	return collision_map.to_global(collision_map.map_to_local(
		collision_map.local_to_map(collision_map.to_local(pos))
	)-Vector2(collision_map.tile_set.tile_size)/2)

func is_colliding(collision_cells, offset = Vector2i(0,0)):
	var own_cells = collision_map.get_used_cells(0)
	for collision_cell in collision_cells:
		var adjusted_cell = collision_cell+offset
		if (adjusted_cell in own_cells
			or adjusted_cell.x < 0
			or adjusted_cell.y < 0
			or adjusted_cell.x >= bottom_right.x
			or adjusted_cell.y >= bottom_right.y
		):
			return true
	return false
