extends Control

@export var draggable : Control
@export var droparea : Control
@export var handle : Node

# while dragging
func _process(_delta):
	var dropRect = droparea.get_global_rect()
	var dropPos = droparea.snap_to_collision_grid(position - handle.size/2)
	if dropRect.has_point(dropPos):
		draggable.global_position = droparea.snap_to_collision_grid(position - handle.size/2)
	else:
		draggable.global_position = position - handle.size/2

func _notification(type):
	if (type == NOTIFICATION_PREDELETE):
		handle.return_to_drag_start()
