extends Node2D

@export_range(0.0, 1.0) var time
@export var game_length: float = 15.0

@export var ground_morning: Color = Color(0.655, 0.435, 0.227)
@export var ground_day: Color = Color(1.0,1.0, 1.0)
@export var ground_evening: Color = Color(0.186, 0.469, 0.921)
@export var ground_modulate_percent: float = 0.2

var progressTime: float
var progress:float


func _ready():
	progressTime = 0
	
func _process(delta):
	if progressTime >= game_length:
		return
	progressTime += delta
		
	progress = inverse_lerp(0, game_length, progressTime)
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
