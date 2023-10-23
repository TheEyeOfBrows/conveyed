extends Node2D

@export_range(0.0, 1.0) var time
@export var game_length: float = 15.0

@export var ground_morning: Color = Color(0.655, 0.435, 0.227)
@export var ground_day: Color = Color(1.0,1.0, 1.0)
@export var ground_evening: Color = Color(0.186, 0.469, 0.921)
@export var ground_modulate_percent: float = 0.2

@export var road_speed:float = 2.0
@export var road_spawn_interval_percent:float = 0.03

var progressTime: float
var progress:float
var progressNextSpawn: float = 0

var actors:Array[PackedScene]

var endText:Array[String]


func _ready():
	progressTime = 0
	actors = [
		preload("res://nodes/actors/house.tscn"),
		preload("res://nodes/actors/sheep.tscn"),
		preload("res://nodes/actors/bush.tscn"),
		preload("res://nodes/actors/tree.tscn"),
		preload("res://nodes/actors/pen.tscn"),
		preload("res://nodes/actors/house.tscn"),
		preload("res://nodes/actors/sheep.tscn"),
		preload("res://nodes/actors/bush.tscn"),
		preload("res://nodes/actors/tree.tscn"),
		preload("res://nodes/actors/pen.tscn"),
		preload("res://nodes/actors/sheep.tscn"),
		preload("res://nodes/actors/bush.tscn"),
		preload("res://nodes/actors/tree.tscn"),
		preload("res://nodes/actors/windmill.tscn"),
	]
	endText = [
		"You should be proud",
		"Score: Super",
		"I like what you did here",
	]
	
func _process(delta):
	if progressTime >= game_length:
		if $GameOver.visible == false:
			$GameOver/text.text = endText[randi() % endText.size()]
			$GameOver.visible = true
		return
	progressTime += delta
	
	var oldProgress = progress
	progress = inverse_lerp(0, game_length, progressTime)
	var progressDelta = progress - oldProgress 
	move_road_followers(progressDelta)
	
	if progress > progressNextSpawn:
		while progressNextSpawn < progress:
			progressNextSpawn += road_spawn_interval_percent
		make_road_follower()
	
	$SunPath/Sun.progress_ratio = min(progress, 1.0)
	$Sky_Day.visible = true
	$Sky_Morning.visible = progress < 0.5
	$Sky_Evening.visible = progress >= 0.5
	var alpha = progress * 2.0 if progress < 0.5 else 1.0 - ((progress-0.5)*2)
	$Sky_Day.self_modulate = Color(1.0,1.0,1.0,alpha)
	if progress <= ground_modulate_percent:
		$Ground.self_modulate = lerp(ground_morning, ground_day, progress/ground_modulate_percent)
	elif progress >= 1.0 - ground_modulate_percent:
		var mod_percent:float = remap(progress, 1.0 - ground_modulate_percent, 1.0, 0.0, 1.0)
		$Ground.self_modulate = lerp(ground_day, ground_evening, mod_percent)
	else:
		$Ground.self_modulate = ground_day

func make_road_follower():
	var newF = PathFollow2D.new()
	newF.rotates = false
	$RoadPath.add_child(newF)
	var newAIdx:int = randi() % actors.size()
	var newA:PackedScene = actors[newAIdx]
	var newAI:Control = newA.instantiate()
	newF.add_child(newAI)
	newAI.position = -(newAI.size/2)

func move_road_followers(delta:float):
	for follower in $RoadPath.get_children():
		var followerPath:PathFollow2D = follower as PathFollow2D
		if followerPath != null:
			followerPath.progress_ratio += delta * road_speed
			if followerPath.progress_ratio >= 1.0:
				followerPath.get_parent().remove_child(followerPath)

func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_to_title_pressed():
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
