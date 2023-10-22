extends Control

@export var DragPoint : PackedScene
@export var droparea : Node

@onready var draggable:Control = get_parent()
var isAttached = true
@onready var roadFollower:PathFollow2D = get_parent().get_parent() as PathFollow2D
@onready var collision_map : TileMap = get_node("../collisionmap")

var map_position
var start_position
var collision_cells = []

# Return draggable to start
func return_to_drag_start():
	mouse_filter = Control.MOUSE_FILTER_STOP
	draggable.z_index = 0
	draggable.modulate = Color(1,1,1,1)
	if roadFollower != null && !isAttached:
		draggable.get_parent().remove_child(draggable)
		roadFollower.add_child(draggable)
		isAttached = true
	draggable.position = start_position
	if map_position != null:
		droparea.emit_signal("item_added", draggable)
		droparea.set_collision_cells(collision_cells, map_position)

# Finish dragging the object
func finish_drag(at_position, at_map_position):
	mouse_filter = Control.MOUSE_FILTER_STOP
	draggable.global_position = at_position
	isAttached = true
	start_position = at_position
	map_position = at_map_position
	if map_position != null:
		droparea.set_collision_cells(collision_cells,map_position)

# Build collision points from collision map content
func _ready():
	collision_cells = collision_map.get_used_cells(0)
	if !draggable.collision_map_visible:
		collision_map.queue_free()

# Start drag
func _get_drag_data(_at_position):
	
	if roadFollower != null && isAttached:
		isAttached = false
		roadFollower.remove_child(draggable)
		roadFollower.get_parent().add_child(draggable)
	# Setup guide as preview
	var dragpoint = DragPoint.instantiate()
	dragpoint.droparea = droparea
	dragpoint.draggable = draggable
	dragpoint.handle = self
	set_drag_preview(dragpoint)

	# Remove ourselves from grid if we are on it
	if map_position != null:
		droparea.emit_signal("item_removed", draggable)
		droparea.remove_collision_cells(collision_cells, map_position)
	
	#Put ourselves in front of all other items
	draggable.z_index = 100

	# Remove collision so we don't get in the way of the mouse
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_position = draggable.global_position

	# Return data
	return {
		position = draggable.global_position,
		collision_cells = collision_cells,
		handle = self,
		draggable = draggable,
	}
