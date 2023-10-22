extends Control

@export var droparea : Node

@export var collision_map_visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if droparea == null:
		droparea = get_node("/root/Main/Droparea")
	$Handle.droparea = droparea
	for child in get_children():
		if child is Control:
			child.mouse_filter = MOUSE_FILTER_IGNORE
	$Handle.mouse_filter = MOUSE_FILTER_STOP
