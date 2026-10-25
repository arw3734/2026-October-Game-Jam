extends Node


var current_time: String
var time_ms: int
var minutes: String
var hours: int
var score: int

@export var rats: Node2D
@export var rat_nav_region: NavigationRegion2D
func _ready() -> void:
	hours = 0
	minutes = "00"
	time_ms = 0
	current_time = "12:00"
	score = 0
	
	for i in range(10):
			if rats.get_child_count() < 60:
				var spawn_location = NavigationServer2D.region_get_random_point(rat_nav_region.get_rid(), 1, false)
				get_parent().spawn_rat(spawn_location)

signal score_added(points: int, reason: String)

func increase_score(value: int, text: String):
	score += value
	score_added.emit(value, text)

func _on_time_timeout() -> void:
	time_ms+=1
	
	if time_ms % 75 > 75/2:
		minutes = "30"
	else:
		minutes = "00"
	
	if time_ms % 75 == 0:
		hours += 1
		for i in range(10):
			if rats.get_child_count() < 60:
				var spawn_location = NavigationServer2D.region_get_random_point(rat_nav_region.get_rid(), 1, false)
				get_parent().spawn_rat(spawn_location)
	
	if time_ms < 75:
		current_time = "12" + ":" + minutes
	else:
		current_time = str(hours) + ":" + minutes
